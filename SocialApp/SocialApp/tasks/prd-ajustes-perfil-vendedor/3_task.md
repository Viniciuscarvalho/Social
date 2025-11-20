# Tarefa 3.0: Ajustar tela de detalhe do evento removendo botão e corrigindo navegação (S)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Esta tarefa envolve remover o botão "Salvar para depois" da tela de detalhe do evento e ajustar o layout para manter hierarquia visual adequada conforme Figma. Também será necessário preparar a ação de "Negociar ingresso" para navegar para lista de vendedores (implementação completa será na tarefa 4.0).

<requirements>
- Remover botão "Salvar para depois" da tela de detalhe do evento
- Ajustar layout e espaçamentos após remoção do botão
- Garantir que layout está conforme Figma
- Preparar ação de "Negociar ingresso" (navegação será implementada na tarefa 4.0)
</requirements>

## Subtarefas

- [ ] 3.1 Localizar e remover botão "Salvar para depois" na EventDetailView
- [ ] 3.2 Ajustar espaçamentos e layout após remoção
- [ ] 3.3 Verificar conformidade com Figma
- [ ] 3.4 Remover ações relacionadas a "Salvar para depois" na EventDetailFeature
- [ ] 3.5 Preparar ação negotiateTicketTapped para navegação futura
- [ ] 3.6 Testar layout e hierarquia visual

## Detalhes de Implementação

### Remoção do Botão

1. Localizar o botão "Salvar para depois" na `EventDetailView`
2. Remover o componente do SwiftUI
3. Remover ações relacionadas na `EventDetailFeature` (se existirem)
4. Ajustar espaçamentos para manter hierarquia visual

### Ajuste de Layout

1. Revisar espaçamentos entre elementos
2. Garantir que botão "Negociar ingresso" mantenha destaque adequado
3. Verificar conformidade com design do Figma

Referência: Seção "EventDetailFeature (ajustes)" na techspec.md

## Critérios de Sucesso

- Botão "Salvar para depois" foi completamente removido
- Layout está ajustado e hierarquia visual está correta
- Espaçamentos estão adequados conforme Figma
- Botão "Negociar ingresso" mantém destaque adequado
- Não há ações ou código relacionado a "Salvar para depois" no código
- Testes visuais confirmam conformidade com Figma

## Dependências

- Nenhuma (tarefa independente)

## Arquivos relevantes

- `Projects/Features/Events/Sources/EventDetailView.swift` (ou similar)
- `Projects/Features/Events/Sources/EventDetailFeature.swift` (ou similar)

## status: pending

<task_context>
<domain>features/events</domain>
<type>implementation</type>
<scope>ui_adjustment</scope>
<complexity>low</complexity>
<dependencies>none</dependencies>
</task_context>

