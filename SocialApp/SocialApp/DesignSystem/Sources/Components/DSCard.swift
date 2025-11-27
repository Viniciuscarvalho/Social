import SwiftUI

// MARK: - Card Components

/// Card base do Design System
public struct DSCard<Content: View>: View {
  
  private let content: Content
  private let padding: CGFloat
  private let hasShadow: Bool
  
  public init(
    padding: CGFloat = DSSpacing.m,
    hasShadow: Bool = true,
    @ViewBuilder content: () -> Content
  ) {
    self.padding = padding
    self.hasShadow = hasShadow
    self.content = content()
  }
  
  public var body: some View {
    content
      .padding(padding)
      .background(DSColors.cardBackground)
      .dsCornerRadius(DSRadius.card)
      .conditionalModifier(hasShadow) { view in
        view.dsCardShadow()
      }
  }
}

/// Card com header e conteúdo
public struct DSHeaderCard<Header: View, Content: View>: View {
  
  private let header: Header
  private let content: Content
  private let hasShadow: Bool
  
  public init(
    hasShadow: Bool = true,
    @ViewBuilder header: () -> Header,
    @ViewBuilder content: () -> Content
  ) {
    self.hasShadow = hasShadow
    self.header = header()
    self.content = content()
  }
  
  public var body: some View {
    VStack(alignment: .leading, spacing: DSSpacing.m) {
      header
        .padding(.horizontal, DSSpacing.m)
        .padding(.top, DSSpacing.m)
      
      Divider()
        .background(DSColors.separator)
      
      content
        .padding(.horizontal, DSSpacing.m)
        .padding(.bottom, DSSpacing.m)
    }
    .background(DSColors.cardBackground)
    .dsCornerRadius(DSRadius.card)
    .conditionalModifier(hasShadow) { view in
      view.dsCardShadow()
    }
  }
}

/// Card com imagem no topo
public struct DSImageCard<Content: View>: View {
  
  private let imageURL: String?
  private let imageName: String?
  private let imageHeight: CGFloat
  private let content: Content
  private let hasShadow: Bool
  
  public init(
    imageURL: String? = nil,
    imageName: String? = nil,
    imageHeight: CGFloat = 200,
    hasShadow: Bool = true,
    @ViewBuilder content: () -> Content
  ) {
    self.imageURL = imageURL
    self.imageName = imageName
    self.imageHeight = imageHeight
    self.hasShadow = hasShadow
    self.content = content()
  }
  
  public var body: some View {
    VStack(spacing: 0) {
      // Imagem
      imageSection
        .frame(height: imageHeight)
        .clipped()
      
      // Conteúdo
      content
        .padding(DSSpacing.m)
    }
    .background(DSColors.cardBackground)
    .dsCornerRadius(DSRadius.card)
    .conditionalModifier(hasShadow) { view in
      view.dsCardShadow()
    }
  }
  
  @ViewBuilder
  private var imageSection: some View {
    if let imageURL = imageURL, !imageURL.isEmpty {
      AsyncImage(url: URL(string: imageURL)) { phase in
        switch phase {
        case .empty:
          ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DSColors.secondaryBackground)
        case .success(let image):
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
        case .failure:
          Image(systemName: "photo.fill")
            .foregroundColor(DSColors.textTertiary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DSColors.secondaryBackground)
        @unknown default:
          EmptyView()
        }
      }
    } else if let imageName = imageName {
      Image(imageName)
        .resizable()
        .aspectRatio(contentMode: .fill)
    } else {
      Rectangle()
        .fill(DSColors.secondaryBackground)
    }
  }
}

/// Card compacto/inline
public struct DSCompactCard<Content: View>: View {
  
  private let content: Content
  
  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
  
  public var body: some View {
    content
      .padding(DSSpacing.sm)
      .background(DSColors.cardBackground)
      .dsCornerRadius(DSRadius.sm)
      .dsLightShadow()
  }
}

// MARK: - Helper Modifier

extension View {
  @ViewBuilder
  func conditionalModifier<T: View>(
    _ condition: Bool,
    transform: (Self) -> T
  ) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}

