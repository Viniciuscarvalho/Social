import ComposableArchitecture
import Foundation
import Supabase

@DependencyClient
struct AuthClient {
    var signIn: @Sendable (_ email: String, _ password: String) async throws -> AuthResponse
    var signUp: @Sendable (_ name: String, _ email: String, _ password: String) async throws -> AuthResponse
    var signOut: @Sendable () async throws -> Void
    var getCurrentSession: @Sendable () async throws -> (user: User, profile: Profile)?
    var testCredentials: @Sendable (_ email: String, _ password: String) async throws -> Void
}

extension AuthClient: DependencyKey {
    static let liveValue = Self(
        signIn: { email, password in
            print("🔐 AuthClient: Fazendo login para \(email)")
            print("🔐 AuthClient: Cliente Supabase configurado")
            let supabase = SupabaseManager.shared.client
            
            do {
                // Verificar se o usuário existe primeiro
                print("🔍 AuthClient: Verificando se usuário existe...")
                
                // Tentar buscar usuário na tabela auth.users primeiro
                do {
                    let users = try await supabase
                        .from("auth.users")
                        .select("id, email, email_confirmed_at")
                        .eq("email", value: email)
                        .execute()
                    print("🔍 AuthClient: Usuário encontrado na tabela auth.users: \(users)")
                } catch {
                    print("⚠️ AuthClient: Não foi possível verificar usuário na tabela auth.users: \(error)")
                }
                
                // Fazer login no Supabase
                print("🔐 AuthClient: Tentando fazer login no Supabase...")
                let session = try await supabase.auth.signIn(
                    email: email,
                    password: password
                )
                
                print("✅ AuthClient: Login no Supabase bem-sucedido, buscando profile...")
                
                // Buscar o perfil do usuário
                let profile: Profile = try await supabase
                    .from("profiles")
                    .select()
                    .eq("id", value: session.user.id.uuidString)
                    .single()
                    .execute()
                    .value
                
                print("✅ AuthClient: Profile encontrado: \(profile.name)")
                
                // Converter Profile para User (modelo do app)
                let user = User(
                    name: profile.name,
                    title: nil,
                    profileImageURL: profile.avatarUrl,
                    email: profile.email
                )
                var userWithId = user
                userWithId.id = profile.id
                
                // Salvar dados localmente
                UserDefaults.standard.set(session.accessToken, forKey: "authToken")
                UserDefaults.standard.set(profile.id, forKey: "currentUserId")
                
                if let userData = try? JSONEncoder().encode(userWithId) {
                    UserDefaults.standard.set(userData, forKey: "currentUser")
                }
                
                print("✅ AuthClient: Login bem-sucedido para \(profile.name)")
                return AuthResponse(user: userWithId, token: session.accessToken, refreshToken: session.refreshToken)
            } catch {
                print("❌ AuthClient: Erro no login - \(error)")
                
                // Log mais detalhado do erro
                if let authError = error as? AuthError {
                    print("❌ AuthClient: AuthError - \(authError)")
                    print("❌ AuthClient: AuthError Message - \(authError.message)")
                } else if let httpError = error as? HTTPError {
                    print("❌ AuthClient: HTTPError - \(httpError)")
                    print("❌ AuthClient: HTTPError Response - \(httpError.response)")
                } else {
                    print("❌ AuthClient: Erro desconhecido - \(type(of: error))")
                    print("❌ AuthClient: Erro detalhado - \(error.localizedDescription)")
                }
                
                // Converter erro para NetworkError baseado na mensagem
                if let authError = error as? AuthError {
                    let message = authError.message.lowercased()
                    if message.contains("invalid") && message.contains("credentials") {
                        throw NetworkError.invalidCredentials("Credenciais inválidas. Verifique email e senha.")
                    } else if message.contains("email") && message.contains("confirm") {
                        throw NetworkError.emailNotConfirmed("Email não confirmado. Verifique sua caixa de entrada.")
                    } else if message.contains("user") && message.contains("not found") {
                        throw NetworkError.userNotFound("Usuário não encontrado.")
                    } else if message.contains("weak") && message.contains("password") {
                        throw NetworkError.weakPassword("Senha muito fraca.")
                    } else if message.contains("email") && message.contains("already") {
                        throw NetworkError.emailAlreadyExists("Email já cadastrado.")
                    } else {
                        throw NetworkError.authError(authError.message)
                    }
                } else if let httpError = error as? HTTPError {
                    throw NetworkError.httpError(400, String(describing: httpError.response))
                } else {
                    throw NetworkError.unknown(error.localizedDescription)
                }
            }
        },
        signUp: { name, email, password in
            print("📝 AuthClient: Cadastrando usuário \(email)")
            let supabase = SupabaseManager.shared.client
            
            do {
                // Criar usuário no Supabase
                print("🔍 AuthClient: Criando usuário no Supabase...")
                let response = try await supabase.auth.signUp(
                    email: email,
                    password: password,
                    data: ["name": .string(name)]
                )
                
                print("✅ AuthClient: Usuário criado no Supabase, aguardando trigger...")
                
                // Aguardar um pouco para o trigger criar o profile
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 segundos
                
                // Tentar buscar o perfil criado
                var profile: Profile?
                var attempts = 0
                let maxAttempts = 5
                
                while attempts < maxAttempts {
                    do {
                        profile = try await supabase
                            .from("profiles")
                            .select()
                            .eq("id", value: response.user.id.uuidString)
                            .single()
                            .execute()
                            .value
                        break
                    } catch {
                        attempts += 1
                        print("⚠️ AuthClient: Tentativa \(attempts) de buscar profile falhou, aguardando...")
                        if attempts < maxAttempts {
                            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 segundo
                        } else {
                            throw error
                        }
                    }
                }
                
                guard let profile = profile else {
                    throw NSError(domain: "AuthClient", code: -1, userInfo: [NSLocalizedDescriptionKey: "Profile não foi criado após cadastro"])
                }
                
                print("✅ AuthClient: Profile encontrado: \(profile.name)")
                
                // Converter Profile para User (modelo do app)
                let appUser = User(
                    name: profile.name,
                    title: nil,
                    profileImageURL: profile.avatarUrl,
                    email: profile.email
                )
                var userWithId = appUser
                userWithId.id = profile.id
                
                // Salvar dados localmente
                if let session = response.session {
                    UserDefaults.standard.set(session.accessToken, forKey: "authToken")
                    UserDefaults.standard.set(profile.id, forKey: "currentUserId")
                    
                    if let userData = try? JSONEncoder().encode(userWithId) {
                        UserDefaults.standard.set(userData, forKey: "currentUser")
                    }
                    
                    print("✅ AuthClient: Cadastro bem-sucedido para \(profile.name)")
                    return AuthResponse(user: userWithId, token: session.accessToken, refreshToken: session.refreshToken)
                } else {
                    print("⚠️ AuthClient: Sessão não retornada, mas usuário foi criado")
                    // Mesmo sem sessão, retornamos o usuário criado
                    return AuthResponse(user: userWithId, token: "", refreshToken: "")
                }
            } catch {
                print("❌ AuthClient: Erro no cadastro - \(error)")
                
                // Log mais detalhado do erro
                if let authError = error as? AuthError {
                    print("❌ AuthClient: AuthError - \(authError)")
                    print("❌ AuthClient: AuthError Message - \(authError.message)")
                } else if let httpError = error as? HTTPError {
                    print("❌ AuthClient: HTTPError - \(httpError)")
                    print("❌ AuthClient: HTTPError Response - \(httpError.response)")
                } else {
                    print("❌ AuthClient: Erro desconhecido - \(type(of: error))")
                    print("❌ AuthClient: Erro detalhado - \(error.localizedDescription)")
                }
                
                // Converter erro para NetworkError baseado na mensagem
                if let authError = error as? AuthError {
                    let message = authError.message.lowercased()
                    if message.contains("invalid") && message.contains("credentials") {
                        throw NetworkError.invalidCredentials("Credenciais inválidas. Verifique email e senha.")
                    } else if message.contains("email") && message.contains("confirm") {
                        throw NetworkError.emailNotConfirmed("Email não confirmado. Verifique sua caixa de entrada.")
                    } else if message.contains("user") && message.contains("not found") {
                        throw NetworkError.userNotFound("Usuário não encontrado.")
                    } else if message.contains("weak") && message.contains("password") {
                        throw NetworkError.weakPassword("Senha muito fraca.")
                    } else if message.contains("email") && message.contains("already") {
                        throw NetworkError.emailAlreadyExists("Email já cadastrado.")
                    } else {
                        throw NetworkError.authError(authError.message)
                    }
                } else if let httpError = error as? HTTPError {
                    throw NetworkError.httpError(400, String(describing: httpError.response))
                } else {
                    throw NetworkError.unknown(error.localizedDescription)
                }
            }
        },
        signOut: {
            print("🚪 AuthClient: Fazendo logout")
            let supabase = SupabaseManager.shared.client
            
            do {
                // Fazer logout no Supabase
                try await supabase.auth.signOut()
                
                // Limpar dados locais
                UserDefaults.standard.removeObject(forKey: "authToken")
                UserDefaults.standard.removeObject(forKey: "currentUser")
                UserDefaults.standard.removeObject(forKey: "currentUserId")
                
                print("✅ AuthClient: Logout bem-sucedido")
            } catch {
                print("❌ AuthClient: Erro no logout - \(error)")
                throw error
            }
        },
        getCurrentSession: {
            print("🔍 AuthClient: Verificando sessão atual")
            let supabase = SupabaseManager.shared.client
            
            do {
                // Verificar se há sessão ativa
                let session = try await supabase.auth.session
                
                // Buscar o perfil do usuário
                let profile: Profile = try await supabase
                    .from("profiles")
                    .select()
                    .eq("id", value: session.user.id.uuidString)
                    .single()
                    .execute()
                    .value
                
                // Converter Profile para User
                let user = User(
                    name: profile.name,
                    title: nil,
                    profileImageURL: profile.avatarUrl,
                    email: profile.email
                )
                var userWithId = user
                userWithId.id = profile.id
                
                print("✅ AuthClient: Sessão ativa para \(profile.name)")
                return (user: userWithId, profile: profile)
            } catch {
                print("❌ AuthClient: Erro ao verificar sessão - \(error)")
                return nil
            }
        },
        testCredentials: { email, password in
            print("🧪 AuthClient: Testando credenciais para \(email)")
            let supabase = SupabaseManager.shared.client
            
            // Teste 1: Verificar configuração do cliente
            print("🧪 Teste 1 - Configuração do cliente:")
            print("   Cliente Supabase configurado")
            print("   Cliente configurado")
            
            // Teste 2: Tentar buscar usuário na tabela auth.users
            print("🧪 Teste 2 - Buscando usuário na tabela auth.users:")
            do {
                let users = try await supabase
                    .from("auth.users")
                    .select("id, email, email_confirmed_at, created_at")
                    .eq("email", value: email)
                    .execute()
                print("   ✅ Usuário encontrado: \(users)")
            } catch {
                print("   ❌ Erro ao buscar usuário: \(error)")
            }
            
            // Teste 3: Tentar login direto
            print("🧪 Teste 3 - Tentando login direto:")
            do {
                let session = try await supabase.auth.signIn(
                    email: email,
                    password: password
                )
                print("   ✅ Login bem-sucedido!")
                print("   User ID: \(session.user.id)")
                print("   Email: \(session.user.email ?? "N/A")")
                print("   Email confirmed: \(session.user.emailConfirmedAt != nil)")
            } catch {
                print("   ❌ Erro no login: \(error)")
                
                // Log detalhado do erro
                if let authError = error as? AuthError {
                    print("   AuthError message: \(authError.message)")
                }
                if let httpError = error as? HTTPError {
                    print("   HTTPError response: \(httpError.response)")
                }
            }
            
            // Teste 4: Verificar se profile existe
            print("🧪 Teste 4 - Verificando profile:")
            do {
                let profiles = try await supabase
                    .from("profiles")
                    .select("id, email, name")
                    .eq("email", value: email)
                    .execute()
                print("   ✅ Profile encontrado: \(profiles)")
            } catch {
                print("   ❌ Erro ao buscar profile: \(error)")
            }
        }
    )
    
    static let testValue = Self(
        signIn: unimplemented("AuthClient.signIn"),
        signUp: unimplemented("AuthClient.signUp"),
        signOut: { },
        getCurrentSession: { nil },
        testCredentials: unimplemented("AuthClient.testCredentials")
    )
}

extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}
