import ComposableArchitecture
import Foundation
import UIKit

@Reducer
public struct ValidationUploadFeature {
    @ObservableState
    public struct State: Equatable {
        var negotiationId: String
        var ticketId: String
        var selectedImages: [UIImage] = []
        var proofDescription: String = ""
        var isUploading: Bool = false
        var uploadProgress: Double = 0
        var errorMessage: String?
        var showingErrorAlert: Bool = false
        var showingImagePicker: Bool = false
        var uploadSuccess: Bool = false
        
        // Limites
        let maxImages: Int = 3
        let maxDescriptionLength: Int = 500
        
        public init(negotiationId: String, ticketId: String) {
            self.negotiationId = negotiationId
            self.ticketId = ticketId
        }
        
        var canAddMoreImages: Bool {
            return selectedImages.count < maxImages
        }
        
        var canSubmit: Bool {
            return !selectedImages.isEmpty && 
                   !proofDescription.isEmpty && 
                   proofDescription.count <= maxDescriptionLength &&
                   !isUploading
        }
        
        var imagesCountText: String {
            return "\(selectedImages.count)/\(maxImages)"
        }
        
        var descriptionCountText: String {
            return "\(proofDescription.count)/\(maxDescriptionLength)"
        }
        
        var isDescriptionValid: Bool {
            return proofDescription.count <= maxDescriptionLength
        }
    }
    
    public enum Action: BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case openImagePicker
        case closeImagePicker
        case imageSelected(UIImage)
        case removeImage(Int)
        case submitValidation
        case uploadProgress(Double)
        case submitResponse(Result<TicketValidation, NetworkError>)
        case dismissErrorAlert
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case validationSubmitted(TicketValidation)
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
                print("📸 ValidationUploadView apareceu")
                return .none
                
            case .openImagePicker:
                guard state.canAddMoreImages else {
                    state.errorMessage = "Você atingiu o limite de \(state.maxImages) imagens"
                    state.showingErrorAlert = true
                    return .none
                }
                state.showingImagePicker = true
                return .none
                
            case .closeImagePicker:
                state.showingImagePicker = false
                return .none
                
            case let .imageSelected(image):
                guard state.canAddMoreImages else {
                    state.errorMessage = "Você atingiu o limite de \(state.maxImages) imagens"
                    state.showingErrorAlert = true
                    return .none
                }
                
                state.selectedImages.append(image)
                state.showingImagePicker = false
                print("📷 Imagem adicionada. Total: \(state.selectedImages.count)")
                return .none
                
            case let .removeImage(index):
                guard index < state.selectedImages.count else { return .none }
                state.selectedImages.remove(at: index)
                print("🗑️ Imagem removida. Restam: \(state.selectedImages.count)")
                return .none
                
            case .submitValidation:
                guard state.canSubmit else { return .none }
                
                state.isUploading = true
                state.uploadProgress = 0
                state.errorMessage = nil
                
                let negotiationId = state.negotiationId
                let ticketId = state.ticketId
                let description = state.proofDescription
                let images = state.selectedImages
                
                print("📤 Iniciando upload de validação...")
                print("   - Negociação: \(negotiationId)")
                print("   - Ticket: \(ticketId)")
                print("   - Imagens: \(images.count)")
                print("   - Descrição: \(description.prefix(50))...")
                
                return .run { send in
                    do {
                        // Comprimir imagens
                        var compressedData: [Data] = []
                        let totalImages = Double(images.count)
                        
                        for (index, image) in images.enumerated() {
                            // Progresso de compressão (0-20% do total)
                            let compressionProgress = (Double(index) / totalImages) * 0.2
                            await send(.uploadProgress(compressionProgress))
                            
                            guard let imageData = image.jpegData(compressionQuality: 0.7) else {
                                throw NetworkError.unknown("Erro ao comprimir imagem \(index + 1)")
                            }
                            
                            compressedData.append(imageData)
                            print("✅ Imagem \(index + 1) comprimida: \(imageData.count) bytes")
                        }
                        
                        // Progresso de upload (20-80%)
                        await send(.uploadProgress(0.2))
                        
                        // Simular progresso incremental
                        for progress in stride(from: 0.2, through: 0.8, by: 0.15) {
                            try? await Task.sleep(for: .milliseconds(300))
                            await send(.uploadProgress(progress))
                        }
                        
                        // Upload para API
                        let validation = try await negotiationClient.uploadValidationProof(
                            negotiationId: negotiationId,
                            ticketId: ticketId,
                            images: compressedData,
                            description: description
                        )
                        
                        // Finalizar progresso (80-100%)
                        await send(.uploadProgress(1.0))
                        
                        print("✅ Upload de validação concluído")
                        await send(.submitResponse(.success(validation)))
                    } catch {
                        print("❌ Erro no upload: \(error.localizedDescription)")
                        let networkError = error as? NetworkError ?? NetworkError.unknown(error.localizedDescription)
                        await send(.submitResponse(.failure(networkError)))
                    }
                }
                
            case let .uploadProgress(progress):
                state.uploadProgress = progress
                return .none
                
            case let .submitResponse(.success(validation)):
                state.isUploading = false
                state.uploadProgress = 1.0
                state.uploadSuccess = true
                print("✅ Validação enviada com sucesso! Status: \(validation.status)")
                
                return .run { send in
                    await send(.delegate(.validationSubmitted(validation)))
                    try? await Task.sleep(for: .seconds(1.5))
                    await send(.delegate(.dismiss))
                }
                
            case let .submitResponse(.failure(error)):
                state.isUploading = false
                state.uploadProgress = 0
                state.errorMessage = error.userFriendlyMessage
                state.showingErrorAlert = true
                print("❌ Erro ao enviar validação: \(error.userFriendlyMessage)")
                return .none
                
            case .dismissErrorAlert:
                state.showingErrorAlert = false
                state.errorMessage = nil
                return .none
                
            case .binding(\.$proofDescription):
                // Limitar caracteres automaticamente
                if state.proofDescription.count > state.maxDescriptionLength {
                    state.proofDescription = String(state.proofDescription.prefix(state.maxDescriptionLength))
                }
                return .none
                
            case .binding:
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
}




