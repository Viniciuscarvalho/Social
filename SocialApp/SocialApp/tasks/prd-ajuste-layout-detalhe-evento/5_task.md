## markdown

## status: pending # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>features/events/navigation</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>http_server</dependencies>
</task_context>

# Tarefa 5.0: Preparar feature/filtro para lista de vendedores por evento

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Disponibilizar endpoint/estado para carregar vendedores que possuem ingressos para o evento selecionado.

<requirements>
- Receber `eventId`
- Retornar lista paginável/filtrável (mínimo: nome e ação “Seguir/Negociar”)
</requirements>

## Subtarefas

- [ ] 5.1 Estado e ação no reducer (ex.: EventsFeature/Route)
- [ ] 5.2 Cliente/serviço para busca de vendedores por `eventId`

## Detalhes de Implementação

Ver techspec.md (Navegação).

## Critérios de Sucesso

- Dados de vendedores disponíveis para a tela de listagem

## Arquivos relevantes
- Projects/Features/Events/Sources/**/*




