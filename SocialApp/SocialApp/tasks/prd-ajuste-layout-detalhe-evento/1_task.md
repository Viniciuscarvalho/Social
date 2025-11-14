## markdown

## status: pending # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>features/events/ui</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>http_server</dependencies>
</task_context>

# Tarefa 1.0: Atualizar layout base da `EventDetailView` conforme anexo

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Implementar a estrutura principal da tela seguindo tipografia, espaçamentos e hierarquia do anexo.

<requirements>
- Manter imagem hero, título e badge de categoria
- Grid/stack de seções com margens conforme design
- Não incluir “participantes” nem “Event Organizer”
</requirements>

## Subtarefas

- [ ] 1.1 Montar seções base e containers
- [ ] 1.2 Ajustar tipografia e espaçamentos

## Detalhes de Implementação

Ver techspec.md (seção Regras de Layout).

## Critérios de Sucesso

- Layout principal reflete o anexo (margens, fontes, hierarquia)
- Build e preview sem quebras

## Arquivos relevantes
- Projects/Features/Events/Sources/Details/EventDetailView.swift






