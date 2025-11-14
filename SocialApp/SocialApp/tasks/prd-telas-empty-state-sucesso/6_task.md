## markdown

## status: pending # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>features/tickets</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>2.0</dependencies>
</task_context>

# Tarefa 6.0: Implementar empty state inicial de Anunciar Ingresso em AddTicketView

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Adicionar uma tela inicial de boas-vindas (welcome) ao fluxo de anunciar ingresso, exibida antes do fluxo de criação propriamente dito, conforme o design das imagens (substituindo "Create Events" por "Anunciar Ingresso").

<requirements>
- Atualizar `Projects/Features/TicketsList/Sources/AddTicketView.swift`
- Adicionar step `.welcome` ao enum `TicketCreationStep` em AddTicketFeature
- Criar view inicial com ícone de calendário, título "Anunciar Ingresso", mensagem e botão
- Ícone: `calendar` estilizado conforme design (calendário com grid)
- Título: "Anunciar Ingresso" (localizado)
- Mensagem: "Configure seu ingresso em minutos — personalize detalhes, preços e publique!" (localizado)
- Botão "Anunciar Ingresso" que avança para step `.details`
- Exibir apenas quando usuário acessa pela primeira vez ou não há dados preenchidos
- Ajustar StepProgressView para não mostrar welcome no progresso
</requirements>

## Subtarefas

- [ ] 6.1 Adicionar step `.welcome = -1` ao enum TicketCreationStep
- [ ] 6.2 Adicionar state showWelcome no AddTicketFeature.State
- [ ] 6.3 Criar WelcomeStepView com layout conforme design
- [ ] 6.4 Integrar welcome step no TabView de AddTicketView
- [ ] 6.5 Adicionar chaves de localização no String Catalog
- [ ] 6.6 Ajustar StepProgressView para não mostrar welcome
- [ ] 6.7 Implementar lógica de exibição (quando mostrar welcome)
- [ ] 6.8 Testar visualmente no simulador
- [ ] 6.9 Testar navegação do botão para details step

## Detalhes de Implementação

**Modificar enum TicketCreationStep**:
```swift
public enum TicketCreationStep: Int, CaseIterable, Equatable {
    case welcome = -1  // Novo step inicial
    case details = 0
    case pricing = 1
    // ... resto
}
```

**Adicionar state**:
```swift
@ObservableState
public struct State: Equatable {
    public var showWelcome: Bool = true  // Novo
    public var currentStep: TicketCreationStep = .welcome  // Começar em welcome
    // ... resto
}
```

**Criar WelcomeStepView**:
```swift
private var welcomeStepView: some View {
    VStack(spacing: 24) {
        Spacer()
        
        // Ícone de calendário em círculo
        ZStack {
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 100, height: 100)
            
            Image(systemName: "calendar")
                .font(.system(size: 50))
                .foregroundColor(.primary)
        }
        
        VStack(spacing: 8) {
            Text(String(localized: "empty_state.announce_ticket.title"))
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            Text(String(localized: "empty_state.announce_ticket.message"))
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        
        Spacer()
        
        Button(action: {
            store.send(.nextStep) // Vai para .details
        }) {
            Text(String(localized: "empty_state.announce_ticket.button"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.primary)
                .cornerRadius(12)
        }
    }
    .padding(40)
}
```

**Ajustar StepProgressView**:
- Filtrar `.welcome` dos steps exibidos no progresso
- Mostrar apenas `.details` até `.review`

**Lógica de exibição**:
- Mostrar welcome apenas se `showWelcome == true` E `currentStep == .welcome`
- Ao clicar no botão, avançar para `.details` e marcar `showWelcome = false`

## Critérios de Sucesso

- Welcome step adicionado ao enum e funcionando
- View inicial exibida corretamente com layout conforme design
- Ícone de calendário estilizado corretamente
- Botão "Anunciar Ingresso" avança para step de details
- StepProgressView não mostra welcome
- Textos localizados funcionando
- Não aparece após usuário já ter preenchido dados

## Arquivos relevantes
- `Projects/Features/TicketsList/Sources/AddTicketView.swift` (adicionar welcomeStepView)
- `Projects/Features/TicketsList/Sources/AddTicketFeature.swift` (modificar enum e state)
- `SocialApp/Resources/Localizable.xcstrings` (chaves de localização)



