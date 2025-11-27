import SwiftUI
import PhotosUI
import ComposableArchitecture

// MARK: - Ticket Media Step View (Etapa 4 - Opcional)

struct TicketMediaStepView: View {
    @Bindable var store: StoreOf<AddTicketFeature>
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var isLoadingImages = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(TicketCreationStep.media.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(TicketCreationStep.media.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 8)
                
                // Info Card
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Esta etapa é opcional")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("Adicione até 5 fotos para destacar seu ingresso")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                // Photo Picker
                VStack(alignment: .leading, spacing: 12) {
                    Label {
                        Text("Fotos do Ingresso")
                            .font(.headline)
                    } icon: {
                        Image(systemName: "photo.on.rectangle")
                            .foregroundColor(DSColors.primary)
                    }
                    
                    if store.selectedImageUrls.isEmpty {
                        PhotosPicker(
                            selection: $selectedItems,
                            maxSelectionCount: 5,
                            matching: .images
                        ) {
                            VStack(spacing: 16) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 50))
                                    .foregroundColor(DSColors.primary.opacity(0.6))
                                
                                VStack(spacing: 8) {
                                    Text("Adicionar Fotos")
                                        .font(.headline)
                                    
                                    Text("Toque para selecionar até 5 imagens")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                                    .foregroundColor(DSColors.primary.opacity(0.3))
                            )
                        }
                        .onChange(of: selectedItems) { _, newItems in
                            Task {
                                await loadImages(from: newItems)
                            }
                        }
                    } else {
                        // Selected Images Grid
                        VStack(spacing: 12) {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(Array(store.selectedImageUrls.enumerated()), id: \.offset) { index, imageUrl in
                                    ZStack(alignment: .topTrailing) {
                                        Rectangle()
                                            .fill(Color(.tertiarySystemFill))
                                            .frame(height: 150)
                                            .cornerRadius(12)
                                            .overlay(
                                                Image(systemName: "photo")
                                                    .foregroundColor(.gray)
                                                    .font(.title)
                                            )
                                        
                                        Button {
                                            removeImage(at: index)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                                .background(Circle().fill(Color.white))
                                        }
                                        .padding(8)
                                    }
                                }
                            }
                            
                            if store.selectedImageUrls.count < 5 {
                                PhotosPicker(
                                    selection: $selectedItems,
                                    maxSelectionCount: 5 - store.selectedImageUrls.count,
                                    matching: .images
                                ) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Adicionar Mais Fotos")
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(DSColors.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(DSColors.primary.opacity(0.1))
                                    .cornerRadius(12)
                                }
                                .onChange(of: selectedItems) { _, newItems in
                                    Task {
                                        await loadImages(from: newItems)
                                    }
                                }
                            }
                        }
                    }
                    
                    if isLoadingImages {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Carregando imagens...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    
                    Text("\(store.selectedImageUrls.count)/5 fotos selecionadas")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Tips
                VStack(alignment: .leading, spacing: 12) {
                    Text("Dicas para boas fotos:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        TipRow(icon: "checkmark.circle", text: "Use imagens claras e de alta qualidade")
                        TipRow(icon: "checkmark.circle", text: "Mostre detalhes importantes do ingresso")
                        TipRow(icon: "checkmark.circle", text: "Evite fotos borradas ou escuras")
                    }
                }
                .padding()
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(12)
                
                Spacer(minLength: 40)
            }
            .padding()
        }
    }
    
    private func loadImages(from items: [PhotosPickerItem]) async {
        isLoadingImages = true
        
        // Simular carregamento de imagens
        // Em produção, aqui você faria upload para storage (Supabase, S3, etc)
        for item in items {
            // Por enquanto, apenas adiciona placeholders
            let placeholder = "image_\(UUID().uuidString)"
            store.send(.binding(.set(\.selectedImageUrls, store.selectedImageUrls + [placeholder])))
        }
        
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s
        isLoadingImages = false
        selectedItems = [] // Reset picker
    }
    
    private func removeImage(at index: Int) {
        var urls = store.selectedImageUrls
        urls.remove(at: index)
        store.send(.binding(.set(\.selectedImageUrls, urls)))
    }
}

// MARK: - Tip Row

struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .font(.caption)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        TicketMediaStepView(
            store: Store(
                initialState: AddTicketFeature.State()
            ) {
                AddTicketFeature()
            }
        )
    }
}

