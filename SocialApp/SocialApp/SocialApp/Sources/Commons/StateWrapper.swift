import SwiftUI

/// Wrapper genérico para gerenciar estados de loading, erro e sucesso
public struct StateWrapper<Content: View>: View {
    let isLoading: Bool
    let error: String?
    let isEmpty: Bool
    let emptyMessage: String
    let emptyIcon: String
    let onRetry: (() -> Void)?
    let onRefresh: (() -> Void)?
    let content: Content
    
    public init(
        isLoading: Bool = false,
        error: String? = nil,
        isEmpty: Bool = false,
        emptyMessage: String = "Nenhum item encontrado",
        emptyIcon: String = "tray",
        onRetry: (() -> Void)? = nil,
        onRefresh: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.isLoading = isLoading
        self.error = error
        self.isEmpty = isEmpty
        self.emptyMessage = emptyMessage
        self.emptyIcon = emptyIcon
        self.onRetry = onRetry
        self.onRefresh = onRefresh
        self.content = content()
    }
    
    public var body: some View {
        ZStack {
            // Conteúdo principal
            content
                .opacity(isLoading || error != nil ? 0 : 1)
                .animation(.easeInOut(duration: 0.2), value: isLoading)
            
            // Estado de loading
            if isLoading {
                LoadingView(message: "Carregando...")
            }
            
            // Estado de erro
            if let error = error, !isLoading {
                ErrorView(
                    title: "Ops! Algo deu errado",
                    message: error,
                    actionTitle: "Tentar Novamente",
                    action: onRetry
                )
            }
            
            // Estado vazio (só mostra se não está carregando e não há erro)
            if isEmpty && !isLoading && error == nil {
                EmptyStateView(
                    title: "Nada por aqui",
                    message: emptyMessage,
                    icon: emptyIcon,
                    actionTitle: onRefresh != nil ? "Atualizar" : nil,
                    action: onRefresh
                )
            }
        }
    }
}

/// Modifier para facilitar o uso do StateWrapper
public struct StateModifier: ViewModifier {
    let isLoading: Bool
    let error: String?
    let isEmpty: Bool
    let emptyMessage: String
    let emptyIcon: String
    let onRetry: (() -> Void)?
    let onRefresh: (() -> Void)?
    
    public init(
        isLoading: Bool = false,
        error: String? = nil,
        isEmpty: Bool = false,
        emptyMessage: String = "Nenhum item encontrado",
        emptyIcon: String = "tray",
        onRetry: (() -> Void)? = nil,
        onRefresh: (() -> Void)? = nil
    ) {
        self.isLoading = isLoading
        self.error = error
        self.isEmpty = isEmpty
        self.emptyMessage = emptyMessage
        self.emptyIcon = emptyIcon
        self.onRetry = onRetry
        self.onRefresh = onRefresh
    }
    
    public func body(content: Content) -> some View {
        StateWrapper(
            isLoading: isLoading,
            error: error,
            isEmpty: isEmpty,
            emptyMessage: emptyMessage,
            emptyIcon: emptyIcon,
            onRetry: onRetry,
            onRefresh: onRefresh
        ) {
            content
        }
    }
}

public extension View {
    /// Aplica estados de loading, erro e vazio à view
    func stateWrapper(
        isLoading: Bool = false,
        error: String? = nil,
        isEmpty: Bool = false,
        emptyMessage: String = "Nenhum item encontrado",
        emptyIcon: String = "tray",
        onRetry: (() -> Void)? = nil,
        onRefresh: (() -> Void)? = nil
    ) -> some View {
        self.modifier(StateModifier(
            isLoading: isLoading,
            error: error,
            isEmpty: isEmpty,
            emptyMessage: emptyMessage,
            emptyIcon: emptyIcon,
            onRetry: onRetry,
            onRefresh: onRefresh
        ))
    }
}

#Preview("Loading State") {
    StateWrapper(isLoading: true) {
        VStack {
            Text("Conteúdo da tela")
            Text("Este conteúdo ficará oculto durante o loading")
        }
    }
}

#Preview("Error State") {
    StateWrapper(
        error: "Não foi possível carregar os dados. Verifique sua conexão.",
        onRetry: {
            print("Tentar novamente")
        }
    ) {
        VStack {
            Text("Conteúdo da tela")
            Text("Este conteúdo ficará oculto durante o erro")
        }
    }
}

#Preview("Empty State") {
    StateWrapper(
        isEmpty: true,
        emptyMessage: "Nenhum evento encontrado",
        emptyIcon: "calendar.badge.exclamationmark",
        onRefresh: {
            print("Atualizar")
        }
    ) {
        VStack {
            Text("Conteúdo da tela")
            Text("Este conteúdo ficará oculto quando vazio")
        }
    }
}

#Preview("Success State") {
    StateWrapper {
        VStack(spacing: 20) {
            Text("✅ Conteúdo carregado com sucesso!")
            Text("Lista de eventos:")
            
            ForEach(0..<3) { index in
                HStack {
                    Text("Evento \(index + 1)")
                    Spacer()
                    Text("✅")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
    }
}





