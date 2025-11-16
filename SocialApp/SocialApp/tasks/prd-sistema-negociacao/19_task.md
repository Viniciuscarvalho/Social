# Tarefa 19.0: Implementar Revelação de Contato com Biometria (M)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Criar fluxo que requer autenticação biométrica (Face ID/Touch ID) antes de revelar o contato do vendedor. Implementar usando LocalAuthentication framework e mostrar informações reveladas de forma clara e copiável.

## Subtarefas

- [ ] 19.1 Criar `BiometricAuthService` se não existir
- [ ] 19.2 Implementar verificação de disponibilidade de biometria
- [ ] 19.3 Implementar método de autenticação com LocalAuthentication
- [ ] 19.4 Adicionar fallback para senha do dispositivo
- [ ] 19.5 Criar `ContactRevealFeature` com TCA
- [ ] 19.6 Implementar State e Actions para revelação
- [ ] 19.7 Integrar autenticação biométrica no fluxo
- [ ] 19.8 Criar `ContactRevealView` para exibir dados
- [ ] 19.9 Implementar exibição de nome, e-mail e telefone
- [ ] 19.10 Implementar botões de copiar para cada dado
- [ ] 19.11 Adicionar feedback visual ao copiar
- [ ] 19.12 Implementar tratamento de erros de autenticação
- [ ] 19.13 Adicionar proteção de tela (ofuscação quando app vai para background)

## Detalhes de Implementação

### Localização
- Arquivo: `SocialApp/Sources/Services/BiometricAuthService.swift` (se não existir)
- Arquivo: `Projects/Features/Negotiations/Sources/ContactRevealFeature.swift`
- Arquivo: `Projects/Features/Negotiations/Sources/ContactRevealView.swift`

### BiometricAuthService

```swift
public class BiometricAuthService {
    public static let shared = BiometricAuthService()
    
    public func authenticate(
        reason: String,
        fallbackTitle: String = "Usar Senha"
    ) async throws -> Bool {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw BiometricError.notAvailable
        }
        
        return try await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: reason
        )
    }
}
```

### ContactRevealFeature

```swift
@Reducer
public struct ContactRevealFeature {
    @ObservableState
    public struct State: Equatable {
        public var negotiationId: String
        public var seller: User?
        public var isAuthenticating: Bool = false
        public var errorMessage: String?
    }
    
    public enum Action: Equatable {
        case revealContact
        case authenticateWithBiometrics
        case authenticationResult(Bool)
        case contactRevealed(Result<User, NetworkError>)
    }
}
```

### Fluxo

1. Usuário toca em "Revelar Dados de Contato"
2. Sistema solicita autenticação biométrica
3. Se autenticado, chama API para revelar contato
4. Exibe dados em sheet/modal
5. Dados são copiáveis e acionáveis

### Proteção de Dados

- Ofuscar tela quando app vai para background
- Não armazenar dados revelados localmente
- Limpar dados da memória quando sheet fechar

## Critérios de Sucesso

- [ ] Autenticação biométrica funciona (Face ID/Touch ID)
- [ ] Fallback para senha funciona
- [ ] Dados são revelados após autenticação
- [ ] Dados são exibidos de forma clara
- [ ] Botões de copiar funcionam
- [ ] Feedback visual ao copiar é claro
- [ ] Erros de autenticação são tratados
- [ ] Proteção de tela funciona
- [ ] Design segue padrões do app
- [ ] Build do projeto compila sem erros

## Dependências

- **9.0**: Models devem estar criados
- **10.0**: NegotiationClient deve estar implementado
- **13.0**: NegotiationDetailFeature deve estar implementada

## Observações

- Autenticação biométrica é obrigatória (requisito de segurança)
- Considerar UX: tornar processo claro e não frustrante
- Dados sensíveis: não logar informações de contato

