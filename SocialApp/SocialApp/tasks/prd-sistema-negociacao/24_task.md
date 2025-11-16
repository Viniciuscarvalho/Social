# Tarefa 24.0: Implementar Máquina de Estados Visual (M)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Criar componente que mostra o progresso da negociação através das fases (Perguntas → Verificação → Aprovação → Contato Revelado) com indicadores visuais claros de onde o usuário está no processo.

## Subtarefas

- [ ] 24.1 Criar componente `StateMachineView`
- [ ] 24.2 Definir estados da máquina (Perguntas, Verificação, Aprovação, Contato Revelado)
- [ ] 24.3 Implementar layout horizontal com etapas
- [ ] 24.4 Implementar indicadores visuais para cada estado
- [ ] 24.5 Implementar conexão entre etapas (linhas)
- [ ] 24.6 Adicionar ícones para cada etapa
- [ ] 24.7 Implementar cores diferentes para estados (pendente, ativo, completo)
- [ ] 24.8 Adicionar labels descritivos para cada etapa
- [ ] 24.9 Implementar animação ao mudar de estado
- [ ] 24.10 Integrar com `NegotiationDetailsView`
- [ ] 24.11 Testar com diferentes estados de negociação
- [ ] 24.12 Adicionar acessibilidade (VoiceOver)

## Detalhes de Implementação

### Localização
- Arquivo: `SocialApp/Sources/Commons/StateMachineView.swift`
- Criar novo arquivo

### Estrutura do Componente

```swift
struct StateMachineView: View {
    let negotiation: Negotiation
    
    enum Step: Int, CaseIterable {
        case questions = 0
        case verification = 1
        case approval = 2
        case contactRevealed = 3
    }
    
    var body: some View {
        HStack {
            ForEach(Step.allCases, id: \.self) { step in
                StepIndicator(step: step, currentStep: currentStep)
            }
        }
    }
}
```

### Estados Visuais

- **Pendente**: Círculo cinza, linha cinza
- **Ativo**: Círculo azul com animação, linha azul
- **Completo**: Círculo verde com checkmark, linha verde

### Etapas

1. **Perguntas**: Ícone de pergunta, "Perguntas"
2. **Verificação**: Ícone de documento, "Verificação"
3. **Aprovação**: Ícone de checkmark, "Aprovação"
4. **Contato Revelado**: Ícone de contato, "Contato"

### Lógica de Estado Atual

```swift
var currentStep: Step {
    if negotiation.contactRevealed {
        return .contactRevealed
    } else if negotiation.status == .approved {
        return .approval
    } else if negotiation.hasDocuments {
        return .verification
    } else {
        return .questions
    }
}
```

## Critérios de Sucesso

- [ ] Componente exibe todas as etapas corretamente
- [ ] Indicadores visuais são claros e distintos
- [ ] Estado atual é destacado adequadamente
- [ ] Animações são sutis e melhoram compreensão
- [ ] Labels são descritivos e claros
- [ ] Integração com view funciona
- [ ] Funciona com diferentes estados de negociação
- [ ] Acessibilidade está implementada
- [ ] Design segue padrões do app
- [ ] Build do projeto compila sem erros

## Dependências

- **9.0**: Models devem estar criados
- **13.0**: NegotiationDetailFeature deve estar implementada

## Observações

- Componente deve ser reutilizável
- Considerar diferentes tamanhos de tela
- Focar em clareza visual sobre complexidade

