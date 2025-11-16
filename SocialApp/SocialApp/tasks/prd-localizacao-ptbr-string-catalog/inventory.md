# Inventário de Strings de UI (pré-migração)

Fonte: varredura automática por padrões comuns (Text, Button, Label, navigationTitle, alert, TextField/SecureField).

## Resumo por padrão
- Text("…"): muitas ocorrências em múltiplos módulos (ex.: TicketsList, Login, Negotiations, Profile, Commons).
- Button("…"): botões de ação e diálogos (ex.: OK, Cancelar, Tentar Novamente).
- Label("…"): rótulos com ícones (ex.: WhatsApp, Ligar, SMS).
- .navigationTitle("…"): títulos de navegação (ex.: Perfil, Search, Recommended Events).
- .alert("…"): títulos de alertas (ex.: Erro, Negociação Enviada!).
- TextField/SecureField("…"): placeholders (ex.: Enter your email, 0,00, Nome).

## Amostras

### Text("…")
- Projects/Features/Login/Views/WelcomeView.swift: `Text("SocialClub")`, `Text("Trade your tickets easily")`, `Text("Create Account")`
- Projects/Features/TicketsList/Sources/TicketPricingStepView.swift: `Text("Preço")`, `Text("*Campo obrigatório")`
- Projects/Features/Negotiations/Sources/ValidationUploadView.swift: `Text("Envie Provas de Validação")`

### Button("…")
- Projects/Features/Login/Views/AuthenticationView.swift: `Button("OK")`
- Projects/Features/Profile/ProfileView.swift: `Button("Editar Perfil")`, `Button("Salvar")`
- Projects/Features/Events/Sources/Details/EventDetailView.swift: `Button("Tentar Novamente")`

### Label("…")
- Projects/Features/TicketsList/Sources/TicketDetailsStepView.swift: `Label("Recarregar Eventos", systemImage: "arrow.clockwise")`
- Projects/Features/TicketsList/Sources/TicketCard.swift: `Label("Deletar", systemImage: "trash.fill")`
- Projects/Features/Negotiations/Sources/NegotiationDetailsView.swift: `Label("WhatsApp", systemImage: "message.fill")`

### .navigationTitle("…")
- SocialApp/Sources/Commons/FilterSheet.swift: `.navigationTitle("Filter events")`
- Projects/Features/Events/Sources/SearchView.swift: `.navigationTitle("Search")`
- Projects/Features/Events/Sources/RecommendedEventsView.swift: `.navigationTitle("Recommended Events")`

### .alert("…")
- Projects/Features/Login/Views/SignUpView.swift: `.alert("Erro", ...)`
- Projects/Features/Negotiations/Sources/NegotiationRequestView.swift: `.alert("Negociação Enviada!", ...)`

### TextField/SecureField("…")
- Projects/Features/Login/Views/SignUpView.swift: `TextField("Enter your email", ...)`, `SecureField("Enter password", ...)`
- Projects/Features/Login/Views/SignInView.swift: `TextField("Enter your email", ...)`, `SecureField("Enter password", ...)`
- Projects/Features/Events/Sources/SearchView.swift: `TextField("Search...", ...)`

> Observação: Há ocorrências em português e inglês — objetivo é consolidar tudo para pt-BR via `String(localized:)`.





