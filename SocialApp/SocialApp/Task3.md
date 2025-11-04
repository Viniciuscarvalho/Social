<role>
Você é um desenvolvedor sênior Swift especializado em iOS, responsável por corrigir bugs críticos e problemas de performance na tela de Perfil da Vendedor do aplicativo Ventür de marketplace de ingressos.
</role>

**MANDATORY REQUIREMENTS**
- **YOU MUST NEED** to use perplexity and context7 para buscar informações quando tiver alguma biblioteca externa ou tools **NEVER RELY** somente in nos models data.

<instructions>
Corrija os seguintes problemas identificados na tela de Perfil da Vendedor:

1. ERRO DE NAVEGAÇÃO (CRÍTICO)
   - A navegação para o perfil da vendedor está falhando consistentemente no primeiro request
   - Erro exibido: "Erro ao carregar perfil" com botão "Tentar Novamente"
   - Identifique e corrija a causa raiz do erro no carregamento inicial

2. PROBLEMA DE PERFORMANCE - REQUESTS DESNECESSÁRIOS
   - A tela está fazendo request para buscar tickets toda vez que é acessada
   - Implementar sistema de cache para evitar requisições repetidas
   - Requests devem ocorrer APENAS:
     * No primeiro carregamento bem-sucedido
     * Quando o usuário executar pull-to-refresh manualmente

3. FILTRO INCORRETO DE DADOS
   - Atualmente está trazendo TODOS os eventos do sistema
   - Deve trazer APENAS os ingressos (tickets) que pertencem àquela vendedor específica
   - Filtrar por sellerId corretamente

Objetivo: Tornar a tela estável, performática e com dados corretos.
</instructions>

<requirements>
1. CORREÇÃO DE ERRO DE NAVEGAÇÃO
   - Verificar se sellerId está sendo passado corretamente na navegação
   - Validar parâmetros antes de fazer qualquer request
   - Implementar tratamento de erro robusto com logs específicos
   - Garantir que dados necessários existem antes de renderizar a tela
   - Adicionar fallback para dados ausentes ou inválidos

2. IMPLEMENTAÇÃO DE CACHE
   - Criar sistema de cache em memória para dados da vendedor
   - Estrutura sugerida:
     * Cache de dados da vendedor (perfil)
     * Cache de lista de ingressos
     * Timestamp de última atualização
   - Cache deve ser invalidado apenas quando:
     * Usuário executa pull-to-refresh
     * App retorna do background após período longo (opcional)
     * Dados ficam muito antigos (ex: > 30 minutos)

3. FILTRO CORRETO DE DADOS
   - Implementar lógica de filtro:
```
     tickets_da_vendedor = tickets.filter { $0.sellerId == vendedor.id }
```
   - Para cada ticket filtrado, buscar informações do evento correspondente
   - NÃO trazer lista completa de eventos desnecessariamente
   - Buscar apenas eventos relacionados aos tickets da vendedor

4. OTIMIZAÇÃO DE REQUESTS
   - Avaliar se pode passar dados da vendedor via parâmetro de navegação
   - Reduzir número de requests ao mínimo necessário
   - Implementar request batch se possível (buscar múltiplos dados numa chamada)
   - Usar dados já carregados em telas anteriores quando disponível

5. GESTÃO DE ESTADO
   - Implementar estados claros:
     * .loading (primeira vez)
     * .loaded (dados carregados com sucesso)
     * .refreshing (pull to refresh)
     * .error (falha no carregamento)
     * .cached (usando dados do cache)
   - Cada estado deve ter UI apropriada

6. PULL TO REFRESH
   - Implementar UIRefreshControl ou equivalente SwiftUI
   - Ao fazer pull to refresh:
     * Invalidar cache
     * Fazer nova request
     * Atualizar timestamp
     * Mostrar indicador de loading
     * Feedback ao usuário quando concluído
</requirements>

<critical>
1. CAUSA RAIZ DO ERRO INICIAL
   - IDENTIFIQUE exatamente por que o primeiro request falha
   - Possíveis causas a investigar:
     * sellerId nulo ou inválido
     * Timing de navegação (tela renderiza antes dos dados)
     * Dados não inicializados corretamente
     * Erro de parsing de JSON
     * Problema de lifecycle (viewDidLoad vs viewWillAppear)
   - CORRIJA a causa raiz, não apenas os sintomas

2. EVITAR REQUESTS REDUNDANTES
   - NUNCA fazer request automático em viewWillAppear/onAppear se dados já existem
   - Verificar cache ANTES de fazer qualquer request
   - Pattern recomendado:
```
     if cache.isValid && cache.hasData {
         usar cache
     } else {
         fazer request
     }
```

3. FILTRO DE DADOS OBRIGATÓRIO
   - É INACEITÁVEL trazer todos os eventos do sistema
   - Impacto de performance grave
   - Desperdício de dados móveis do usuário
   - SEMPRE filtrar por sellerId específico

4. INTEGRIDADE DE DADOS
   - Garantir que sellerId é consistente em toda a navegação
   - Validar que sellerId existe antes de fazer qualquer operação
   - Tratar caso onde vendedor não tem ingressos (lista vazia é válida)

5. EXPERIÊNCIA DO USUÁRIO
   - Erro inicial quebra completamente a experiência
   - Usuário não deve ver tela de erro na primeira vez
   - Loading deve ser mostrado enquanto carrega pela primeira vez
   - Cache deve tornar navegações subsequentes instantâneas
</critical>

<acceptance_criteria>
✓ Navegação para perfil da vendedor funciona 100% das vezes no primeiro acesso
✓ Nenhum erro "Erro ao carregar perfil" aparece em navegação normal
✓ Request de tickets só ocorre na primeira vez e em pull-to-refresh
✓ Cache é implementado e funciona corretamente
✓ Navegações subsequentes são instantâneas (usam cache)
✓ Pull-to-refresh funciona e atualiza dados corretamente
✓ Apenas ingressos da vendedor específica são exibidos
✓ Nenhum ticket de outras vendedors aparece na lista
✓ Quantidade de "Ingressos" na estatística está correta (apenas da vendedor)
✓ Performance é visivelmente melhor (sem delays desnecessários)
✓ Logs claros para debugging em caso de erro
✓ Estados de loading, cached, e error estão bem definidos
✓ Dados são consistentes entre navegações
✓ Não há memory leaks com o sistema de cache
✓ App não faz requests desnecessários em background
</acceptance_criteria>

<behaviour_details>
1. FLUXO CORRETO DE CARREGAMENTO - PRIMEIRA VEZ
   - Usuário toca em card da vendedor na tela anterior
   - App navega para SellerProfileView passando sellerId
   - Tela aparece mostrando skeleton/loading state
   - App verifica cache:
     * Se cache válido existe: usa cache, transição instantânea
     * Se não há cache: faz request
   - Request busca:
     * Dados da vendedor (se necessário)
     * Tickets filtrados por sellerId
     * Informações dos eventos relacionados aos tickets
   - Dados são armazenados em cache com timestamp
   - UI atualiza mostrando dados completos
   - Estado muda para .loaded

2. FLUXO CORRETO - NAVEGAÇÕES SUBSEQUENTES
   - Usuário retorna à tela de perfil da mesma vendedor
   - App verifica cache IMEDIATAMENTE
   - Cache é válido? 
     * SIM: Mostra dados instantaneamente (sem loading, sem request)
     * NÃO: Segue fluxo de primeira vez
   - Nenhuma animação de loading
   - Experiência instantânea

3. FLUXO DE PULL TO REFRESH
   - Usuário arrasta tela para baixo
   - Indicador de refresh aparece
   - Cache é invalidado
   - Request é feito (mesmo que dados já existam)
   - Ao completar:
     * Cache é atualizado com novos dados
     * Timestamp atualizado
     * Indicador desaparece
     * Mensagem sutil de confirmação (opcional)

4. FILTRO DE DADOS IMPLEMENTADO
```swift
   // Pseudocódigo do filtro correto
   func loadSellerTickets(sellerId: String) {
       // 1. Filtrar apenas tickets desta vendedor
       let sellerTickets = allTickets.filter { $0.sellerId == sellerId }
       
       // 2. Extrair IDs únicos dos eventos
       let eventIds = Set(sellerTickets.map { $0.eventId })
       
       // 3. Buscar apenas os eventos necessários
       let relevantEvents = allEvents.filter { eventIds.contains($0.id) }
       
       // 4. Combinar dados
       let ticketsWithEventInfo = sellerTickets.map { ticket in
           let event = relevantEvents.first { $0.id == ticket.eventId }
           return TicketViewModel(ticket: ticket, event: event)
       }
       
       // 5. Atualizar UI
       self.tickets = ticketsWithEventInfo
   }
```

5. TRATAMENTO DE ERROS ESPECÍFICO
   - Se erro no primeiro carregamento:
     * Logar erro específico (network, parsing, etc)
     * Mostrar mensagem clara ao usuário
     * Oferecer botão "Tentar Novamente"
     * Não mostrar tela vazia sem contexto
   
   - Se erro em pull-to-refresh:
     * Manter dados anteriores visíveis
     * Mostrar toast/snackbar com erro
     * Não limpar tela
     * Permitir usuário continuar usando dados em cache

6. GESTÃO DE CACHE
   - Estrutura de cache:
```swift
     struct SellerProfileCache {
         let sellerId: String
         let sellerData: Seller
         let tickets: [Ticket]
         let events: [Event]
         let timestamp: Date
         
         var isValid: Bool {
             Date().timeIntervalSince(timestamp) < 1800 // 30 min
         }
     }
```
   
   - Cache em memória (não persistir em disco inicialmente)
   - Usar dicionário com sellerId como chave
   - Limpar cache ao sair do app ou após tempo excessivo

7. LOGS E DEBUGGING
   - Adicionar logs em pontos críticos:
     * "Navegando para perfil da vendedor: [sellerId]"
     * "Cache encontrado: [válido/inválido]"
     * "Fazendo request para tickets da vendedor"
     * "Request concluído: [X] tickets encontrados"
     * "Erro ao carregar perfil: [detalhes]"
   - Logs devem ajudar a identificar problemas rapidamente

8. VALIDAÇÕES NECESSÁRIAS
   - Antes de qualquer operação, validar:
     * sellerId não é nil
     * sellerId não é string vazia
     * sellerId existe na lista de vendedores
   - Se validação falhar:
     * Não prosseguir
     * Mostrar erro apropriado
     * Logar para debugging
     * Voltar para tela anterior (opcional)
</behaviour_details>