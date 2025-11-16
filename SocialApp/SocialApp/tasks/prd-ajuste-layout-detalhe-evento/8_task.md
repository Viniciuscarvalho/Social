## markdown

## status: pending # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>features/events/i18n</domain>
<type>implementation</type>
<scope>configuration</scope>
<complexity>low</complexity>
<dependencies></dependencies>
</task_context>

# Tarefa 8.0: Adicionar chaves ao String Catalog (pt-BR) para textos da tela

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Criar chaves para títulos/labels da tela (Sobre o evento, Localização, Preço, Data, Local, etc.)

<requirements>
- Usar convenções já adotadas (dot-case)
- Aplicar `String(localized:)`
</requirements>

## Subtarefas

- [ ] 8.1 Definir chaves
- [ ] 8.2 Usar chaves na view

## Detalhes de Implementação

Ver GUIDELINES e CONVENTIONS existentes do projeto.

## Critérios de Sucesso

- Zero literais novas de UI na tela

## Arquivos relevantes
- SocialApp/Resources/Localizable.xcstrings
- Projects/Features/Events/Sources/Details/EventDetailView.swift





