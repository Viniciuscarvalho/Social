## markdown

## status: pending # Opções: pending, in-progress, completed, excluded

<task_context>
<domain>localization</domain>
<type>implementation</type>
<scope>configuration</scope>
<complexity>small</complexity>
<dependencies></dependencies>
</task_context>

# Tarefa 9.0: Adicionar todas as localizações necessárias no String Catalog

<critical>Ler os arquivos de prd.md e techspec.md desta pasta, se você não ler esses arquivos sua tarefa será invalidada</critical>

## Visão Geral

Adicionar todas as chaves de localização necessárias para as telas de empty state e sucesso no arquivo String Catalog (Localizable.xcstrings), garantindo suporte completo à localização pt-BR.

<requirements>
- Atualizar `SocialApp/Resources/Localizable.xcstrings`
- Adicionar todas as chaves listadas na Tech Spec
- Todas as chaves devem ter tradução pt-BR
- Verificar se alguma chave já existe (evitar duplicação)
- Organizar chaves em grupos lógicos se possível
- Garantir que textos sejam claros e concisos
</requirements>

## Subtarefas

- [ ] 9.1 Listar todas as chaves necessárias baseado nas tarefas 3-8
- [ ] 9.2 Verificar chaves existentes para evitar duplicação
- [ ] 9.3 Adicionar chaves de empty state de busca
- [ ] 9.4 Adicionar chaves de empty state de ingressos
- [ ] 9.5 Adicionar chaves de empty state de favoritos
- [ ] 9.6 Adicionar chaves de empty state de anunciar ingresso
- [ ] 9.7 Adicionar chaves de sucesso de anunciar ingresso
- [ ] 9.8 Adicionar chaves de sucesso de reset de senha
- [ ] 9.9 Revisar todos os textos para clareza e consistência
- [ ] 9.10 Testar localizações no simulador

## Detalhes de Implementação

**Chaves a adicionar**:

**Empty State - Busca**:
- `empty_state.search.no_results.title` = "Nenhum Resultado Encontrado"
- `empty_state.search.no_results.message` = "Tente uma palavra-chave diferente ou filtro para encontrar eventos incríveis perto de você"

**Empty State - Ingressos**:
- `empty_state.tickets.no_upcoming.title` = "Nenhum Ingresso Futuro"
- `empty_state.tickets.no_upcoming.message` = "Você não tem eventos futuros. Encontre eventos emocionantes e compre seus ingressos hoje!"
- `empty_state.tickets.no_past.title` = "Nenhum Ingresso Passado"
- `empty_state.tickets.browse_events` = "Navegar Eventos"

**Empty State - Favoritos**:
- `empty_state.favorites.title` = "Nenhum Favorito Ainda"
- `empty_state.favorites.message` = "Toque no ícone de coração para salvar eventos que você ama e acessá-los a qualquer momento aqui."
- `empty_state.favorites.add_button` = "Adicionar"

**Empty State - Anunciar Ingresso**:
- `empty_state.announce_ticket.title` = "Anunciar Ingresso"
- `empty_state.announce_ticket.message` = "Configure seu ingresso em minutos — personalize detalhes, preços e publique!"
- `empty_state.announce_ticket.button` = "Anunciar Ingresso"

**Sucesso - Anunciar Ingresso**:
- `success.announce_ticket.title` = "Anunciar Ingresso Está Pronto!"
- `success.announce_ticket.message` = "Os detalhes do seu ingresso estão configurados. Revise e publique para disponibilizar para compradores."
- `success.announce_ticket.button` = "Confirmar & Publicar"

**Sucesso - Reset de Senha**:
- `success.password_reset.title` = "Bem-sucedido"
- `success.password_reset.message` = "Sua nova senha foi definida com sucesso!"
- `success.password_reset.button` = "Concluir"

**Formato do arquivo**:
- Arquivo `Localizable.xcstrings` é um JSON estruturado
- Adicionar entradas no formato apropriado do String Catalog
- Manter organização e comentários se necessário

**Verificar existentes**:
- `signin.success.*` pode já existir - decidir se reutiliza ou cria novas
- Algumas mensagens podem ter variações próximas já existentes

## Critérios de Sucesso

- Todas as chaves necessárias adicionadas ao String Catalog
- Traduções pt-BR corretas e consistentes
- Sem duplicação de chaves
- Textos claros e concisos
- Organização adequada do arquivo
- Todas as localizações funcionando nas views correspondentes

## Arquivos relevantes
- `SocialApp/Resources/Localizable.xcstrings` (arquivo principal)
- Todas as views que usam localização (tarefas 3-8)


