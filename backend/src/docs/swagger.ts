export const swaggerDocument = {
  openapi: "3.0.0",
  info: {
    title: "API de Chamados SEDCON",
    version: "1.0.0",
    description:
      "API REST para cadastro, atualização de status e priorização de chamados técnicos.",
  },
  servers: [{ url: "/" }],
  components: {
    securitySchemes: {
      bearerAuth: { type: "http", scheme: "bearer", bearerFormat: "JWT" },
    },
  },
  security: [{ bearerAuth: [] }],
  paths: {
    "/auth/registrar": {
      post: {
        summary: "Cria um novo usuário",
        security: [],
        requestBody: {
          content: {
            "application/json": {
              example: { nome: "Maria Silva", email: "maria@email.com", senha: "123456", role: "CLIENTE" },
            },
          },
        },
        responses: { "201": { description: "Usuário criado com token JWT" } },
      },
    },
    "/auth/login": {
      post: {
        summary: "Autentica um usuário",
        security: [],
        requestBody: {
          content: {
            "application/json": { example: { email: "maria@email.com", senha: "123456" } },
          },
        },
        responses: { "200": { description: "Login efetuado, retorna token JWT" } },
      },
    },
    "/chamados": {
      get: {
        summary: "Lista chamados (com filtros e paginação)",
        parameters: [
          { name: "status", in: "query", schema: { type: "string" } },
          { name: "prioridade", in: "query", schema: { type: "string" } },
          { name: "pagina", in: "query", schema: { type: "integer" } },
          { name: "limite", in: "query", schema: { type: "integer" } },
        ],
        responses: { "200": { description: "Lista paginada de chamados" } },
      },
      post: {
        summary: "Cria um novo chamado",
        requestBody: {
          content: {
            "application/json": {
              example: { titulo: "Impressora não liga", descricao: "A impressora do setor financeiro não liga desde ontem", prioridade: "ALTA" },
            },
          },
        },
        responses: { "201": { description: "Chamado criado" } },
      },
    },
    "/chamados/{id}": {
      get: {
        summary: "Busca um chamado por id",
        parameters: [{ name: "id", in: "path", required: true, schema: { type: "string" } }],
        responses: { "200": { description: "Detalhes do chamado" } },
      },
    },
    "/chamados/{id}/status": {
      patch: {
        summary: "Atualiza o status de um chamado",
        parameters: [{ name: "id", in: "path", required: true, schema: { type: "string" } }],
        requestBody: { content: { "application/json": { example: { status: "EM_ANDAMENTO" } } } },
        responses: { "200": { description: "Chamado atualizado" } },
      },
    },
    "/chamados/{id}/prioridade": {
      patch: {
        summary: "Atualiza a prioridade de um chamado (ADMIN/TECNICO)",
        parameters: [{ name: "id", in: "path", required: true, schema: { type: "string" } }],
        requestBody: { content: { "application/json": { example: { prioridade: "URGENTE" } } } },
        responses: { "200": { description: "Chamado atualizado" } },
      },
    },
  },
};
