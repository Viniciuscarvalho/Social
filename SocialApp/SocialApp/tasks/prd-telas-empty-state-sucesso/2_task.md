## markdown

## status: pending # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>commons/components</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>small</complexity>
<dependencies></dependencies>
</task_context>

# Tarefa 2.0: Atualizar e estender EmptyStateView existente (se necessário)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Revisar o componente `EmptyStateView` existente em `ErrorView.swift` e estendê-lo se necessário para suportar todos os casos de uso das telas de empty state do projeto.

<requirements>
- Revisar componente existente em `SocialApp/Sources/Commons/ErrorView.swift` (linhas 125-177)
- Verificar se o componente atende todos os casos de uso necessários
- Se necessário, estender para suportar:
  - Ícones customizados (SF Symbols e assets de imagem)
  - Diferentes tamanhos de ícone
  - Layout otimizado para diferentes contextos
- Manter compatibilidade com uso existente
</requirements>

## Subtarefas

- [ ] 2.1 Revisar uso atual de EmptyStateView no projeto
- [ ] 2.2 Identificar requisitos adicionais necessários
- [ ] 2.3 Estender componente (se necessário) mantendo compatibilidade
- [ ] 2.4 Adicionar suporte a ícones customizados (se necessário)
- [ ] 2.5 Testar componente com todos os casos de uso
- [ ] 2.6 Documentar mudanças (se houver)

## Detalhes de Implementação

O componente já existe e possui:
- Parâmetros: icon (String), title (String), message (String), actionTitle (String?), action (() -> Void)?
- Layout: VStack com ícone, título, mensagem e botão opcional

**Verificar se precisa**:
- Suporte a Image vs Image(systemName:) - pode precisar de ambos
- Tamanho de ícone configurável (atualmente fixo em 60pt)
- Cores de ícone configuráveis (atualmente usa AppColors.tertiaryText)

Se não precisar de mudanças, marcar tarefa como concluída rapidamente.

## Critérios de Sucesso

- Componente revisado e documentado
- Todas as funcionalidades necessárias presentes ou adicionadas
- Compatibilidade com uso existente mantida
- Casos de uso futuros cobertos

## Arquivos relevantes
- `SocialApp/Sources/Commons/ErrorView.swift` (linhas 125-177 - EmptyStateView)
- Uso existente: `Projects/Features/TicketsList/Sources/TicketsListView.swift` (linha 134)



