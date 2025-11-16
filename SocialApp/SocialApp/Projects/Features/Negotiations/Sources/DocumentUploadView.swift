import SwiftUI
import PhotosUI
import ComposableArchitecture

public struct DocumentUploadView: View {
    @Bindable var store: StoreOf<NegotiationDetailsFeature>
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var selectedDocumentType: DocumentType = .ticketPhoto
    @State private var showingImagePicker = false
    @State private var showingSourceSelection = false
    
    public init(store: StoreOf<NegotiationDetailsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                headerView
                
                // Tipo de documento
                documentTypeSelection
                
                // Preview da imagem
                if let image = selectedImage {
                    imagePreview(image: image)
                } else {
                    imagePlaceholder
                }
                
                // Botões de ação
                actionButtons
                
                Spacer()
            }
            .padding()
            .navigationTitle("Enviar Documento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        store.send(.hideDocumentUpload)
                        dismiss()
                    }
                }
            }
            .photosPicker(
                isPresented: $showingImagePicker,
                selection: $selectedItem,
                matching: .images
            )
            .onChange(of: selectedItem) { oldValue, newValue in
                loadImage(from: newValue)
            }
            .confirmationDialog("Selecionar Imagem", isPresented: $showingSourceSelection) {
                Button("Câmera") {
                    // TODO: Implementar câmera
                    showingImagePicker = true
                }
                Button("Galeria") {
                    showingImagePicker = true
                }
                Button("Cancelar", role: .cancel) { }
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Você pode enviar até 2 documentos por negociação")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            
            if store.documents.count > 0 {
                Text("\(store.documents.count) de 2 enviados")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.orange)
            }
        }
    }
    
    // MARK: - Document Type Selection
    
    private var documentTypeSelection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tipo de Documento")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                ForEach([DocumentType.ticketPhoto, DocumentType.idDocument], id: \.self) { type in
                    Button {
                        selectedDocumentType = type
                    } label: {
                        HStack {
                            Image(systemName: type.icon)
                                .font(.system(size: 16))
                            Text(type.displayName)
                                .font(.system(size: 14, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedDocumentType == type ? Color(red: 0.5, green: 0.3, blue: 0.9).opacity(0.2) : Color(.systemGray6))
                        )
                        .foregroundColor(selectedDocumentType == type ? Color(red: 0.5, green: 0.3, blue: 0.9) : .primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedDocumentType == type ? Color(red: 0.5, green: 0.3, blue: 0.9) : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Image Placeholder
    
    private var imagePlaceholder: some View {
        Button {
            showingSourceSelection = true
        } label: {
            VStack(spacing: 16) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)
                
                Text("Selecionar Imagem")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Text("Toque para escolher da galeria ou câmera")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                            .foregroundColor(.secondary.opacity(0.3))
                    )
            )
        }
    }
    
    // MARK: - Image Preview
    
    private func imagePreview(image: UIImage) -> some View {
        VStack(spacing: 12) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 300)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            
            Button {
                selectedImage = nil
                selectedItem = nil
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Remover")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.red)
            }
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Botão selecionar imagem
            if selectedImage == nil {
                Button {
                    showingSourceSelection = true
                } label: {
                    HStack {
                        Image(systemName: "photo.badge.plus")
                        Text("Selecionar Imagem")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.5, green: 0.3, blue: 0.9))
                    )
                }
            }
            
            // Botão enviar
            if let image = selectedImage {
                Button {
                    uploadImage(image)
                } label: {
                    HStack {
                        if store.isUploadingDocument {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.9)
                        } else {
                            Image(systemName: "arrow.up.circle.fill")
                        }
                        Text(store.isUploadingDocument ? "Enviando..." : "Enviar Documento")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(store.isUploadingDocument ? Color.gray : Color(red: 0.5, green: 0.3, blue: 0.9))
                    )
                }
                .disabled(store.isUploadingDocument || store.documents.count >= 2)
                
                // Progress bar
                if store.isUploadingDocument {
                    ProgressView(value: store.uploadProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                        .frame(height: 4)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadImage(from item: PhotosPickerItem?) {
        guard let item = item else { return }
        
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    selectedImage = image
                }
            }
        }
    }
    
    private func uploadImage(_ image: UIImage) {
        // Compressão de imagem (qualidade 0.7)
        guard let imageData = compressImage(image, quality: 0.7) else {
            print("❌ Erro ao comprimir imagem")
            return
        }
        
        // Validação de tamanho (máximo 10MB antes de compressão)
        let maxSize: Int = 10 * 1024 * 1024 // 10MB
        if imageData.count > maxSize {
            print("❌ Imagem muito grande após compressão")
            // TODO: Mostrar erro ao usuário
            return
        }
        
        store.send(.uploadDocument(imageData, selectedDocumentType))
        
        // Fecha o sheet após upload bem-sucedido
        Task {
            // Aguarda o upload completar
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 segundos
            if !store.isUploadingDocument {
                dismiss()
                store.send(.hideDocumentUpload)
            }
        }
    }
    
    private func compressImage(_ image: UIImage, quality: CGFloat = 0.7) -> Data? {
        return image.jpegData(compressionQuality: quality)
    }
}

