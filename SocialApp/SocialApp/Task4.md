<role>
Você é um desenvolvedor Swift sênior especializado em SwiftUI e The Composable Architecture (TCA). Você vai implementar e corrigir o CRUD completo de tickets (ingressos) no aplicativo SocialClub, garantindo sincronização de estado em toda a aplicação e consistência visual.
</role>

**MANDATORY REQUIREMENTS**
- **YOU MUST NEED** to use perplexity and context7 para buscar informações quando tiver alguma biblioteca externa ou tools **NEVER RELY** somente in nos models data.

<dependent_context>
- O aplicativo já possui:
  - Sistema de autenticação de usuários
  - Listagem completa de tickets (todos os tickets disponíveis)
  - Área de perfil do usuário com "Meus Ingressos"
  - Funcionalidade de adicionar tickets (CREATE)
  - Funcionalidade de deletar tickets na tela "Meus Ingressos" (DELETE - parcial)
- Baseie-se nas implementações existentes de:
  - Gerenciamento de estado com TCA
  - Estrutura de dados de Ticket e Event
  - Navegação entre telas
  - Sistema de cache implementado anteriormente
</dependent_context>

<contexto>
Atualmente o aplicativo possui problemas críticos no fluxo CRUD de tickets:

1. **CRUD Incompleto:**
   - CREATE funciona: usuário pode adicionar ticket e se torna vendedor
   - READ funciona: tickets são listados
   - UPDATE não está implementado
   - DELETE funciona parcialmente: apenas atualiza lista local

2. **Sincronização de Estado Quebrada:**
   - Ao deletar um ticket em "Meus Ingressos", a lista local atualiza corretamente
   - PORÉM o ticket deletado ainda aparece na listagem completa da aplicação
   - Cache e estado global não são invalidados/atualizados
   - Outras telas que mostram aquele ticket não são notificadas da deleção

3. **Inconsistência Visual:**
   - Ao inserir novo ticket, o espaçamento dos cards fica diferente dos demais
   - Conforme imagem anexada, há espaçamento irregular entre cards
   - Layout não está uniforme após operações CRUD

**Objetivo:** Garantir que operações CRUD reflitam em TODA a aplicação, com estado sincronizado e UI consistente.
</contexto>

<escopo>
Esta tarefa deve implementar/corrigir:

1. **CRUD Completo de Tickets:**
   - CREATE: já funciona, mas validar e garantir consistência
   - READ: já funciona, mas garantir fonte única de verdade
   - UPDATE: implementar edição de tickets (preço, tipo, status)
   - DELETE: corrigir para sincronizar em toda aplicação

2. **Sincronização Global de Estado:**
   - Centralizar estado de tickets em um Store TCA único
   - Implementar sistema de notificações/eventos para mudanças de estado
   - Invalidar caches quando tickets são criados/editados/deletados
   - Garantir que todas as telas refletem o estado mais recente

3. **Correção de Layout:**
   - Padronizar espaçamento entre cards de tickets
   - Garantir consistência visual após inserções/remoções
   - Usar componentes reutilizáveis para evitar divergências

4. **Atualização em Tempo Real:**
   - Ao deletar ticket em "Meus Ingressos" → atualizar listagem completa
   - Ao adicionar ticket → aparecer imediatamente em todas listas relevantes
   - Ao editar ticket → refletir mudanças em todas as visualizações

5. **Gestão de Relacionamentos:**
   - Tickets relacionados a eventos (via eventId)
   - Tickets relacionados a vendedores (via sellerId)
   - Atualizar contadores e estatísticas automaticamente
</escopo>

<tca_architecture>
Estrutura TCA recomendada para gerenciamento de tickets:
```swift
// MARK: - State
struct TicketsState: Equatable {
    var allTickets: IdentifiedArrayOf<Ticket> = []
    var myTickets: IdentifiedArrayOf<Ticket> = []
    var isLoading: Bool = false
    var error: String?
    
    // Computed
    var availableTickets: IdentifiedArrayOf<Ticket> {
        allTickets.filter { $0.status == .available }
    }
}

// MARK: - Action
enum TicketsAction: Equatable {
    case loadTickets
    case loadMyTickets
    case ticketsLoaded([Ticket])
    case myTicketsLoaded([Ticket])
    
    case createTicket(Ticket)
    case ticketCreated(Ticket)
    
    case updateTicket(id: String, updates: TicketUpdates)
    case ticketUpdated(Ticket)
    
    case deleteTicket(id: String)
    case ticketDeleted(id: String)
    
    case error(String)
}

// MARK: - Environment
struct TicketsEnvironment {
    var ticketService: TicketService
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

// MARK: - Reducer
let ticketsReducer = Reducer<TicketsState, TicketsAction, TicketsEnvironment> { 
    state, action, environment in
    
    switch action {
    case .deleteTicket(let id):
        // Deletar do estado local IMEDIATAMENTE
        state.allTickets.remove(id: id)
        state.myTickets.remove(id: id)
        
        // Fazer chamada de API em background
        return environment.ticketService
            .deleteTicket(id)
            .receive(on: environment.mainQueue)
            .catchToEffect(TicketsAction.ticketDeleted)
            
    case .ticketDeleted(let id):
        // Confirmar deleção bem-sucedida
        // Invalidar caches relacionados
        // Notificar outras features
        return .none
        
    case .createTicket(let ticket):
        // Adicionar ao estado local OTIMISTICAMENTE
        state.allTickets.append(ticket)
        state.myTickets.append(ticket)
        
        return environment.ticketService
            .createTicket(ticket)
            .receive(on: environment.mainQueue)
            .catchToEffect(TicketsAction.ticketCreated)
        
    // ... outros cases
    }
}
```

**Nota:** Este é um exemplo estrutural. Adapte à arquitetura TCA já existente no projeto.
</tca_architecture>

<requirements>
1. **CENTRALIZAÇÃO DE ESTADO**
   - Criar um único TicketsStore/Reducer como fonte única de verdade
   - Todas as telas devem consumir desse store central via ViewStore
   - Eliminar estados duplicados ou desincronizados
   - Usar `@StateObject` ou `@ObservedObject` apropriadamente

2. **SINCRONIZAÇÃO EM DELEÇÃO**
   - Ao deletar ticket em "Meus Ingressos":
     * Remover do array `myTickets`
     * Remover do array `allTickets`
     * Atualizar contadores (quantidade de ingressos do vendedor)
     * Invalidar cache de perfil do vendedor
     * Notificar outras features através de Effects

3. **SINCRONIZAÇÃO EM CRIAÇÃO**
   - Ao criar novo ticket:
     * Adicionar em `allTickets`
     * Adicionar em `myTickets`
     * Atualizar status do usuário para vendedor (se necessário)
     * Invalidar caches relevantes
     * Aplicar layout correto (resolver espaçamento)

4. **IMPLEMENTAR UPDATE**
   - Permitir edição de tickets existentes
   - Campos editáveis: preço, tipo, status, quantidade
   - Refletir mudanças em todas visualizações
   - Validar permissões (apenas dono pode editar)

5. **CORREÇÃO DE LAYOUT**
   - Identificar causa do espaçamento irregular (padding, spacing, frame)
   - Criar componente `TicketCard` reutilizável com layout fixo
   - Usar `LazyVGrid` ou `LazyVStack` com spacing consistente
   - Exemplo:
```swift
     LazyVStack(spacing: 16) {
         ForEach(tickets) { ticket in
             TicketCard(ticket: ticket)
                 .padding(.horizontal, 16)
         }
     }
```

6. **INVALIDAÇÃO DE CACHE**
   - Sistema implementado anteriormente deve ser integrado
   - Ao modificar tickets, invalidar:
     * Cache da listagem completa
     * Cache de "Meus Ingressos"
     * Cache do perfil do vendedor
     * Cache de tickets por evento

7. **GESTÃO DE RELACIONAMENTOS**
   - Ao deletar ticket, atualizar:
     * Contagem de ingressos disponíveis do evento
     * Contagem de ingressos do vendedor
     * Lista de vendedores do evento (se ficar sem tickets)
   - Manter integridade referencial

8. **FEEDBACK VISUAL**
   - Loading states durante operações CRUD
   - Animações suaves ao adicionar/remover items
   - Toast/Alert de confirmação de sucesso
   - Error states claros
</requirements>

<critical>
1. **FONTE ÚNICA DE VERDADE (CRÍTICO)**
   - NUNCA deve haver múltiplas fontes de estado para tickets
   - TODOS os componentes devem ler do mesmo store TCA
   - Estados locais (@State) só para UI temporária, nunca para dados de domínio
   - Se múltiplos stores existirem, consolidar em um único

2. **DELEÇÃO DEVE SER GLOBAL (CRÍTICO)**
   - Deletar ticket não pode apenas remover da lista local
   - DEVE remover de `allTickets` global
   - DEVE remover de cache
   - DEVE notificar todas features interessadas
   - DEVE atualizar contadores e estatísticas
   - Ticket deletado NÃO PODE aparecer em nenhum lugar da aplicação

3. **ESPAÇAMENTO CONSISTENTE (CRÍTICO)**
   - IDENTIFICAR causa raiz: padding, spacing, frame, ou safe area
   - CORRIGIR usando valores fixos e consistentes
   - TESTAR após criação, edição e deleção
   - USAR componentes reutilizáveis para evitar divergências
   - Conforme imagem anexada, há espaçamento diferente - isso é INACEITÁVEL

4. **ATUALIZAÇÃO OTIMISTA**
   - UI deve atualizar IMEDIATAMENTE (otimistic updates)
   - Não esperar resposta da API para atualizar lista
   - Se API falhar, reverter mudança e mostrar erro
   - Melhor UX: usuário vê mudança instantânea

5. **PREVENÇÃO DE RACE CONDITIONS**
   - Operações CRUD simultâneas podem causar inconsistências
   - Usar `.cancellable(id:)` em Effects quando apropriado
   - Garantir ordem de operações
   - Tratar estados intermediários

6. **VALIDAÇÃO DE DADOS**
   - Ao criar/editar ticket, validar:
     * Preço > 0
     * eventId existe
     * sellerId é o usuário atual
     * Tipo de ticket é válido
     * Datas são coerentes
   - Não permitir estados inválidos
</critical>

<acceptance_criteria>
✓ CRUD completo implementado: Create, Read, Update, Delete funcionam
✓ Deletar ticket em "Meus Ingressos" remove da aplicação inteira
✓ Ticket deletado NÃO aparece em listagem completa
✓ Ticket deletado NÃO aparece em perfil do vendedor
✓ Ticket deletado atualiza contadores corretamente
✓ Criar ticket adiciona em todas listas relevantes imediatamente
✓ Editar ticket reflete mudanças em todas visualizações
✓ Espaçamento entre cards é uniforme e consistente
✓ Layout após inserção é idêntico aos cards existentes (conforme imagem)
✓ Cache é invalidado apropriadamente após operações CRUD
✓ Estado é sincronizado em toda a aplicação
✓ Não há duplicação de estado ou lógica
✓ Operações são otimistas (UI atualiza imediatamente)
✓ Feedback visual claro para todas operações
✓ Error handling robusto em todas operações
✓ Contadores e estatísticas são atualizados automaticamente
✓ Performance mantida (sem lags ao adicionar/remover items)
✓ Animações suaves e naturais
✓ Código segue padrões TCA do projeto
</acceptance_criteria>

<behaviour_details>
1. **FLUXO DE DELEÇÃO CORRETO**
```
   Usuário em "Meus Ingressos"
   → Toca "Deletar" em um ticket
   → Confirmação aparece
   → Usuário confirma
   → UI atualiza IMEDIATAMENTE (otimistic):
     * Ticket removido da lista "Meus Ingressos" com animação
     * Contador de ingressos decrementa
   → Request de DELETE enviada ao backend/local storage
   → Effect dispara TicketsAction.ticketDeleted
   → Reducer remove de TODAS as listas:
     * state.allTickets.remove(id)
     * state.myTickets.remove(id)
   → Cache invalidado
   → Outras features notificadas via Effect
   → Se usuário navegar para listagem completa:
     * Ticket NÃO aparece
   → Se usuário navegar para perfil do vendedor:
     * Ticket NÃO aparece
     * Contador está correto
   → Toast de sucesso: "Ingresso removido com sucesso"
```

2. **FLUXO DE CRIAÇÃO CORRETO**
```
   Usuário em "Adicionar Ingresso"
   → Preenche formulário (evento, tipo, preço, quantidade)
   → Validação em tempo real
   → Toca "Adicionar"
   → Validação final
   → UI atualiza IMEDIATAMENTE:
     * Ticket aparece em "Meus Ingressos"
     * Ticket aparece na listagem completa
     * Contador incrementa
     * Espaçamento é IDÊNTICO aos outros cards
   → Request de POST enviada
   → Se sucesso:
     * Confirmar ID do backend
     * Atualizar ticket com ID real
   → Se falha:
     * Reverter adição
     * Mostrar erro claro
   → Cache invalidado
   → Toast de sucesso: "Ingresso adicionado com sucesso"
```

3. **FLUXO DE EDIÇÃO (NOVO)**
```
   Usuário em "Meus Ingressos"
   → Toca no ticket ou botão "Editar"
   → Sheet/Modal com formulário pré-preenchido
   → Edita campos (preço, tipo, quantidade, status)
   → Toca "Salvar"
   → Validação
   → UI atualiza IMEDIATAMENTE:
     * Ticket atualizado em lista
     * Mudanças visíveis
   → Request de PUT/PATCH enviada
   → Se sucesso: confirmar
   → Se falha: reverter e mostrar erro
   → Cache invalidado
   → Toast: "Ingresso atualizado com sucesso"
```

4. **CORREÇÃO DE LAYOUT**
   - Problema atual: primeiro card após inserção tem espaçamento diferente
   - Solução:
```swift
     // Componente reutilizável
     struct TicketCard: View {
         let ticket: Ticket
         
         var body: some View {
             VStack(alignment: .leading, spacing: 12) {
                 // Conteúdo do card
             }
             .padding(16)
             .background(Color.cardBackground)
             .cornerRadius(12)
             .shadow(radius: 2)
         }
     }
     
     // Uso na lista
     ScrollView {
         LazyVStack(spacing: 16) { // SPACING FIXO
             ForEach(viewStore.myTickets) { ticket in
                 TicketCard(ticket: ticket)
                     .padding(.horizontal, 16) // PADDING CONSISTENTE
             }
         }
         .padding(.vertical, 16)
     }
```
   - Verificar se não há condicionais que aplicam estilos diferentes
   - Garantir que primeiro e último item não têm tratamento especial

5. **SINCRONIZAÇÃO ENTRE FEATURES**
   - Implementar sistema de eventos/notificações:
```swift
     enum GlobalAction {
         case tickets(TicketsAction)
         case profile(ProfileAction)
         case eventDetails(EventDetailsAction)
     }
     
     // No reducer global
     case .tickets(.ticketDeleted(let id)):
         // Notificar outras features
         return .merge(
             .send(.profile(.invalidateCache)),
             .send(.eventDetails(.reloadTickets))
         )
```

6. **CACHE INVALIDATION STRATEGY**
   - Após operação CRUD bem-sucedida:
```swift
     case .ticketCreated, .ticketUpdated, .ticketDeleted:
         return Effect.merge(
             Effect(value: .invalidateTicketsCache),
             Effect(value: .invalidateProfileCache),
             Effect(value: .reloadAllTickets)
         )
```
   - Cache deve ter timestamp e ser invalidado após modificações

7. **TRATAMENTO DE ERROS**
   - Para cada operação CRUD:
```swift
     case .deleteTicket(let id):
         // Salvar estado anterior
         let previousState = state
         
         // Atualizar otimisticamente
         state.allTickets.remove(id: id)
         
         return environment.ticketService
             .deleteTicket(id)
             .catch { error in
                 // Reverter estado
                 Just(.revertState(previousState))
             }
             .eraseToEffect()
```

8. **ANIMAÇÕES SUAVES**
```swift
   // Ao adicionar/remover com animação
   withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
       viewStore.send(.deleteTicket(id: ticket.id))
   }
```

9. **PERFORMANCE**
   - Usar `IdentifiedArrayOf` para operações O(1)
   - Lazy loading em listas grandes
   - Evitar re-renders desnecessários
   - Usar `.equatable()` em Views quando apropriado

10. **DEBUGGING**
    - Adicionar logs em operações críticas:
```swift
      case .ticketDeleted(let id):
          print("🗑️ Ticket deleted: \(id)")
          print("📊 Tickets remaining: \(state.allTickets.count)")
          // ...
```
</behaviour_details>

<constraints>
- **NÃO DEVE** criar múltiplos stores para tickets
- **NÃO DEVE** usar @State para dados de domínio (apenas UI local)
- **NÃO DEVE** fazer requests diretos nas Views
- **NÃO DEVE** ignorar erros ou estados intermediários
- **NÃO DEVE** ter lógica de negócio nas Views (tudo no Reducer)
- **DEVE** seguir padrões TCA rigorosamente
- **DEVE** usar IdentifiedArrayOf para coleções
- **DEVE** usar Environment para dependencies
- **DEVE** manter Views como pure/stateless quanto possível
- **DEVE** aplicar updates otimistas sempre que possível
- **DEVE** reverter mudanças se API falhar
- **DEVE** manter código testável (separação de concerns)
</constraints>

<testing_strategy>
Testar os seguintes cenários:

1. **Criação de Ticket:**
   - ✓ Aparece em "Meus Ingressos"
   - ✓ Aparece em listagem completa
   - ✓ Aparece no perfil do vendedor
   - ✓ Contadores atualizados
   - ✓ Espaçamento correto

2. **Deleção de Ticket:**
   - ✓ Remove de "Meus Ingressos"
   - ✓ Remove de listagem completa
   - ✓ Remove do perfil do vendedor
   - ✓ Contadores atualizados
   - ✓ Não aparece em nenhum lugar

3. **Edição de Ticket:**
   - ✓ Mudanças refletem em todas views
   - ✓ Preço atualizado corretamente
   - ✓ Tipo/status atualizados
   - ✓ Cache invalidado

4. **Sincronização:**
   - ✓ Navegar entre telas mostra dados consistentes
   - ✓ Pull-to-refresh traz dados atualizados
   - ✓ Múltiplas operações CRUD consecutivas funcionam

5. **Layout:**
   - ✓ Espaçamento uniforme entre todos cards
   - ✓ Cards recém-criados idênticos aos existentes
   - ✓ Animações suaves
   - ✓ Responsivo em diferentes tamanhos de tela

6. **Edge Cases:**
   - ✓ Deletar último ticket
   - ✓ Criar ticket quando lista vazia
   - ✓ Operações CRUD em sequência rápida
   - ✓ Erros de rede durante operações
</testing_strategy>

<file_structure>
Arquivos a modificar/criar (adaptar aos nomes do projeto):
```
Ventür/
  Features/
    Tickets/
      TicketsCore.swift          # MODIFICAR: State, Action, Reducer
      TicketsList/
        TicketsListView.swift    # MODIFICAR: usar store global
      MyTickets/
        MyTicketsView.swift      # MODIFICAR: sincronizar deleção
      TicketDetail/
        TicketDetailView.swift   # CRIAR/MODIFICAR: adicionar edição
      Components/
        TicketCard.swift         # MODIFICAR: padronizar layout
    Profile/
      SellerProfile/
        SellerProfileView.swift  # MODIFICAR: reagir a mudanças
  
  Services/
    TicketService.swift          # MODIFICAR: adicionar UPDATE
  
  Models/
    Ticket.swift                 # VERIFICAR: estrutura adequada
    
  AppCore.swift                  # MODIFICAR: integrar tickets store
```
</file_structure>

<passos_sugeridos>
1. **Auditoria de Estado Atual:**
   - Mapear todos os lugares onde tickets são mantidos
   - Identificar duplicação de estado
   - Documentar fluxo de dados atual

2. **Consolidar em Store Único:**
   - Criar/refatorar TicketsCore com State unificado
   - Migrar todas Views para usar esse store
   - Remover estados locais duplicados

3. **Implementar Deleção Global:**
   - Modificar TicketsAction.deleteTicket
   - Reducer deve remover de TODAS as listas
   - Adicionar invalidação de cache
   - Testar que não aparece mais em nenhum lugar

4. **Corrigir Layout:**
   - Identificar causa do espaçamento irregular
   - Padronizar TicketCard
   - Aplicar spacing consistente
   - Testar após operações CRUD

5. **Implementar Update:**
   - Criar UI de edição
   - Adicionar TicketsAction.updateTicket
   - Implementar lógica no Reducer
   - Adicionar validações

6. **Otimizar Performance:**
   - Aplicar updates otimistas
   - Implementar rollback em caso de erro
   - Adicionar animações suaves

7. **Testar Extensivamente:**
   - Todos cenários do <testing_strategy>
   - Verificar edge cases
   - Confirmar sincronização global

8. **Documentar:**
   - Comentar decisões arquiteturais
   - Documentar fluxo de dados
   - Adicionar TODOs se aplicável
</passos_sugeridos>

<output_expectations>
Após implementação, forneça:

1. **Resumo das Mudanças:**
   - Arquivos modificados e por quê
   - Mudanças na arquitetura TCA
   - Como sincronização global foi implementada

2. **Decisões Técnicas:**
   - Abordagem escolhida para store único
   - Como cache é invalidado
   - Estratégia de updates otimistas
   - Causa raiz do problema de espaçamento e como foi corrigido

3. **Melhorias Implementadas:**
   - CRUD completo funcionando
   - Sincronização global de estado
   - Layout consistente
   - Performance otimizada

4. **Pontos de Atenção:**
   - Possíveis edge cases a monitorar
   - Áreas que podem precisar refinamento
   - Sugestões de melhorias futuras

5. **Testes Realizados:**
   - Cenários testados e resultados
   - Confirmação de que ticket deletado não aparece mais
   - Confirmação de layout consistente
</output_expectations>

<nao_deve>
- Não criar lógica de negócio nas Views
- Não usar @State para dados de domínio
- Não fazer requests diretos
- Não ignorar states intermediários (loading, error)
- Não ter múltiplas fontes de verdade
- Não aplicar estilos condicionais que quebrem consistência
- Não fazer mudanças sem testes
- Não deixar cache desincronizado
- Não usar força bruta (ex: recarregar tudo sempre)
- Não ignorar performance e UX
</nao_deve>

<referencias>
- The Composable Architecture: https://github.com/pointfreeco/swift-composable-architecture
- TCA Best Practices: https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/
- SwiftUI Layout: https://developer.apple.com/documentation/swiftui/layout
- IdentifiedArrayOf: https://github.com/pointfreeco/swift-identified-collections
</referencias>