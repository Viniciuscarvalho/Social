# Tarefa 13.0: Criar Feature NegotiationDetail (TCA) (L)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Expandir o `NegotiationDetailsFeature` existente para gerenciar estado completo dos detalhes de uma negociação, incluindo perguntas, respostas, documentos e todas as ações do usuário. Coordenar múltiplas child features se necessário.

## Subtarefas

- [ ] 13.1 Expandir `State` para incluir perguntas, respostas e documentos
- [ ] 13.2 Adicionar actions para carregar perguntas e documentos
- [ ] 13.3 Adicionar actions para criar perguntas
- [ ] 13.4 Adicionar actions para responder perguntas
- [ ] 13.5 Adicionar actions para upload de documentos
- [ ] 13.6 Implementar lógica de carregamento de dados relacionados
- [ ] 13.7 Implementar computed properties (ex: `canAskQuestions`, `canUploadDocuments`)
- [ ] 13.8 Adicionar child states para perguntas e documentos (opcional)
- [ ] 13.9 Implementar marcação automática como lido ao abrir
- [ ] 13.10 Adicionar tratamento de erros para todas as operações
- [ ] 13.11 Implementar atualização de estado após ações (refresh automático)
- [ ] 13.12 Testar fluxo completo de ações

## Detalhes de Implementação

### Localização
- Arquivo: `Projects/Features/Negotiations/Sources/NegotiationDetailsFeature.swift`
- Expandir feature existente

### Expansão do State

```swift
@ObservableState
public struct State: Equatable {
    // ... propriedades existentes ...
    public var questions: [NegotiationQuestion] = []
    public var documents: [NegotiationDocument] = []
    public var isLoadingQuestions: Bool = false
    public var isLoadingDocuments: Bool = false
    public var showingQuestionSheet: Bool = false
    public var showingDocumentUpload: Bool = false
}
```

### Novas Actions

```swift
public enum Action: Equatable {
    // ... actions existentes ...
    case loadQuestions
    case questionsResponse(Result<[NegotiationQuestion], NetworkError>)
    case loadDocuments
    case documentsResponse(Result<[NegotiationDocument], NetworkError>)
    case createQuestion(CreateQuestionRequest)
    case questionCreated(Result<NegotiationQuestion, NetworkError>)
    case answerQuestion(String, String) // questionId, answerText
    case questionAnswered(Result<NegotiationAnswer, NetworkError>)
    case uploadDocument(Data, String) // data, documentType
    case documentUploaded(Result<NegotiationDocument, NetworkError>)
    case markAsRead
}
```

### Lógica do Reducer

- Ao carregar negociação, também carregar perguntas e documentos
- Após criar pergunta, recarregar lista de perguntas
- Após responder pergunta, atualizar state local e recarregar
- Após upload de documento, recarregar lista de documentos
- Ao abrir detalhes, marcar como lido automaticamente

## Critérios de Sucesso

- [ ] State gerencia perguntas, respostas e documentos
- [ ] Todas as ações estão implementadas
- [ ] Carregamento de dados relacionados funciona
- [ ] Marcação automática como lido funciona
- [ ] Atualização de estado após ações funciona
- [ ] Tratamento de erros está completo
- [ ] Feature segue padrões TCA do projeto
- [ ] Build do projeto compila sem erros

## Dependências

- **9.0**: Models devem estar criados
- **10.0**: NegotiationClient deve estar implementado
- **11.0**: NegotiationsListFeature deve estar implementada (para navegação)

## Observações

- Expandir feature existente, não criar nova
- Manter compatibilidade com código existente
- Seguir padrão de outras detail features do projeto

