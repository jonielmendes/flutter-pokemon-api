#  <p align="center"> PokéDex - Flutter App

<p align="center">
  <img src="https://github.com/user-attachments/assets/7459cda4-7d2f-491c-8e85-c31b6ab0a5ee" alt="Logo" width="128" height="128" />
  <img src="https://github.com/user-attachments/assets/0180f628-a648-4ac7-8550-4a0cf412aba0" alt="Screenshot 1" width="128" height="128" />
  <img src="https://github.com/user-attachments/assets/6621b57d-10b2-4e87-9d67-03a1012e7654" alt="Screenshot 2" width="128" height="128" />
  <img src="https://github.com/user-attachments/assets/feec9c48-dda2-4707-b7c8-c13b77ad2329" alt="Screenshot 3" width="122" height="122" />
</p>

Aplicativo móvel desenvolvido em Flutter que consome a [PokéAPI](https://pokeapi.co/) para exibir informações completas sobre Pokémon.

## Funcionalidades

- **Splash Screen**: Tela de abertura animada com logo
- **Lista Paginada**: Carrega 20 Pokémon por vez com infinite scroll
- **Busca em Tempo Real**: Filtra Pokémon por nome instantaneamente
- **Tela de Detalhes**: Informações completas (tipos, stats, habilidades, evoluções)
- **Tratamento de Erros**: Mensagens amigáveis com botão de retry
- **Tema Claro/Escuro**: Alternância de tema com persistência
- **Animações**: Hero animations e transições suaves

## Tecnologias

- Flutter SDK
- Provider - Gerenciamento de estado
- HTTP - Requisições à API
- Cached Network Image - Cache de imagens
- Shared Preferences - Persistência de dados

## Estrutura do Projeto

```
lib/
├── models/
│   └── pokemon.dart              # Estrutura de dados (PokemonListItem, PokemonDetails, etc)
├── services/
│   └── pokemon_service.dart      # Comunicação com a PokéAPI (requisições HTTP)
├── providers/
│   ├── pokemon_provider.dart     # Gerenciamento de estado da lista e detalhes
│   └── theme_provider.dart       # Gerenciamento de tema claro/escuro
├── screens/
│   ├── splash_screen.dart        # Tela inicial animada
│   ├── home_screen.dart          # Lista principal de Pokémon
│   └── detail_screen.dart        # Detalhes completos do Pokémon
├── widgets/
│   ├── pokemon_card.dart         # Card individual na lista
│   ├── search_bar_widget.dart    # Barra de busca
│   ├── error_widget.dart         # Widget de erro com retry
│   ├── stat_bar.dart             # Barra de estatísticas
│   └── type_badge.dart           # Badge de tipo do Pokémon
└── utils/
    ├── pokemon_colors.dart       # Cores por tipo
    └── string_extensions.dart    # Extensões de String
```

## Como Executar

Clone o repositório, instale as dependências e execute:

```bash
git clone https://github.com/jonielmendes/flutter-pokemon-api.git
cd flutter-pokemon-api
flutter pub get
flutter run
```

## Arquitetura

O projeto segue o padrão Provider para gerenciamento de estado. A estrutura é organizada em camadas: UI Layer (telas e widgets), Providers (gerenciamento de estado), Services (comunicação HTTP) e PokéAPI.

O fluxo de dados funciona assim: a UI solicita dados via Provider, o Provider chama o Service, o Service faz requisição HTTP à PokéAPI, retorna dados estruturados, o Provider notifica os listeners e a UI se reconstrói automaticamente.

## 🔧 Funcionalidades Técnicas

- **Infinite Scroll**: Detecta quando usuário está próximo do fim e carrega mais automaticamente
- **Pull-to-Refresh**: Arraste para baixo recarrega a lista
- **Busca em Tempo Real**: Filtra localmente 1000+ Pokémon instantaneamente
- **Cache de Imagens**: Armazena imagens localmente para melhor performance
- **Tratamento de Erros**: Captura erros de conexão e timeout com opção de retry
- **Persistência de Tema**: Salva preferência em SharedPreferences

## 🌐 API Utilizada

PokéAPI v2: https://pokeapi.co/api/v2

Endpoints consumidos:
- GET /pokemon?offset={offset}&limit={limit} - Lista paginada
- GET /pokemon/{id} - Dados básicos
- GET /pokemon-species/{id} - Descrição e extras
- GET /evolution-chain/{id} - Cadeia de evolução

## 📄 Licença

Projeto desenvolvido para fins acadêmicos (Programação para Dispositivos Móveis).
