import ComposableArchitecture
import Foundation
import Supabase

@DependencyClient
public struct ProfileClient {
    public var fetchProfile: @Sendable (_ userId: String) async throws -> Profile
    public var updateProfile: @Sendable (_ profile: Profile) async throws -> Profile
    public var uploadAvatar: @Sendable (_ userId: String, _ imageData: Data) async throws -> String
}

extension ProfileClient: DependencyKey {
    public static let liveValue = Self(
        fetchProfile: { userId in
            print("👤 ProfileClient: Buscando perfil para \(userId)")
            let supabase = SupabaseManager.shared.client
            
            do {
                let profile: Profile = try await supabase
                    .from("profiles")
                    .select()
                    .eq("id", value: userId)
                    .single()
                    .execute()
                    .value
                
                print("✅ ProfileClient: Perfil carregado para \(profile.name)")
                return profile
            } catch {
                print("❌ ProfileClient: Erro ao buscar perfil - \(error)")
                throw error
            }
        },
        updateProfile: { profile in
            print("✏️ ProfileClient: Atualizando perfil \(profile.id)")
            let supabase = SupabaseManager.shared.client
            
            do {
                let updatedProfile: Profile = try await supabase
                    .from("profiles")
                    .update(profile)
                    .eq("id", value: profile.id)
                    .single()
                    .execute()
                    .value
                
                print("✅ ProfileClient: Perfil atualizado com sucesso")
                return updatedProfile
            } catch {
                print("❌ ProfileClient: Erro ao atualizar perfil - \(error)")
                throw error
            }
        },
        uploadAvatar: { userId, imageData in
            print("📷 ProfileClient: Fazendo upload de avatar para \(userId)")
            let supabase = SupabaseManager.shared.client
            
            do {
                // Nome único para o arquivo
                let fileName = "\(userId)/avatar_\(Date().timeIntervalSince1970).jpg"
                
                // Upload para o bucket 'avatars'
                try await supabase.storage
                    .from("avatars")
                    .upload(
                        fileName,
                        data: imageData,
                        options: FileOptions(contentType: "image/jpeg")
                    )
                
                // Obter URL pública
                let publicURL = try supabase.storage
                    .from("avatars")
                    .getPublicURL(path: fileName)
                
                print("✅ ProfileClient: Avatar enviado com sucesso")
                return publicURL.absoluteString
            } catch {
                print("❌ ProfileClient: Erro ao enviar avatar - \(error)")
                throw error
            }
        }
    )
    
    public static let testValue = Self(
        fetchProfile: { userId in
            // Mock profile para testes
            Profile(
                email: "test@example.com",
                name: "Test User",
                avatarUrl: nil,
                bio: nil,
                phone: nil,
                totalSpent: 0,
                eventsAttended: 0,
                notificationsEnabled: true,
                emailNotifications: true,
                language: "pt-BR"
            )
        },
        updateProfile: { profile in profile },
        uploadAvatar: { _, _ in "https://example.com/avatar.jpg" }
    )
}

extension DependencyValues {
    public var profileClient: ProfileClient {
        get { self[ProfileClient.self] }
        set { self[ProfileClient.self] = newValue }
    }
}

