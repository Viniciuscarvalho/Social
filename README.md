# 🎫 SocialApp

Uma aplicação iOS moderna para descoberta e compra de tickets para eventos sociais, construída com SwiftUI e The Composable Architecture.

## 📱 Sobre o App

O SocialApp é uma plataforma que conecta usuários a eventos sociais, permitindo:
- **Descoberta de Eventos**: Navegue por diferentes categorias de eventos
- **Lista de Tickets**: Visualize e filtre tickets disponíveis
- **Detalhes de Tickets**: Informações completas sobre cada ticket
- **Perfis de Vendedores**: Conheça os organizadores dos eventos

## 🏗️ Arquitetura

O projeto utiliza uma arquitetura modular baseada no **Tuist** com as seguintes componentes:

- **SharedModels**: Modelos de dados compartilhados e efeitos comuns
- **Events**: Gerenciamento de eventos e categorias
- **TicketsList**: Lista e filtros de tickets
- **TicketDetail**: Detalhes específicos de cada ticket
- **SellerProfile**: Perfis de vendedores/organizadores

### Stack Tecnológica

- **SwiftUI**: Interface do usuário
- **The Composable Architecture (TCA) v1.0+**: Gerenciamento de estado
- **Tuist**: Gerenciamento de projeto modular
- **iOS 16+**: Plataforma mínima suportada

## 🚀 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- **Xcode 15.0+**
- **iOS 16.0+** (para simulação/dispositivo)
- **Tuist** (para gerenciamento de projeto)

## 📦 Instalação

### 1. Clone o repositório

```bash
git clone https://github.com/seu-usuario/SocialApp.git
cd SocialApp
```

### 2. Instale o Tuist

Se você ainda não tem o Tuist instalado:

```bash
# Via curl (recomendado)
curl -Ls https://install.tuist.io | bash

# Ou via Homebrew
brew install tuist/tuist/tuist
```

### 3. Configure o projeto

```bash
# Navegue até a pasta do projeto
cd SocialApp

# Gere o workspace Xcode
tuist generate
```

### 4. Abra o projeto

```bash
# Abra o workspace gerado
open SocialApp.xcworkspace
```

## 🛠️ Desenvolvimento

### Estrutura do Projeto

```
SocialApp/
├── Project.swift                 # Configuração principal do Tuist
├── SharedModels/                # Módulo de modelos compartilhados
│   ├── Project.swift
│   └── Sources/
│       ├── Models.swift         # Modelos de dados
│       ├── MockData.swift       # Dados de teste
├── Projects/
│   └── Features/                # Features modulares (sem Project.swift separados)
│       ├── Events/              # Módulo de eventos
│       │   └── Sources/
│       │       ├── EventsFeature.swift
│       │       ├── EventsView.swift
│       │       └── Components/
│       │           ├── CategoryButton.swift
│       │           ├── EventCard.swift
│       │           └── RecomendedEventCard.swift
│       ├── TicketsList/         # Módulo de lista de tickets
│       │   └── Sources/
│       │       ├── TicketsListFeature.swift
│       │       ├── TicketsListView.swift
│       │       └── TicketCard.swift
│       ├── TicketDetail/        # Módulo de detalhes do ticket
│       │   └── Sources/
│       │       └── TicketDetailFeature.swift
│       └── SellerProfile/       # Módulo de perfil do vendedor
│           └── Sources/
│               └── SellerProfileFeature.swift
└── SocialApp/                   # App principal
    ├── Sources/
    │   ├── SocialApp.swift      # Ponto de entrada da aplicação
    │   ├── SocialAppFeature.swift # Feature principal
    │   ├── SocialAppView.swift  # View principal
    │   ├── ContentView.swift    # View de conteúdo
    │   ├── Dependencies/        # Clientes de dependências
    │   │   ├── EventsClient.swift
    │   │   ├── TicketsClient.swift
    │   │   └── UserClient.swift
    │   ├── Navigation/          # Configuração de navegação
    │   │   └── NavigationClient.swift
    │   └── Services/            # Implementações de serviços
    │       ├── JSONLoader.swift
    ├── Resources/               # Recursos (JSONs, Assets)
    │   ├── Assets.xcassets/
    │   ├── events.json
    │   └── user.json
    └── Tests/                   # Testes unitários
        └── SocialAppTests.swift
```

### Comandos Úteis

```bash
# Gerar o workspace após mudanças
tuist generate

# Limpar cache e regenerar
tuist clean
tuist install
tuist generate

# Executar testes
tuist test

# Verificar dependências
tuist graph
```

### Adicionando uma Nova Feature

1. Crie uma nova pasta em `Projects/Features/[NomeDaFeature]/Sources/`
2. Adicione os arquivos Swift da feature
3. Atualize o `Project.swift` principal incluindo o novo caminho em `sources`
4. Execute `tuist generate`

## 🧪 Testes

```bash
# Executar todos os testes
tuist test

# Executar testes específicos
tuist test --path SocialApp/Tests
```

## 📱 Executando o App

1. Abra `SocialApp.xcworkspace` no Xcode
2. Selecione o target `SocialApp`
3. Escolha um simulador iOS 16.0+ ou dispositivo físico
4. Pressione `Cmd + R` para executar

## 🔧 Configuração de Desenvolvimento

### Variáveis de Ambiente

O projeto não requer variáveis de ambiente especiais. Todos os dados são mockados via arquivos JSON em `SocialApp/Resources/`.

### Dependências Externas

- **Swift Composable Architecture v1.0+**: Framework para gerenciamento de estado
- **SwiftUI**: Framework nativo para UI

## 📊 Features Implementadas

### ✅ SharedModels
- [x] Modelos de dados compartilhados (Event, Ticket, User, Seller)
- [x] Dados mockados para desenvolvimento e testes
- [x] Efeitos compartilhados entre features
- [x] Executor de efeitos centralizado

### ✅ Events
- [x] Modelo de dados para eventos
- [x] Categorias de eventos (CategoryButton)
- [x] Cards de eventos (EventCard, RecommendedEventCard)
- [x] Feature completa com TCA (EventsFeature)
- [x] Interface SwiftUI (EventsView)

### ✅ TicketsList
- [x] Lista de tickets disponíveis
- [x] Cards de tickets (TicketCard)
- [x] Feature completa com TCA (TicketsListFeature)
- [x] Interface SwiftUI (TicketsListView)
- [x] Filtros e ordenação

### ✅ TicketDetail
- [x] Detalhes específicos do ticket
- [x] Feature completa com TCA (TicketDetailFeature)
- [x] Integração com dados do ticket

### ✅ SellerProfile
- [x] Perfil do vendedor
- [x] Feature completa com TCA (SellerProfileFeature)
- [x] Informações do organizador

### ✅ SocialApp (App Principal)
- [x] Configuração principal com TCA (SocialAppFeature)
- [x] Navegação entre features
- [x] Clientes de dependências (EventsClient, TicketsClient, UserClient)
- [x] Serviços de dados (JSONLoader, ServiceImplementations)
- [x] Configuração de navegação (NavigationClient)
- [x] Provider do TCA (TCAProvider)

## 🚧 Roadmap

### Próximas Features
- [ ] Sistema de autenticação
- [ ] Integração com API real
- [ ] Sistema de pagamentos
- [ ] Notificações push
- [ ] Sistema de avaliações

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### Padrões de Código

- Use SwiftUI para todas as interfaces
- Siga os padrões do TCA para gerenciamento de estado
- Mantenha features modulares e independentes
- Escreva testes unitários para novas funcionalidades

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 📞 Suporte

Se você encontrar algum problema ou tiver dúvidas:

1. Verifique as [Issues](../../issues) existentes
2. Crie uma nova issue com detalhes do problema
3. Para dúvidas gerais, use as [Discussions](../../discussions)

## 🙏 Agradecimentos

- [Point-Free](https://pointfree.co) pelo The Composable Architecture
- [Tuist](https://tuist.io) pela ferramenta de gerenciamento de projetos
- Comunidade SwiftUI pela documentação e exemplos

---

**Desenvolvido com ❤️ usando SwiftUI e TCA**
