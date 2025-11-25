# Tarefa 1.0: Ajustar tela de Profile para incluir seleção de tema e navegação para vendedor (M)

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Esta tarefa envolve ajustar a tela de perfil do usuário para reintroduzir a funcionalidade de seleção de tema e restaurar a navegação para o perfil do vendedor quando o usuário clicar no card/área do vendedor.

<requirements>
- Reintroduzir componente de seleção de tema na tela de perfil
- Integrar ThemeManager existente na UI
- Restaurar funcionalidade de navegação para perfil de vendedor
- Garantir que o card/área do vendedor seja clicável e navegue corretamente
</requirements>

## Subtarefas

- [ ] 1.1 Adicionar componente de seleção de tema na ProfileView
- [ ] 1.2 Integrar ThemeManager.shared na ProfileView
- [ ] 1.3 Adicionar ação navigateToSellerProfile na ProfileFeature
- [ ] 1.4 Implementar navegação do card do vendedor para SellerProfileView
- [ ] 1.5 Testar seleção de tema e persistência
- [ ] 1.6 Testar navegação para perfil de vendedor

## Detalhes de Implementação

### Seleção de Tema

Conforme especificado na techspec.md, o `ThemeManager` já existe no projeto. É necessário:

1. Importar `ThemeManager` na `ProfileView`
2. Adicionar componente visual para seleção (pode ser `ThemeToggleView` se existir, ou criar novo componente)
3. Conectar seleção do usuário ao `ThemeManager.shared`
4. Garantir que mudanças sejam aplicadas imediatamente

### Navegação para Vendedor

1. Identificar o card/área do vendedor na `ProfileView`
2. Adicionar ação de toque que dispara `navigateToSellerProfile` na feature
3. Implementar reducer que atualiza estado de navegação
4. Conectar navegação para `SellerProfileView` passando `sellerId`

Referência: Seção "ProfileFeature (ajustes)" na techspec.md

## Critérios de Sucesso

- Componente de seleção de tema é exibido na tela de perfil
- Usuário pode selecionar entre Claro, Escuro e Automático
- Seleção é persistida e aplicada imediatamente na aplicação
- Card/área do vendedor é clicável na tela de perfil
- Ao clicar no card do vendedor, navega corretamente para SellerProfileView
- Navegação passa o ID do vendedor como parâmetro
- Testes unitários cobrem ações de tema e navegação

## Arquivos relevantes

- `Projects/Features/Profile/ProfileView.swift`
- `Projects/Features/Profile/ProfileFeature.swift`
- `SocialApp/Sources/ThemeApp/ThemeManager.swift`
- `SocialApp/Sources/ThemeApp/ThemeToggleView.swift` (se existir)
- `Projects/Features/SellerProfile/Sources/SellerProfileView.swift`

## status: pending

<task_context>
<domain>features/profile</domain>
<type>implementation</type>
<scope>core_feature</scope>
<complexity>medium</complexity>
<dependencies>theme_manager</dependencies>
</task_context>


