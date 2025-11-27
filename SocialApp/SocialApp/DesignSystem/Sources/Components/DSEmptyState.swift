import SwiftUI

// MARK: - Empty State Component

public struct DSEmptyState: View {
  
  private let icon: String
  private let title: String
  private let message: String?
  private let actionTitle: String?
  private let action: (() -> Void)?
  
  public init(
    icon: String = "tray.fill",
    title: String,
    message: String? = nil,
    actionTitle: String? = nil,
    action: (() -> Void)? = nil
  ) {
    self.icon = icon
    self.title = title
    self.message = message
    self.actionTitle = actionTitle
    self.action = action
  }
  
  public var body: some View {
    VStack(spacing: DSSpacing.l) {
      // Ícone
      Image(systemName: icon)
        .font(.system(size: 64, weight: .light))
        .foregroundColor(DSColors.textTertiary)
      
      // Textos
      VStack(spacing: DSSpacing.s) {
        Text(title)
          .font(DSTypography.title3(weight: .semibold))
          .foregroundColor(DSColors.textPrimary)
          .multilineTextAlignment(.center)
        
        if let message = message {
          Text(message)
            .font(DSTypography.body())
            .foregroundColor(DSColors.textSecondary)
            .multilineTextAlignment(.center)
        }
      }
      .padding(.horizontal, DSSpacing.xl)
      
      // Botão de ação (opcional)
      if let actionTitle = actionTitle, let action = action {
        Button(actionTitle) {
          action()
        }
        .dsPrimaryButton()
        .padding(.horizontal, DSSpacing.xl)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(DSColors.background)
  }
}

// MARK: - Search Empty State

public struct DSSearchEmptyState: View {
  
  private let searchTerm: String
  
  public init(searchTerm: String) {
    self.searchTerm = searchTerm
  }
  
  public var body: some View {
    DSEmptyState(
      icon: "magnifyingglass",
      title: "Nenhum resultado encontrado",
      message: "Não encontramos resultados para \"\(searchTerm)\".\nTente buscar com palavras diferentes."
    )
  }
}

// MARK: - Error State

public struct DSErrorState: View {
  
  private let title: String
  private let message: String
  private let retryAction: (() -> Void)?
  
  public init(
    title: String = "Algo deu errado",
    message: String = "Ocorreu um erro ao carregar os dados. Por favor, tente novamente.",
    retryAction: (() -> Void)? = nil
  ) {
    self.title = title
    self.message = message
    self.retryAction = retryAction
  }
  
  public var body: some View {
    DSEmptyState(
      icon: "exclamationmark.triangle.fill",
      title: title,
      message: message,
      actionTitle: retryAction != nil ? "Tentar Novamente" : nil,
      action: retryAction
    )
  }
}

// MARK: - No Connection State

public struct DSNoConnectionState: View {
  
  private let retryAction: (() -> Void)?
  
  public init(retryAction: (() -> Void)? = nil) {
    self.retryAction = retryAction
  }
  
  public var body: some View {
    DSEmptyState(
      icon: "wifi.slash",
      title: "Sem conexão",
      message: "Verifique sua conexão com a internet e tente novamente.",
      actionTitle: retryAction != nil ? "Tentar Novamente" : nil,
      action: retryAction
    )
  }
}

// MARK: - Loading Empty (Skeleton)

public struct DSLoadingEmpty: View {
  
  private let icon: String
  private let title: String
  
  public init(
    icon: String = "hourglass",
    title: String = "Carregando..."
  ) {
    self.icon = icon
    self.title = title
  }
  
  public var body: some View {
    VStack(spacing: DSSpacing.l) {
      // Ícone animado
      Image(systemName: icon)
        .font(.system(size: 64, weight: .light))
        .foregroundColor(DSColors.textTertiary)
        .symbolEffect(.pulse)
      
      // Título
      Text(title)
        .font(DSTypography.title3(weight: .semibold))
        .foregroundColor(DSColors.textPrimary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(DSColors.background)
  }
}

// MARK: - Compact Empty State (inline)

public struct DSCompactEmptyState: View {
  
  private let icon: String
  private let message: String
  
  public init(icon: String = "tray.fill", message: String) {
    self.icon = icon
    self.message = message
  }
  
  public var body: some View {
    HStack(spacing: DSSpacing.sm) {
      Image(systemName: icon)
        .font(.system(size: 20, weight: .regular))
        .foregroundColor(DSColors.textTertiary)
      
      Text(message)
        .font(DSTypography.body())
        .foregroundColor(DSColors.textSecondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, DSSpacing.xl)
  }
}

