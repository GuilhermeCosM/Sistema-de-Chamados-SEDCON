# Sistema de Chamados SEDCON

Sistema de chamados técnicos da SEDCON/PROCON-RJ: cadastro, atualização de status, definição de prioridade, atribuição de técnico e histórico de auditoria.

Construído com a stack **Node.js + Flutter**, alinhada à vaga de Desenvolvedor(a) Full Stack Júnior (Node.js + Flutter).

## Screenshots

| Login | Lista de chamados |
|---|---|
| <img src="docs/screenshots/login.png" width="350"/> | <img src="docs/screenshots/lista.png" width="350"/> |

| Detalhe do chamado (status, prioridade, comentários e histórico) | Novo chamado |
|---|---|
| <img src="docs/screenshots/detalhe.png" width="350"/> | <img src="docs/screenshots/novo.png" width="350"/> |

## Stack

- **Back-end**: Node.js, TypeScript, Express, Prisma ORM, PostgreSQL, JWT, Zod
- **Mobile**: Flutter (Dart), Provider, http, flutter_secure_storage

## Estrutura

```
projeto-chamados/
  backend/       # API REST (Node.js + TypeScript + Prisma + PostgreSQL)
  flutter_app/   # App mobile (Flutter) que consome a API
```

## Como rodar o projeto completo

1. **Backend**: siga `backend/README.md` (Docker Compose sobe o PostgreSQL, depois `npm install`, migrations e seed)
2. **Flutter**: siga `flutter_app/README.md` (aponte a URL da API e rode `flutter run`)

## Funcionalidades principais

- Autenticação com JWT e 3 perfis: `ADMIN`, `TECNICO`, `CLIENTE`
- CRUD completo de chamados com filtros e paginação
- Atualização de status (Aberto → Em andamento → Aguardando cliente → Resolvido → Fechado)
- Definição/alteração de prioridade (Baixa, Média, Alta, Urgente)
- Atribuição de técnico responsável
- Comentários por chamado
- **Histórico de auditoria**: toda mudança de status/prioridade/técnico fica registrada com autor e data
- Documentação da API via Swagger (`/docs`)

## Testes automatizados

O backend conta com testes de integração (Jest + Supertest), cobrindo autenticação, permissões por perfil e o fluxo de chamados (criação, atualização de status/prioridade e histórico de auditoria).

Para rodar (com o banco de testes já configurado — veja `backend/README.md`):

```bash
cd backend
npm test
```

## Próximos passos sugeridos (diferenciais de portfólio)

- [x] Testes automatizados no backend (Jest + Supertest)
- [ ] Notificações em tempo real (Socket.io) quando o status de um chamado muda
- [ ] Deploy do backend (Railway/Render) + banco gerenciado, e do app via TestFlight/Play Console interno
- [ ] Tela de dashboard com contagem de chamados por status/prioridade
