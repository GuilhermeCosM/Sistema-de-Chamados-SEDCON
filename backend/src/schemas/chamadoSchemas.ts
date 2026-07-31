import { z } from "zod";

const statusEnum = z.enum(["ABERTO", "EM_ANDAMENTO", "AGUARDANDO_CLIENTE", "RESOLVIDO", "FECHADO"]);
const prioridadeEnum = z.enum(["BAIXA", "MEDIA", "ALTA", "URGENTE"]);

export const criarChamadoSchema = z.object({
  titulo: z.string().min(3, "Título deve ter ao menos 3 caracteres"),
  descricao: z.string().min(10, "Descrição deve ter ao menos 10 caracteres"),
  categoria: z.string().optional(),
  prioridade: prioridadeEnum.optional(),
});

export const atualizarStatusSchema = z.object({
  status: statusEnum,
});

export const atualizarPrioridadeSchema = z.object({
  prioridade: prioridadeEnum,
});

export const atribuirTecnicoSchema = z.object({
  tecnicoId: z.string().uuid("Id de técnico inválido"),
});

export const criarComentarioSchema = z.object({
  texto: z.string().min(1, "Comentário não pode ser vazio"),
});

export const listarChamadosQuerySchema = z.object({
  status: statusEnum.optional(),
  prioridade: prioridadeEnum.optional(),
  tecnicoId: z.string().uuid().optional(),
  pagina: z.coerce.number().int().min(1).default(1),
  limite: z.coerce.number().int().min(1).max(100).default(20),
});
