import type OpenAI from "openai";
import { z } from "zod";
import { Prisma, Prioridade, StatusChamado } from "@prisma/client";
import { prisma } from "../config/prisma";
import { AppError } from "../middlewares/errorHandler";
import { JwtPayload } from "../utils/jwt";

type Role = JwtPayload["role"];
export type DefinicaoFerramenta = OpenAI.Chat.Completions.ChatCompletionFunctionTool;

export interface Ferramenta {
  definicao: DefinicaoFerramenta;
  roles: Role[];
  escrita: boolean;
  executar: (input: unknown, usuario: JwtPayload) => Promise<unknown>;
}

// Monta a ferramenta: valida a entrada com Zod antes de executar
function criar<T extends z.ZodTypeAny>(cfg: {
  nome: string;
  descricao: string;
  propriedades: Record<string, unknown>;
  obrigatorios?: string[];
  roles: Role[];
  escrita?: boolean;
  entrada: T;
  executar: (input: z.infer<T>, usuario: JwtPayload) => Promise<unknown>;
}): Ferramenta {
  return {
    definicao: {
      type: "function",
      function: {
        name: cfg.nome,
        description: cfg.descricao,
        parameters: {
          type: "object",
          properties: cfg.propriedades,
          required: cfg.obrigatorios ?? [],
        },
      },
    },
    roles: cfg.roles,
    escrita: cfg.escrita ?? false,
    executar: (input, usuario) => cfg.executar(cfg.entrada.parse(input), usuario),
  };
}

const STATUS = Object.values(StatusChamado);
const PRIORIDADES = Object.values(Prioridade);
const STATUS_ABERTOS: StatusChamado[] = ["ABERTO", "EM_ANDAMENTO", "AGUARDANDO_CLIENTE"];
const TODOS: Role[] = ["ADMIN", "TECNICO", "CLIENTE"];
const EQUIPE: Role[] = ["ADMIN", "TECNICO"];

const idProp = {
  type: "string",
  description: "Id completo do chamado (uuid) ou os primeiros caracteres dele (mínimo 6)",
};

// CLIENTE só enxerga os próprios chamados (mesma regra da API REST)
function escopo(usuario: JwtPayload): Prisma.ChamadoWhereInput {
  return usuario.role === "CLIENTE" ? { solicitanteId: usuario.sub } : {};
}

// Aceita uuid completo ou prefixo; falha se não achar ou se for ambíguo
async function obterChamado(idOuPrefixo: string, usuario: JwtPayload) {
  const id = idOuPrefixo.trim().toLowerCase();
  const encontrados = await prisma.chamado.findMany({
    where: { ...escopo(usuario), id: id.length === 36 ? id : { startsWith: id } },
    take: 2,
  });
  if (encontrados.length === 0) throw new AppError("Chamado não encontrado", 404);
  if (encontrados.length > 1) throw new AppError("Id ambíguo: informe mais caracteres do id", 400);
  return encontrados[0];
}

// Atualiza o campo e grava o histórico de auditoria na mesma transação (igual aos controllers)
async function alterarCampo(params: {
  chamadoId: string;
  autorId: string;
  campo: "status" | "prioridade" | "tecnico";
  antigo: string | null;
  novo: string;
  data: Prisma.ChamadoUncheckedUpdateInput;
}) {
  const { chamadoId, autorId, campo, antigo, novo, data } = params;
  if (antigo === novo) return { ok: true, mensagem: `O campo ${campo} já estava com esse valor` };

  await prisma.$transaction([
    prisma.chamado.update({ where: { id: chamadoId }, data }),
    prisma.historicoChamado.create({
      data: { chamadoId, autorId, campo, valorAntigo: antigo, valorNovo: novo },
    }),
  ]);
  return { ok: true, chamadoId, campo, de: antigo, para: novo };
}

const cortar = (texto: string, max: number) => (texto.length > max ? texto.slice(0, max) + "…" : texto);

export const ferramentas: Ferramenta[] = [
  // ---------- Leitura ----------
  criar({
    nome: "listar_chamados",
    descricao:
      "Lista chamados, mais urgentes primeiro, com filtros opcionais. Retorna no máximo 10 por chamada. " +
      "Use para responder perguntas como 'quais chamados urgentes estão abertos?'.",
    propriedades: {
      status: { type: "string", enum: STATUS },
      prioridade: { type: "string", enum: PRIORIDADES },
      sem_tecnico: { type: "boolean", description: "true para listar apenas chamados sem técnico atribuído" },
      limite: { type: "integer", minimum: 1, maximum: 10, description: "Padrão: 5" },
    },
    roles: TODOS,
    entrada: z.object({
      status: z.nativeEnum(StatusChamado).optional(),
      prioridade: z.nativeEnum(Prioridade).optional(),
      sem_tecnico: z.boolean().optional(),
      limite: z.number().int().min(1).max(10).default(5),
    }),
    executar: async (i, usuario) => {
      const where: Prisma.ChamadoWhereInput = {
        ...escopo(usuario),
        ...(i.status && { status: i.status }),
        ...(i.prioridade && { prioridade: i.prioridade }),
        ...(i.sem_tecnico && { tecnicoId: null }),
      };
      const [total, chamados] = await Promise.all([
        prisma.chamado.count({ where }),
        prisma.chamado.findMany({
          where,
          orderBy: [{ prioridade: "desc" }, { criadoEm: "desc" }],
          take: i.limite,
          include: { solicitante: { select: { nome: true } }, tecnico: { select: { nome: true } } },
        }),
      ]);
      return {
        total,
        exibindo: chamados.length,
        chamados: chamados.map((c) => ({
          id: c.id,
          titulo: c.titulo,
          descricao: cortar(c.descricao, 200),
          categoria: c.categoria,
          status: c.status,
          prioridade: c.prioridade,
          criadoEm: c.criadoEm,
          solicitante: c.solicitante.nome,
          tecnico: c.tecnico?.nome ?? null,
        })),
      };
    },
  }),

  criar({
    nome: "resumo_chamados",
    descricao:
      "Retorna contagens de chamados por status e por prioridade, e quantos estão sem técnico. " +
      "Use para visão geral, números e totais.",
    propriedades: {},
    roles: TODOS,
    entrada: z.object({}),
    executar: async (_i, usuario) => {
      const where = escopo(usuario);
      const [porStatus, porPrioridade, semTecnico] = await Promise.all([
        prisma.chamado.groupBy({ by: ["status"], where, _count: { _all: true } }),
        prisma.chamado.groupBy({ by: ["prioridade"], where, _count: { _all: true } }),
        prisma.chamado.count({ where: { ...where, tecnicoId: null, status: { in: STATUS_ABERTOS } } }),
      ]);
      return {
        porStatus: Object.fromEntries(porStatus.map((g) => [g.status, g._count._all])),
        porPrioridade: Object.fromEntries(porPrioridade.map((g) => [g.prioridade, g._count._all])),
        abertosSemTecnico: semTecnico,
      };
    },
  }),

  criar({
    nome: "buscar_chamado",
    descricao:
      "Retorna os detalhes de um chamado: descrição completa, últimos 10 comentários e últimas 10 mudanças do histórico.",
    propriedades: { id: idProp },
    obrigatorios: ["id"],
    roles: TODOS,
    entrada: z.object({ id: z.string().min(6) }),
    executar: async (i, usuario) => {
      const base = await obterChamado(i.id, usuario);
      const c = await prisma.chamado.findUniqueOrThrow({
        where: { id: base.id },
        include: {
          solicitante: { select: { nome: true, email: true } },
          tecnico: { select: { nome: true } },
          comentarios: {
            orderBy: { criadoEm: "desc" },
            take: 10,
            include: { autor: { select: { nome: true } } },
          },
          historicos: {
            orderBy: { criadoEm: "desc" },
            take: 10,
            include: { autor: { select: { nome: true } } },
          },
        },
      });
      return {
        id: c.id,
        titulo: c.titulo,
        descricao: c.descricao,
        categoria: c.categoria,
        status: c.status,
        prioridade: c.prioridade,
        criadoEm: c.criadoEm,
        atualizadoEm: c.atualizadoEm,
        solicitante: c.solicitante,
        tecnico: c.tecnico?.nome ?? null,
        comentarios: c.comentarios.reverse().map((m) => ({ autor: m.autor.nome, texto: m.texto, criadoEm: m.criadoEm })),
        historico: c.historicos.map((h) => ({
          campo: h.campo,
          de: h.valorAntigo,
          para: h.valorNovo,
          autor: h.autor.nome,
          criadoEm: h.criadoEm,
        })),
      };
    },
  }),

  criar({
    nome: "listar_tecnicos",
    descricao:
      "Lista os técnicos com o id e a quantidade de chamados em aberto de cada um. " +
      "Use para sugerir ou fazer atribuição de chamados.",
    propriedades: {},
    roles: EQUIPE,
    entrada: z.object({}),
    executar: async () => {
      const tecnicos = await prisma.usuario.findMany({
        where: { role: "TECNICO" },
        select: {
          id: true,
          nome: true,
          _count: { select: { chamadosAtribuidos: { where: { status: { in: STATUS_ABERTOS } } } } },
        },
        orderBy: { nome: "asc" },
      });
      return tecnicos.map((t) => ({ id: t.id, nome: t.nome, chamadosEmAberto: t._count.chamadosAtribuidos }));
    },
  }),

  // ---------- Escrita (só são oferecidas ao modelo quando permitirAcoes = true) ----------
  criar({
    nome: "atualizar_status",
    descricao: "Altera o status de um chamado. Só use quando o usuário pedir explicitamente.",
    propriedades: { id: idProp, status: { type: "string", enum: STATUS } },
    obrigatorios: ["id", "status"],
    roles: EQUIPE,
    escrita: true,
    entrada: z.object({ id: z.string().min(6), status: z.nativeEnum(StatusChamado) }),
    executar: async (i, usuario) => {
      const c = await obterChamado(i.id, usuario);
      return alterarCampo({
        chamadoId: c.id,
        autorId: usuario.sub,
        campo: "status",
        antigo: c.status,
        novo: i.status,
        data: { status: i.status },
      });
    },
  }),

  criar({
    nome: "atualizar_prioridade",
    descricao: "Altera a prioridade de um chamado. Só use quando o usuário pedir explicitamente.",
    propriedades: { id: idProp, prioridade: { type: "string", enum: PRIORIDADES } },
    obrigatorios: ["id", "prioridade"],
    roles: EQUIPE,
    escrita: true,
    entrada: z.object({ id: z.string().min(6), prioridade: z.nativeEnum(Prioridade) }),
    executar: async (i, usuario) => {
      const c = await obterChamado(i.id, usuario);
      return alterarCampo({
        chamadoId: c.id,
        autorId: usuario.sub,
        campo: "prioridade",
        antigo: c.prioridade,
        novo: i.prioridade,
        data: { prioridade: i.prioridade },
      });
    },
  }),

  criar({
    nome: "atribuir_tecnico",
    descricao: "Atribui um chamado a um técnico (use listar_tecnicos para obter o id). Só use quando o usuário pedir explicitamente.",
    propriedades: { id: idProp, tecnicoId: { type: "string", description: "Id (uuid) do técnico" } },
    obrigatorios: ["id", "tecnicoId"],
    roles: ["ADMIN"],
    escrita: true,
    entrada: z.object({ id: z.string().min(6), tecnicoId: z.string().uuid() }),
    executar: async (i, usuario) => {
      const c = await obterChamado(i.id, usuario);
      const tecnico = await prisma.usuario.findUnique({ where: { id: i.tecnicoId } });
      if (!tecnico || tecnico.role !== "TECNICO") {
        throw new AppError("Usuário informado não é um técnico válido", 400);
      }
      return alterarCampo({
        chamadoId: c.id,
        autorId: usuario.sub,
        campo: "tecnico",
        antigo: c.tecnicoId,
        novo: i.tecnicoId,
        data: { tecnicoId: i.tecnicoId },
      });
    },
  }),

  criar({
    nome: "adicionar_comentario",
    descricao: "Adiciona um comentário a um chamado. Só use quando o usuário pedir explicitamente.",
    propriedades: { id: idProp, texto: { type: "string", description: "Texto do comentário" } },
    obrigatorios: ["id", "texto"],
    roles: TODOS,
    escrita: true,
    entrada: z.object({ id: z.string().min(6), texto: z.string().trim().min(1).max(2000) }),
    executar: async (i, usuario) => {
      const c = await obterChamado(i.id, usuario);
      const comentario = await prisma.comentario.create({
        data: { texto: i.texto, chamadoId: c.id, autorId: usuario.sub },
      });
      return { ok: true, comentarioId: comentario.id, chamadoId: c.id };
    },
  }),
];

const porNome = new Map(ferramentas.map((f) => [f.definicao.function.name, f]));

// O modelo só enxerga as ferramentas que este usuário pode usar
export function ferramentasPara(role: Role, permitirAcoes: boolean): DefinicaoFerramenta[] {
  return ferramentas
    .filter((f) => f.roles.includes(role) && (permitirAcoes || !f.escrita))
    .map((f) => f.definicao);
}

export function buscarFerramenta(nome: string): Ferramenta | undefined {
  return porNome.get(nome);
}