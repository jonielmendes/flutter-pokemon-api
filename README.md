# <img width="128" height="128" alt="Image" src="https://github.com/user-attachments/assets/6621b57d-10b2-4e87-9d67-03a1012e7654" /><img width="122" height="122" alt="Image" src="https://github.com/user-attachments/assets/feec9c48-dda2-4707-b7c8-c13b77ad2329" /> PokéDex - Flutter App

Aplicativo móvel desenvolvido em Flutter que consome a [PokéAPI](https://pokeapi.co/) para exibir informações completas sobre Pokémon.

##  Funcionalidades

- **Splash Screen**: Tela de abertura animada com logo
- **Lista Paginada**: Carrega 20 Pokémon por vez com infinite scroll
- **Busca em Tempo Real**: Filtra Pokémon por nome instantaneamente
- **Tela de Detalhes**: Informações completas (tipos, stats, habilidades, evoluções)
- **Tratamento de Erros**: Mensagens amigáveis com botão de retry
- **Tema Claro/Escuro**: Alternância de tema com persistência
- **Animações**: Hero animations e transições suaves

##  Tecnologias

- Flutter SDK
- Provider - Gerenciamento de estado
- HTTP - Requisições à API
- Cached Network Image - Cache de imagens
- Shared Preferences - Persistência de dados

##  Como Executar

Clone o repositório, instale as dependências e execute:

git clone https://github.com/jonielmendes/flutter-pokemon-api.git
cd flutter-pokemon-api
flutter pub get
flutter run

##  Arquitetura

O projeto segue o padrão Provider para gerenciamento de estado. A estrutura é organizada em camadas: UI Layer (telas e widgets), Providers (gerenciamento de estado), Services (comunicação HTTP) e PokéAPI.

O fluxo de dados funciona assim: a UI solicita dados via Provider, o Provider chama o Service, o Service faz requisição HTTP à PokéAPI, retorna dados estruturados, o Provider notifica os listeners e a UI se reconstrói automaticamente.

## 🔧 Funcionalidades Técnicas

**Infinite Scroll**: Detecta quando usuário está próximo do fim e carrega mais automaticamente

**Pull-to-Refresh**: Arraste para baixo recarrega a lista

**Busca em Tempo Real**: Filtra localmente 1000+ Pokémon instantaneamente

**Cache de Imagens**: Armazena imagens localmente para melhor performance

**Tratamento de Erros**: Captura erros de conexão e timeout com opção de retry

**Persistência de Tema**: Salva preferência em SharedPreferences

## 🌐 API Utilizada

PokéAPI v2: https://pokeapi.co/api/v2

Endpoints consumidos:
- GET /pokemon?offset={offset}&limit={limit} - Lista paginada
- GET /pokemon/{id} - Dados básicos
- GET /pokemon-species/{id} - Descrição e extras
- GET /evolution-chain/{id} - Cadeia de evolução

## 📄 Licença

Projeto desenvolvido para fins acadêmicos (Programação para Dispositivos Móveis).

