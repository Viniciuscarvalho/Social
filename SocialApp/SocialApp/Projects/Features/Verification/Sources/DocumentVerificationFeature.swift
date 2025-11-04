import ComposableArchitecture
import Foundation
import UIKit

@Reducer
public struct DocumentVerificationFeature {
    @ObservableState
    public struct State: Equatable {
        var documentType: DocumentType = .rg
        var documentImage: UIImage?
        var isUploading: Bool = false
        var uploadProgress: Double = 0
        var errorMessage: String?
        var showingErrorAlert: Bool = false
        var showingImagePicker: Bool = false
        var verificationSubmitted: Bool = false
        
        public init() {}
        
        var canSubmit: Bool {
            return documentImage != nil && !isUploading
        }
        
        public enum DocumentType: String, Codable, Equatable, CaseIterable {
            case rg = "RG"
            case cnh = "CNH"
            case passaporte = "Passaporte"
            
            var displayName: String {
                return rawValue
            }
            
            var icon: String {
                switch self {
                case .rg: return "person.text.rectangle"
                case .cnh: return "car.fill"
                case .passaporte: return "airplane"
                }
            }
            
            var description: String {
                switch self {
                case .rg: return "Registro Geral (RG)"
                case .cnh: return "Carteira Nacional de Habilitação"
                case .passaporte: return "Passaporte Brasileiro"
                }
            }
        }
    }
    
    public enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case selectDocumentType(State.DocumentType)
        case openImagePicker
        case closeImagePicker
        case imageSelected(UIImage)
        case removeImage
        case submitDocument
        case submitResponse(Result<UserVerification, NetworkError>)
        case dismissErrorAlert
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case verificationSubmitted(UserVerification)
            case dismiss
        }
    }
    
    @Dependency(\.negotiationClient) var negotiationClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
                
            case let .selectDocumentType(type):
                state.documentType = type
                return .none
                
            case .openImagePicker:
                state.showingImagePicker = true
                return .none
                
            case .closeImagePicker:
                state.showingImagePicker = false
                return .none
                
            case let .imageSelected(image):
                state.documentImage = image
                state.showingImagePicker = false
                print("📷 Imagem do documento selecionada")
                return .none
                
            case .removeImage:
                state.documentImage = nil
                print("🗑️ Imagem do documento removida")
                return .none
                
            case .submitDocument:
                guard state.canSubmit, let image = state.documentImage else { return .none }
                
                state.isUploading = true
                state.uploadProgress = 0
                state.errorMessage = nil
                
                let documentType = state.documentType.rawValue
                
                // Comprimir imagem para upload
                guard let imageData = image.jpegData(compressionQuality: 0.7) else {
                    state.errorMessage = "Erro ao processar a imagem"
                    state.showingErrorAlert = true
                    state.isUploading = false
                    return .none
                }
                
                print("📤 Enviando documento: \(documentType) (\(imageData.count) bytes)")
                
                return .run { send in
                    do {
                        // Simular progresso de upload
                        for progress in stride(from: 0.0, through: 0.8, by: 0.2) {
                            try? await Task.sleep(for: .milliseconds(300))
                            // TODO: Atualizar progresso na UI quando implementar
                        }
                        
                        let verification = try await negotiationClient.submitDocument(documentType, imageData)
                        await send(.submitResponse(.success(verification)))
                    } catch {
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.submitResponse(.failure(networkError)))
                    }
                }
                
            case let .submitResponse(.success(verification)):
                state.isUploading = false
                state.uploadProgress = 1.0
                state.verificationSubmitted = true
                print("✅ Documento enviado com sucesso! Status: em análise")
                
                return .run { send in
                    await send(.delegate(.verificationSubmitted(verification)))
                    try? await Task.sleep(for: .seconds(2))
                    await send(.delegate(.dismiss))
                }
                
            case let .submitResponse(.failure(error)):
                state.isUploading = false
                state.uploadProgress = 0
                state.errorMessage = error.userFriendlyMessage
                state.showingErrorAlert = true
                print("❌ Erro ao enviar documento: \(error.userFriendlyMessage)")
                return .none
                
            case .dismissErrorAlert:
                state.showingErrorAlert = false
                state.errorMessage = nil
                return .none
                
            case .binding:
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}

