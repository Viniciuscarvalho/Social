## markdown

## status: pending # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>features/events</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>small</complexity>
<dependencies>2.0</dependencies>
</task_context>

# Tarefa 3.0: Implementar empty state de busca sem resultados em SearchView

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Atualizar a view `noResultsView` em `SearchView` para exibir um empty state padronizado quando não há resultados de busca, conforme o design das imagens fornecidas.

<requirements>
- Atualizar `Projects/Features/Events/Sources/SearchView.swift` (linhas 177-194)
- Ícone: `magnifyingglass` em círculo cinza claro (conforme design)
- Título: "Nenhum Resultado Encontrado" (localizado)
- Mensagem: "Tente uma palavra-chave diferente ou filtro para encontrar eventos incríveis perto de você" (localizado)
- Sem botão de ação
- Usar EmptyStateView existente ou componente customizado
</requirements>

## Subtarefas

- [ ] 3.1 Adicionar chaves de localização no String Catalog
- [ ] 3.2 Atualizar noResultsView em SearchView.swift
- [ ] 3.3 Aplicar estilos conforme design (ícone em círculo cinza claro)
- [ ] 3.4 Testar visualmente no simulador
- [ ] 3.5 Verificar comportamento quando busca está vazia vs sem resultados

## Detalhes de Implementação

A view já existe (linhas 177-194) mas precisa ser atualizada para:
- Ícone em círculo cinza claro (usar ZStack com Circle e Image)
- Layout seguindo padrão das imagens
- Textos localizados via String Catalog

**Estrutura sugerida**:
```swift
private var noResultsView: some View {
    VStack(spacing: 16) {
        ZStack {
            Circle()
                .fill(Color(.systemGray5)) // Cinza claro
                .frame(width: 80, height: 80)
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.blue) // Azul/preto conforme design
        }
        
        Text(String(localized: "empty_state.search.no_results.title"))
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.primary)
        
        Text(String(localized: "empty_state.search.no_results.message"))
            .font(.system(size: 14))
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
    .padding(.top, 60)
}
```

## Critérios de Sucesso

- Empty state exibido corretamente quando busca retorna vazio
- Layout visualmente alinhado com o design da imagem
- Textos localizados funcionando
- Não aparece quando busca está vazia (só quando há busca mas sem resultados)

## Arquivos relevantes
- `Projects/Features/Events/Sources/SearchView.swift` (linhas 177-194 - noResultsView)
- `SocialApp/Resources/Localizable.xcstrings` (chaves de localização)

