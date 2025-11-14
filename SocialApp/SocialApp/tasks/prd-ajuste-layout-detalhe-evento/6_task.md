## markdown

## status: pending # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>features/events/navigation</domain>
<type>integration</type>
<scope>core_feature</scope>
<complexity>low</complexity>
<dependencies>temporal</dependencies>
</task_context>

# Tarefa 6.0: Ligar botão “Negociar ingresso” à lista de vendedores (sem alterar botão)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Ao tocar no botão existente, navegar para a tela de vendedores do evento.

<requirements>
- Reusar botão existente (sem mudar estilo ou texto)
- Passar `eventId` corretamente
</requirements>

## Subtarefas

- [ ] 6.1 Ação de navegação (rota) para lista de vendedores
- [ ] 6.2 Passagem de `eventId` e teste manual

## Detalhes de Implementação

Ver techspec.md (Navegação).

## Critérios de Sucesso

- Navegação funcionando a partir do botão atual

## Arquivos relevantes
- Projects/Features/Events/Sources/Details/EventDetailView.swift






