import SwiftUI

/// View para carregar imagens de forma lazy com placeholder e cache
public struct LazyImageView: View {
    let url: URL?
    let placeholder: Image
    let contentMode: ContentMode
    
    @State private var image: UIImage?
    @State private var isLoading: Bool = false
    @State private var loadFailed: Bool = false
    
    public init(
        url: URL?,
        placeholder: Image = Image(systemName: "photo"),
        contentMode: ContentMode = .fill
    ) {
        self.url = url
        self.placeholder = placeholder
        self.contentMode = contentMode
    }
    
    public var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if loadFailed {
                placeholderView
                    .overlay(
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                            .font(.system(size: 20))
                    )
            } else if isLoading {
                placeholderView
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
            } else {
                placeholderView
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private var placeholderView: some View {
        placeholder
            .resizable()
            .aspectRatio(contentMode: contentMode)
            .foregroundColor(.gray.opacity(0.3))
    }
    
    private func loadImage() async {
        guard let url = url else {
            loadFailed = true
            return
        }
        
        // Verificar cache primeiro
        if let cachedImage = ImageCache.shared.get(forKey: url.absoluteString) {
            self.image = cachedImage
            return
        }
        
        isLoading = true
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let uiImage = UIImage(data: data) {
                // Cachear imagem
                ImageCache.shared.set(uiImage, forKey: url.absoluteString)
                
                await MainActor.run {
                    self.image = uiImage
                    self.isLoading = false
                }
            } else {
                await MainActor.run {
                    self.loadFailed = true
                    self.isLoading = false
                }
            }
        } catch {
            print("❌ Error loading image: \(error.localizedDescription)")
            await MainActor.run {
                self.loadFailed = true
                self.isLoading = false
            }
        }
    }
}

/// Cache simples de imagens em memória
public class ImageCache {
    public static let shared = ImageCache()
    
    private var cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 100 // Máximo de 100 imagens
        cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB
    }
    
    public func get(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    public func set(_ image: UIImage, forKey key: String) {
        let cost = image.jpegData(compressionQuality: 1.0)?.count ?? 0
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }
    
    public func clear() {
        cache.removeAllObjects()
        print("🗑️ Image cache cleared")
    }
}

#Preview {
    VStack(spacing: 20) {
        LazyImageView(
            url: URL(string: "https://picsum.photos/400/300"),
            contentMode: .fill
        )
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        
        LazyImageView(
            url: URL(string: "https://invalid-url"),
            contentMode: .fill
        )
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .padding()
}


