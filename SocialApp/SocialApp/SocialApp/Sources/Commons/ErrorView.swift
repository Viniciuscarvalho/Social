import SwiftUI

/// View genérica para estados de erro
public struct ErrorView: View {
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    let icon: String
    
    public init(
        title: String = "Ops! Algo deu errado",
        message: String,
        actionTitle: String? = "Tentar Novamente",
        action: (() -> Void)? = nil,
        icon: String = "exclamationmark.triangle"
    ) {
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
        self.icon = icon
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            // Ícone
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            // Título
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            // Mensagem
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
            
            // Botão de ação (opcional)
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text(actionTitle)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 32)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

/// View de erro compacta (para usar em cards ou seções menores)
public struct CompactErrorView: View {
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    public init(
        message: String,
        actionTitle: String? = "Tentar Novamente",
        action: (() -> Void)? = nil
    ) {
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.red)
                
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.red.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
    }
}

/// View de erro para listas vazias
public struct EmptyStateView: View {
    let title: String
    let message: String
    let icon: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    public init(
        title: String = "Nada por aqui",
        message: String,
        icon: String = "tray",
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.actionTitle = actionTitle
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview("Error View") {
    ErrorView(
        title: "Erro ao carregar",
        message: "Não foi possível carregar os eventos. Verifique sua conexão com a internet e tente novamente.",
        action: {
            print("Tentar novamente")
        }
    )
}

#Preview("Compact Error") {
    CompactErrorView(
        message: "Falha ao carregar dados",
        action: {
            print("Tentar novamente")
        }
    )
    .padding()
}

#Preview("Empty State") {
    EmptyStateView(
        title: "Nenhum evento encontrado",
        message: "Não há eventos disponíveis no momento. Tente novamente mais tarde.",
        icon: "calendar.badge.exclamationmark",
        actionTitle: "Atualizar",
        action: {
            print("Atualizar")
        }
    )
}


