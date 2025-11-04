import SwiftUI
import ComposableArchitecture
import PhotosUI

public struct ValidationUploadView: View {
    @Bindable var store: StoreOf<ValidationUploadFeature>
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: PhotosPickerItem?
    
    public init(store: StoreOf<ValidationUploadFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header info
                        headerSection
                        
                        // Image picker section
                        imagePickerSection
                        
                        // Selected images grid
                        if !store.selectedImages.isEmpty {
                            selectedImagesSection
                        }
                        
                        // Description field
                        descriptionSection
                        
                        // Guidelines
                        guidelinesSection
                        
                        // Submit button
                        if store.canSubmit {
                            submitButton
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Validar Ingresso")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .disabled(store.isUploading)
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
                        selectedItem = nil // Reset for next selection
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
                    if store.uploadSuccess {
                        successOverlay
                    } else if store.isUploading {
                        uploadingOverlay
                    }
                }
            )
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 28))
                    .foregroundColor(AppColors.primary)
            }
            
            Text("Envie Provas de Validação")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            Text("Adicione fotos claras do ingresso e uma descrição detalhada")
                .font(.system(size: 14))
                .foregroundColor(AppColors.secondaryText)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Image Picker Section
    
    private var imagePickerSection: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            HStack(spacing: 12) {
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: 20))
                    .foregroundColor(store.canAddMoreImages ? AppColors.primary : .gray)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Adicionar Foto")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(store.canAddMoreImages ? AppColors.primaryText : .gray)
                    
                    Text(store.imagesCountText)
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.tertiaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.tertiaryText)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(store.canAddMoreImages ? AppColors.border : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .disabled(!store.canAddMoreImages)
    }
    
    // MARK: - Selected Images Section
    
    private var selectedImagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fotos Selecionadas")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(Array(store.selectedImages.enumerated()), id: \.offset) { index, image in
                    imageCard(image: image, index: index)
                }
            }
        }
    }
    
    private func imageCard(image: UIImage, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Button {
                store.send(.removeImage(index))
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.red)
                            .frame(width: 20, height: 20)
                    )
            }
            .padding(6)
        }
    }
    
    // MARK: - Description Section
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Descrição")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                Text(store.descriptionCountText)
                    .font(.system(size: 12))
                    .foregroundColor(store.isDescriptionValid ? AppColors.tertiaryText : .red)
            }
            
            ZStack(alignment: .topLeading) {
                if store.proofDescription.isEmpty {
                    Text("Descreva detalhes do ingresso: número, setor, código de barras, etc.")
                        .font(.system(size: 15))
                        .foregroundColor(AppColors.tertiaryText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                
                TextEditor(text: $store.proofDescription)
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.primaryText)
                    .frame(minHeight: 120)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .scrollContentBackground(.hidden)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(store.isDescriptionValid ? AppColors.border : Color.red, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Guidelines Section
    
    private var guidelinesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                
                Text("Diretrizes")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.primaryText)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                guidelineItem(icon: "checkmark.circle", text: "Fotos claras e bem iluminadas")
                guidelineItem(icon: "checkmark.circle", text: "Código de barras visível")
                guidelineItem(icon: "checkmark.circle", text: "Informações legíveis")
                guidelineItem(icon: "checkmark.circle", text: "Máximo de \(store.maxImages) fotos")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.05))
        )
    }
    
    private func guidelineItem(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.green)
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(AppColors.secondaryText)
        }
    }
    
    // MARK: - Submit Button
    
    private var submitButton: some View {
        Button {
            store.send(.submitValidation)
        } label: {
            HStack {
                if store.isUploading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                    Text("Enviando...")
                } else {
                    Text("Enviar Validação")
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: store.canSubmit ? 
                        [AppColors.primary, Color.purple] : 
                        [Color.gray, Color.gray.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
        .disabled(!store.canSubmit)
    }
    
    // MARK: - Uploading Overlay
    
    private var uploadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Progress Circle
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 8)
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .trim(from: 0, to: store.uploadProgress)
                        .stroke(AppColors.primary, lineWidth: 8)
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.3), value: store.uploadProgress)
                    
                    Text("\(Int(store.uploadProgress * 100))%")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 8) {
                    Text("Enviando...")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Comprimindo e fazendo upload das imagens")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.1, green: 0.1, blue: 0.2))
            )
            .padding(40)
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
                        .fill(Color.green)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("Validação Enviada!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Suas provas estão em análise.\nVocê será notificado em breve.")
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

#Preview {
    ValidationUploadView(
        store: Store(
            initialState: ValidationUploadFeature.State(
                negotiationId: "nego-123",
                ticketId: "ticket-123"
            )
        ) {
            ValidationUploadFeature()
        }
    )
}


