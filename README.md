# MangaVerse

Plataforma de leitura de mangás com backend Rails, integração com a API do MangaDex e app mobile em React Native (Expo).

---

## Arquitetura

```
projeto-manga/          → API Rails (backend + web)
manga-mobile/           → App mobile Expo (React Native)
```

O Rails serve duas interfaces a partir do mesmo código:

- **Web** — páginas HTML com Hotwire/Turbo para o catálogo e leitor
- **API JSON** (`/api/v1`) — endpoints consumidos pelo app mobile

---

## Funcionalidades

**Web**
- Catálogo de mangás locais com filtro por gênero e busca por título/autor
- Página de detalhe com capa, sinopse, avaliação e lista de capítulos
- Leitor de capítulos com navegação entre páginas e capítulos

**Explore (MangaDex)**
- Mangás em alta, últimos lançamentos em PT-BR e recomendações personalizadas
- Navegação por 18+ gêneros/categorias
- Histórico de leitura que alimenta o sistema de recomendação

**App mobile**
- Tela inicial com hero de destaque, card "Continue lendo" e "Novo hoje"
- Grade de categorias com identidade visual por gênero
- Busca no catálogo local
- Histórico de leitura

---

## Tecnologias

| Camada | Tecnologia |
|---|---|
| Backend | Ruby on Rails 8.1 |
| Banco de dados | PostgreSQL |
| API externa | MangaDex API (mangadex.org) |
| Frontend web | Hotwire · Turbo Frames · Stimulus |
| CSS | Tailwind CSS v4 |
| Armazenamento de arquivos | Active Storage (Google Cloud Storage em produção) |
| App mobile | Expo SDK 55 · React Native 0.85 · React 19 |
| Navegação mobile | Expo Router 4 (file-based) |
| Estado/cache mobile | TanStack Query v5 |
| HTTP mobile | Axios |

---

## Pré-requisitos

**Backend**
- Ruby 3.2+
- PostgreSQL 12+
- Bundler

**Mobile**
- Node.js 18+
- Expo CLI (`npm install -g expo-cli`)
- Expo Go no dispositivo ou emulador Android/iOS

---

## Instalação e execução

### Backend Rails

```bash
cd projeto-manga

# Instalar gems
bundle install

# Criar banco PostgreSQL e carregar schema
rails db:create db:schema:load

# (Opcional) Popular com dados de exemplo
rails db:seed

# Iniciar servidor
rails server
```

Web disponível em `http://localhost:3000`
API disponível em `http://localhost:3000/api/v1`

### App mobile

```bash
cd manga-mobile

npm install --legacy-peer-deps

# Iniciar Metro Bundler
npx expo start
```

Escaneie o QR code com o Expo Go ou pressione `a` (Android) / `i` (iOS).

> **Dispositivo físico Android:** altere `API_BASE` em `services/api.ts` para o IP da sua máquina (ex: `http://192.168.1.x:3000/api/v1`).

---

## Endpoints da API

| Método | Rota | Descrição |
|---|---|---|
| GET | `/api/v1/explore` | Popular, lançamentos, categorias, histórico, recomendações |
| GET | `/api/v1/explore/category` | Mangás por gênero (`?tag_id=&name=`) |
| GET | `/api/v1/mangas` | Catálogo local (`?genre=&query=`) |
| GET | `/api/v1/mangas/:id` | Detalhe + capítulos |
| GET | `/api/v1/mangas/:manga_id/chapters/:id` | Páginas do capítulo |
| GET | `/api/v1/reading_histories` | Histórico de leitura |
| POST | `/api/v1/reading_histories` | Registrar leitura |

Todos os endpoints retornam JSON. CORS habilitado para origens externas.

---

## Estrutura do projeto

```
projeto-manga/
├── app/
│   ├── controllers/
│   │   ├── api/v1/                   # Controllers da API mobile
│   │   │   ├── base_controller.rb
│   │   │   ├── explore_controller.rb
│   │   │   ├── mangas_controller.rb
│   │   │   ├── chapters_controller.rb
│   │   │   └── reading_histories_controller.rb
│   │   ├── explore_controller.rb     # Homepage web
│   │   ├── mangas_controller.rb      # Catálogo web
│   │   └── chapters_controller.rb   # Leitor web
│   ├── models/
│   │   ├── manga.rb
│   │   ├── chapter.rb
│   │   ├── page.rb
│   │   └── reading_history.rb
│   ├── services/
│   │   └── mangadex_service.rb       # Integração MangaDex API
│   └── views/
│       ├── api/v1/                   # Templates JBuilder (JSON)
│       ├── mangas/
│       ├── chapters/
│       └── explore/
├── config/
│   ├── routes.rb
│   ├── database.yml                  # PostgreSQL
│   └── initializers/cors.rb
└── db/
    └── schema.rb

manga-mobile/
├── app/
│   ├── _layout.tsx                   # Root layout + React Query Provider
│   ├── (tabs)/
│   │   ├── index.tsx                 # Home (hero + lançamentos + categorias)
│   │   ├── categories.tsx            # Grade de gêneros
│   │   ├── search.tsx                # Busca no catálogo
│   │   └── history.tsx              # Histórico de leitura
│   ├── manga/[id].tsx               # Detalhe do mangá
│   ├── chapter/[id].tsx             # Leitor de capítulos
│   └── category/[id].tsx            # Mangás por categoria
├── services/
│   └── api.ts                        # Cliente Axios → Rails API
└── constants/
    └── genres.ts                     # Mapeamento gênero → emoji/cores
```

---

## Variáveis de ambiente

| Variável | Descrição | Padrão |
|---|---|---|
| `DB_USERNAME` | Usuário PostgreSQL | `usuario` (peer auth) |
| `DB_PASSWORD` | Senha PostgreSQL | vazio |
| `DATABASE_URL` | URL completa (produção) | — |

---

Feito com Ruby on Rails e React Native.
