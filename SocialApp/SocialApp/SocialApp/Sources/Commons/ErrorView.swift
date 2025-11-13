import SwiftUI

/// View genérica para exibir erros com ações
public struct ErrorView: View {
    let error: Error
    let retryAction: (() -> Void)?
    let dismissAction: (() -> Void)?
    
    public init(
        error: Error,
        retryAction: (() -> Void)? = nil,
        dismissAction: (() -> Void)? = nil
    ) {
        self.error = error
        self.retryAction = retryAction
        self.dismissAction = dismissAction
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
            }
            
            // Error message
            VStack(spacing: 8) {
                Text("Ops! Algo deu errado")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Text(errorMessage)
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            // Actions
            VStack(spacing: 12) {
                if let retryAction = retryAction {
                    Button(action: retryAction) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Tentar Novamente")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppColors.primary)
                        .cornerRadius(12)
                    }
                }
                
                if let dismissAction = dismissAction {
                    Button(action: dismissAction) {
                        Text("Voltar")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
            }
        }
        .padding(32)
        .background(AppColors.background)
    }
    
    private var errorMessage: String {
        if let networkError = error as? NetworkError {
            return networkError.userFriendlyMessage
        }
        return error.localizedDescription
    }
}

/// View compacta de erro inline
public struct InlineErrorView: View {
    let message: String
    let retryAction: (() -> Void)?
    
    public init(message: String, retryAction: (() -> Void)? = nil) {
        self.message = message
        self.retryAction = retryAction
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(AppColors.primaryText)
            
            Spacer()
            
            if let retryAction = retryAction {
                Button(action: retryAction) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
    }
}

/// Empty state view
public struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    public init(
        icon: String = "tray",
        title: String,
        message: String,
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
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(AppColors.tertiaryText)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.primaryText)
                
                Text(message)
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(AppColors.primary)
                        .cornerRadius(12)
                }
            }
        }
        .padding(40)
    }
}

#Preview("Error View") {
    ErrorView(
        error: NetworkError.serverError(500),
        retryAction: {},
        dismissAction: {}
    )
}

#Preview("Inline Error") {
    VStack(spacing: 16) {
        InlineErrorView(
            message: "Não foi possível carregar os dados",
            retryAction: {}
        )
        
        InlineErrorView(
            message: "Erro de conexão"
        )
    }
    .padding()
    .background(AppColors.background)
}

#Preview("Empty State") {
    EmptyStateView(
        icon: "ticket",
        title: "Nenhum Ingresso",
        message: "Você ainda não tem ingressos cadastrados",
        actionTitle: "Adicionar Ingresso",
        action: {}
    )
}










