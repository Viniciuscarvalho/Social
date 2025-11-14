## markdown

## status: pending # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>features/events/ui</domain>
<type>implementation</type>
<scope>middleware</scope>
<complexity>low</complexity>
<dependencies>temporal</dependencies>
</task_context>

# Tarefa 9.0: Tratar estados de carregamento/erro e formatações

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Exibir loading/skeleton, mensagens de erro e garantir formatações corretas de preço e data/hora.

<requirements>
- Skeleton/ProgressView
- Mensagem de erro com retry
</requirements>

## Subtarefas

- [ ] 9.1 Loading/skeleton
- [ ] 9.2 Erro + retry

## Detalhes de Implementação

Conforme techspec.md.

## Critérios de Sucesso

- UX consistente em estados transientes

## Arquivos relevantes
- Projects/Features/Events/Sources/Details/EventDetailView.swift




