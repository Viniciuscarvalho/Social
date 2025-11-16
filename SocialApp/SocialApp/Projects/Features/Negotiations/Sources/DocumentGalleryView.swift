import SwiftUI
import ComposableArchitecture

public struct DocumentGalleryView: View {
    let documents: [NegotiationDocument]
    let onDelete: ((NegotiationDocument) -> Void)?
    @State private var selectedDocument: NegotiationDocument?
    @State private var showingFullScreen: Bool = false
    @State private var currentIndex: Int = 0
    
    public init(
        documents: [NegotiationDocument],
        onDelete: ((NegotiationDocument) -> Void)? = nil
    ) {
        self.documents = documents
        self.onDelete = onDelete
    }
    
    public var body: some View {
        if documents.isEmpty {
            emptyStateView
        } else {
            VStack(alignment: .leading, spacing: 12) {
                headerView
                gridView
            }
            .fullScreenCover(isPresented: $showingFullScreen) {
                if let selectedDoc = selectedDocument {
                    FullScreenDocumentViewer(
                        documents: documents,
                        selectedDocument: selectedDoc,
                        currentIndex: $currentIndex,
                        onDismiss: {
                            showingFullScreen = false
                        },
                        onDelete: onDelete
                    )
                }
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("Nenhum documento enviado")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            Text("Documentos")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(documents.count)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color(.systemGray6))
                )
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Grid View
    
    private var gridView: some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
        
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Array(documents.enumerated()), id: \.element.id) { index, document in
                DocumentThumbnail(
                    document: document,
                    onTap: {
                        selectedDocument = document
                        currentIndex = index
                        showingFullScreen = true
                    }
                )
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Document Thumbnail

struct DocumentThumbnail: View {
    let document: NegotiationDocument
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                // Image
                AsyncImage(url: URL(string: document.thumbnailUrl ?? document.fileUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 150)
                            .background(Color(.systemGray6))
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "photo")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, minHeight: 150)
                            .background(Color(.systemGray6))
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Status badge
                VStack {
                    HStack {
                        statusBadge
                        Spacer()
                    }
                    Spacer()
                }
                .padding(8)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var statusBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: document.status.icon)
                .font(.system(size: 10, weight: .semibold))
            
            Text(document.status.displayName)
                .font(.system(size: 10, weight: .semibold))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(document.status.color.opacity(0.9))
        )
        .foregroundColor(.white)
        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Full Screen Document Viewer

struct FullScreenDocumentViewer: View {
    let documents: [NegotiationDocument]
    let selectedDocument: NegotiationDocument
    @Binding var currentIndex: Int
    let onDismiss: () -> Void
    let onDelete: ((NegotiationDocument) -> Void)?
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $currentIndex) {
                ForEach(Array(documents.enumerated()), id: \.element.id) { index, document in
                    ZoomableImageView(
                        imageUrl: document.fileUrl,
                        thumbnailUrl: document.thumbnailUrl,
                        scale: $scale,
                        lastScale: $lastScale,
                        offset: $offset,
                        lastOffset: $lastOffset
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .never))
            
            // Top bar
            VStack {
                HStack {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Status badge
                    if currentIndex < documents.count {
                        let document = documents[currentIndex]
                        HStack(spacing: 6) {
                            Image(systemName: document.status.icon)
                                .font(.system(size: 12))
                            Text(document.status.displayName)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(document.status.color.opacity(0.9))
                        )
                        .foregroundColor(.white)
                    }
                    
                    if let deleteHandler = onDelete, currentIndex < documents.count {
                        Button {
                            deleteHandler(documents[currentIndex])
                            if currentIndex < documents.count - 1 {
                                // Mantém no mesmo índice
                            } else if currentIndex > 0 {
                                currentIndex -= 1
                            } else {
                                onDismiss()
                            }
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.red.opacity(0.7))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                Spacer()
                
                // Bottom info
                if currentIndex < documents.count {
                    let document = documents[currentIndex]
                    VStack(spacing: 8) {
                        Text(document.documentType.displayName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        if let uploadedAt = document.uploadedAt {
                            Text("Enviado em \(uploadedAt.formatted(date: .abbreviated, time: .shortened))")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onChange(of: currentIndex) { oldValue, newValue in
            // Reset zoom when changing documents
            scale = 1.0
            lastScale = 1.0
            offset = .zero
            lastOffset = .zero
        }
    }
}

// MARK: - Zoomable Image View

struct ZoomableImageView: View {
    let imageUrl: String
    let thumbnailUrl: String?
    
    @Binding var scale: CGFloat
    @Binding var lastScale: CGFloat
    @Binding var offset: CGSize
    @Binding var lastOffset: CGSize
    
    var body: some View {
        GeometryReader { geometry in
            AsyncImage(url: URL(string: thumbnailUrl ?? imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .tint(.white)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            SimultaneousGesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        let delta = value / lastScale
                                        lastScale = value
                                        scale *= delta
                                        scale = min(max(scale, 1.0), 4.0) // Limit zoom between 1x and 4x
                                    }
                                    .onEnded { _ in
                                        lastScale = 1.0
                                        // Reset if zoomed out too much
                                        if scale < 1.0 {
                                            withAnimation {
                                                scale = 1.0
                                                offset = .zero
                                            }
                                        }
                                    },
                                
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                        )
                case .failure:
                    VStack(spacing: 12) {
                        Image(systemName: "photo")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.5))
                        Text("Erro ao carregar imagem")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Validation Status Extension

extension ValidationStatus {
    var icon: String {
        switch self {
        case .pending:
            return "clock.fill"
        case .inReview:
            return "eye.fill"
        case .approved:
            return "checkmark.circle.fill"
        case .rejected:
            return "xmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .pending:
            return .orange
        case .inReview:
            return .blue
        case .approved:
            return .green
        case .rejected:
            return .red
        }
    }
}

