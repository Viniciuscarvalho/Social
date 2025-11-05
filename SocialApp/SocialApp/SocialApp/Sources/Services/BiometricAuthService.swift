import Foundation
import LocalAuthentication

/// Serviço de autenticação biométrica usando Face ID / Touch ID
public class BiometricAuthService {
    public static let shared = BiometricAuthService()
    
    private let context = LAContext()
    
    private init() {}
    
    /// Tipos de biometria disponíveis
    public enum BiometricType {
        case faceID
        case touchID
        case none
        
        var displayName: String {
            switch self {
            case .faceID: return "Face ID"
            case .touchID: return "Touch ID"
            case .none: return "Senha"
            }
        }
        
        var icon: String {
            switch self {
            case .faceID: return "faceid"
            case .touchID: return "touchid"
            case .none: return "lock.fill"
            }
        }
    }
    
    /// Erros de autenticação biométrica
    public enum BiometricError: LocalizedError {
        case notAvailable
        case notEnrolled
        case authenticationFailed
        case userCancel
        case userFallback
        case systemCancel
        case passcodeNotSet
        case biometryLockout
        case unknown(Error)
        
        public var errorDescription: String? {
            switch self {
            case .notAvailable:
                return "Biometria não disponível neste dispositivo"
            case .notEnrolled:
                return "Nenhuma biometria cadastrada. Configure Face ID ou Touch ID nas configurações do dispositivo"
            case .authenticationFailed:
                return "Falha na autenticação biométrica"
            case .userCancel:
                return "Autenticação cancelada pelo usuário"
            case .userFallback:
                return "Usuário optou por usar senha"
            case .systemCancel:
                return "Autenticação cancelada pelo sistema"
            case .passcodeNotSet:
                return "Senha do dispositivo não configurada"
            case .biometryLockout:
                return "Biometria bloqueada. Use a senha do dispositivo para desbloquear"
            case .unknown(let error):
                return "Erro desconhecido: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Verifica se a biometria está disponível no dispositivo
    public func isBiometricAvailable() -> Bool {
        var error: NSError?
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return canEvaluate
    }
    
    /// Retorna o tipo de biometria disponível
    public func biometricType() -> BiometricType {
        guard isBiometricAvailable() else {
            return .none
        }
        
        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case .none:
            return .none
        @unknown default:
            return .none
        }
    }
    
    /// Autentica o usuário com biometria
    /// - Parameters:
    ///   - reason: Mensagem exibida ao usuário explicando por que a autenticação é necessária
    ///   - fallbackTitle: Título do botão de fallback (opcional)
    /// - Returns: `true` se autenticado com sucesso, caso contrário lança erro
    public func authenticate(
        reason: String,
        fallbackTitle: String? = nil
    ) async throws -> Bool {
        // Criar novo contexto para cada autenticação
        let authContext = LAContext()
        authContext.localizedFallbackTitle = fallbackTitle
        
        // Verificar se biometria está disponível
        var error: NSError?
        guard authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let error = error {
                throw mapLAError(error)
            }
            throw BiometricError.notAvailable
        }
        
        do {
            print("🔐 Iniciando autenticação biométrica...")
            let success = try await authContext.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            
            if success {
                print("✅ Autenticação biométrica bem-sucedida")
            }
            
            return success
        } catch let error as LAError {
            print("❌ Erro na autenticação biométrica: \(error.localizedDescription)")
            throw mapLAError(error)
        } catch {
            print("❌ Erro desconhecido na autenticação: \(error.localizedDescription)")
            throw BiometricError.unknown(error)
        }
    }
    
    /// Autentica com biometria ou senha do dispositivo
    public func authenticateWithDeviceCredentials(
        reason: String
    ) async throws -> Bool {
        let authContext = LAContext()
        
        // Verificar se pode avaliar a política
        var error: NSError?
        guard authContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            if let error = error {
                throw mapLAError(error)
            }
            throw BiometricError.passcodeNotSet
        }
        
        do {
            print("🔐 Iniciando autenticação com credenciais do dispositivo...")
            let success = try await authContext.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: reason
            )
            
            if success {
                print("✅ Autenticação bem-sucedida")
            }
            
            return success
        } catch let error as LAError {
            print("❌ Erro na autenticação: \(error.localizedDescription)")
            throw mapLAError(error)
        } catch {
            print("❌ Erro desconhecido: \(error.localizedDescription)")
            throw BiometricError.unknown(error)
        }
    }
    
    /// Invalida o contexto de autenticação atual
    public func invalidate() {
        context.invalidate()
    }
    
    // MARK: - Private Methods
    
    private func mapLAError(_ error: Error) -> BiometricError {
        guard let laError = error as? LAError else {
            return .unknown(error)
        }
        
        switch laError.code {
        case .biometryNotAvailable:
            return .notAvailable
        case .biometryNotEnrolled:
            return .notEnrolled
        case .authenticationFailed:
            return .authenticationFailed
        case .userCancel:
            return .userCancel
        case .userFallback:
            return .userFallback
        case .systemCancel:
            return .systemCancel
        case .passcodeNotSet:
            return .passcodeNotSet
        case .biometryLockout:
            return .biometryLockout
        default:
            return .unknown(error)
        }
    }
}

// MARK: - Dependency Key

extension BiometricAuthService: TestDependencyKey {
    public static var testValue: BiometricAuthService {
        return BiometricAuthService.shared
    }
}

import ComposableArchitecture

extension DependencyValues {
    public var biometricAuth: BiometricAuthService {
        get { self[BiometricAuthService.self] }
        set { self[BiometricAuthService.self] = newValue }
    }
}



