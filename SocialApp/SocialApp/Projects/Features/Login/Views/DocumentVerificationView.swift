import SwiftUI
import ComposableArchitecture
import PhotosUI

public struct DocumentVerificationView: View {
    @Bindable var store: StoreOf<DocumentVerificationFeature>
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: PhotosPickerItem?
    
    public init(store: StoreOf<DocumentVerificationFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color(red: 0.05, green: 0.05, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Content
                ScrollView {
                    VStack(spacing: 32) {
                        // Icon
                        iconSection
                        
                        // Title and description
                        textSection
                        
                        // Document type selector
                        documentTypeSelector
                        
                        // Image picker or preview
                        if let image = store.documentImage {
                            imagePreviewSection(image)
                        } else {
                            imagePickerSection
                        }
                        
                        // Submit button
                        if store.documentImage != nil {
                            submitButton
                        }
                        
                        // Info section
                        infoSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .onChange(of: selectedItem) { oldValue, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    store.send(.imageSelected(image))
                }
            }
        }
        .alert("Erro", isPresented: $store.showingErrorAlert) {
            Button("OK") {
                store.send(.dismissErrorAlert)
            }
        } message: {
            if let errorMessage = store.errorMessage {
                Text(errorMessage)
            }
        }
        .overlay(
            Group {
                if store.verificationSubmitted {
                    successOverlay
                }
            }
        )
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    // MARK: - Icon Section
    
    private var iconSection: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.3), Color.pink.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
            
            Image(systemName: "doc.text.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Text Section
    
    private var textSection: some View {
        VStack(spacing: 12) {
            Text("Verificação de Documento")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Envie uma foto do seu documento para\naumentar sua confiabilidade")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }
    
    // MARK: - Document Type Selector
    
    private var documentTypeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tipo de Documento")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            HStack(spacing: 12) {
                ForEach(DocumentVerificationFeature.State.DocumentType.allCases, id: \.self) { type in
                    documentTypeButton(type)
                }
            }
        }
    }
    
    private func documentTypeButton(_ type: DocumentVerificationFeature.State.DocumentType) -> some View {
        Button {
            store.send(.selectDocumentType(type))
        } label: {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(store.documentType == type ? .white : .white.opacity(0.6))
                
                Text(type.rawValue)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(store.documentType == type ? .white : .white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(store.documentType == type ? 
                          Color.purple.opacity(0.3) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(store.documentType == type ? 
                            Color.purple : Color.white.opacity(0.2), lineWidth: 1.5)
            )
        }
    }
    
    // MARK: - Image Picker Section
    
    private var imagePickerSection: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 8]))
                        .foregroundColor(.white.opacity(0.3))
                        .frame(height: 200)
                    
                    VStack(spacing: 12) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("Selecionar Foto")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Toque para escolher da galeria")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
        }
    }
    
    // MARK: - Image Preview Section
    
    private func imagePreviewSection(_ image: UIImage) -> some View {
        VStack(spacing: 16) {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Button {
                    store.send(.removeImage)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(Color.red)
                                .frame(width: 24, height: 24)
                        )
                }
                .padding(8)
            }
            
            Button {
                selectedItem = nil
                // Reopen picker
            } label: {
                HStack {
                    Image(systemName: "photo")
                    Text("Escolher Outra Foto")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                )
            }
        }
    }
    
    // MARK: - Submit Button
    
    private var submitButton: some View {
        Button {
            store.send(.submitDocument)
        } label: {
            HStack {
                if store.isUploading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                    Text("Enviando...")
                } else {
                    Text("Enviar Documento")
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: store.canSubmit ? 
                        [Color.purple, Color.pink] : [Color.gray, Color.gray.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
        .disabled(!store.canSubmit)
    }
    
    // MARK: - Info Section
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                
                Text("Informações Importantes")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                infoItem(icon: "checkmark.circle", text: "Foto clara e legível")
                infoItem(icon: "checkmark.circle", text: "Documento original (não pode ser fotocópia)")
                infoItem(icon: "checkmark.circle", text: "Todos os dados visíveis")
                infoItem(icon: "lock.shield", text: "Seus dados estão protegidos e seguros")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private func infoItem(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.green)
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    // MARK: - Success Overlay
    
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("Documento Enviado!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Seu documento está em análise.\nVocê será notificado em breve.")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.1, green: 0.1, blue: 0.2))
            )
            .padding(40)
        }
    }
}







