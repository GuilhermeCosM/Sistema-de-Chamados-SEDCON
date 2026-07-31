# API de Chamados SEDCON

API REST construída com **Node.js + TypeScript + Express + Prisma + PostgreSQL** para controle de chamados técnicos: cadastro, atualização de status, definição de prioridade, atribuição de técnico e histórico de auditoria.

## Stack

- Node.js + TypeScript
- Express
- Prisma ORM + PostgreSQL
- JWT (autenticação) + bcryptjs (hash de senha)
- Zod (validação de dados)
- Swagger UI (documentação da API)

## Como rodar

### 1. Subir o banco de dados (via Docker)

```bash
docker compose up -d
```

Ou use uma instância PostgreSQL própria, ajustando `DATABASE_URL` no `.env`.

### 2. Configurar variáveis de ambiente

```bash
cp .env.example .env
```

Edite o `.env` com sua string de conexão e um `JWT_SECRET` seguro.

### 3. Instalar dependências e preparar o banco

```bash
npm install
npx prisma migrate dev --name init
npm run prisma:seed
```

O seed cria 3 usuários de teste (senha `123456` para todos):
- `admin@chamados.com` (ADMIN)
- `tecnico@chamados.com` (TECNICO)
- `cliente@chamados.com` (CLIENTE)

### 4. Rodar em modo desenvolvimento

```bash
npm run dev
```

A API sobe em `http://localhost:3333`, com documentação em `http://localhost:3333/docs`.

## Principais endpoints

| Método | Rota | Descrição | Acesso |
|---|---|---|---|
| POST | `/auth/registrar` | Cria usuário | Público |
| POST | `/auth/login` | Autentica e retorna JWT | Público |
| GET | `/auth/perfil` | Dados do usuário logado | Autenticado |
| POST | `/chamados` | Cria chamado | Autenticado |
| GET | `/chamados` | Lista chamados (filtros: status, prioridade, paginação) | Autenticado |
| GET | `/chamados/:id` | Detalhe do chamado (com comentários e histórico) | Autenticado |
| PATCH | `/chamados/:id/status` | Atualiza status | Autenticado |
| PATCH | `/chamados/:id/prioridade` | Atualiza prioridade | ADMIN / TECNICO |
| PATCH | `/chamados/:id/tecnico` | Atribui técnico ao chamado | ADMIN |
| POST | `/chamados/:id/comentarios` | Adiciona comentário | Autenticado |
| DELETE | `/chamados/:id` | Exclui chamado | ADMIN |
| GET | `/usuarios/tecnicos` | Lista técnicos disponíveis | ADMIN / TECNICO |

## Regras de negócio

- Usuários `CLIENTE` só visualizam os próprios chamados; `ADMIN`/`TECNICO` veem todos.
- Toda mudança de status, prioridade ou técnico gera um registro em `HistoricoChamado` (auditoria).
- Autenticação via header `Authorization: Bearer <token>`.
