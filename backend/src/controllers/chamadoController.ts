import { Request, Response } from "express";
import { Prisma } from "@prisma/client";
import { prisma } from "../config/prisma";
import { AppError } from "../middlewares/errorHandler";
import {
  criarChamadoSchema,
  atualizarStatusSchema,
  atualizarPrioridadeSchema,
  atribuirTecnicoSchema,
  criarComentarioSchema,
  listarChamadosQuerySchema,
} from "../schemas/chamadoSchemas";

const includePadrao = {
  solicitante: { select: { id: true, nome: true, email: true } },
  tecnico: { select: { id: true, nome: true, email: true } },
};

export async function criarChamado(req: Request, res: Response) {
  const dados = criarChamadoSchema.parse(req.body);

  const chamado = await prisma.chamado.create({
    data: {
      ...dados,
      solicitanteId: req.usuario!.sub,
    },
    include: includePadrao,
  });

  return res.status(201).json(chamado);
}

export async function listarChamados(req: Request, res: Response) {
  const { status, prioridade, tecnicoId, pagina, limite } = listarChamadosQuerySchema.parse(req.query);

  // Cliente só vê os próprios chamados; técnico/admin veem tudo (com filtros opcionais)
  const filtroBase =
    req.usuario!.role === "CLIENTE" ? { solicitanteId: req.usuario!.sub } : {};

  const where = {
    ...filtroBase,
    ...(status && { status }),
    ...(prioridade && { prioridade }),
    ...(tecnicoId && { tecnicoId }),
  };

  const [chamados, total] = await Promise.all([
    prisma.chamado.findMany({
      where,
      include: includePadrao,
      orderBy: [{ prioridade: "desc" }, { criadoEm: "desc" }],
      skip: (pagina - 1) * limite,
      take: limite,
    }),
    prisma.chamado.count({ where }),
  ]);

  return res.json({
    dados: chamados,
    paginacao: { pagina, limite, total, totalPaginas: Math.ceil(total / limite) },
  });
}

export async function buscarChamadoPorId(req: Request, res: Response) {
  const chamado = await prisma.chamado.findUnique({
    where: { id: req.params.id },
    include: {
      ...includePadrao,
      comentarios: {
        include: { autor: { select: { id: true, nome: true } } },
        orderBy: { criadoEm: "asc" },
      },
      historicos: {
        include: { autor: { select: { id: true, nome: true } } },
        orderBy: { criadoEm: "desc" },
      },
    },
  });

  if (!chamado) throw new AppError("Chamado não encontrado", 404);

  if (req.usuario!.role === "CLIENTE" && chamado.solicitanteId !== req.usuario!.sub) {
    throw new AppError("Você não tem acesso a este chamado", 403);
  }

  return res.json(chamado);
}

export async function atualizarStatus(req: Request, res: Response) {
  const { status } = atualizarStatusSchema.parse(req.body);
  const chamado = await buscarOu404(req.params.id);

  const atualizado = await prisma.$transaction(async (tx: Prisma.TransactionClient) => {
    const c = await tx.chamado.update({
      where: { id: chamado.id },
      data: { status },
      include: includePadrao,
    });

    await tx.historicoChamado.create({
      data: {
        chamadoId: chamado.id,
        autorId: req.usuario!.sub,
        campo: "status",
        valorAntigo: chamado.status,
        valorNovo: status,
      },
    });

    return c;
  });

  return res.json(atualizado);
}

export async function atualizarPrioridade(req: Request, res: Response) {
  const { prioridade } = atualizarPrioridadeSchema.parse(req.body);
  const chamado = await buscarOu404(req.params.id);

  const atualizado = await prisma.$transaction(async (tx: Prisma.TransactionClient) => {
    const c = await tx.chamado.update({
      where: { id: chamado.id },
      data: { prioridade },
      include: includePadrao,
    });

    await tx.historicoChamado.create({
      data: {
        chamadoId: chamado.id,
        autorId: req.usuario!.sub,
        campo: "prioridade",
        valorAntigo: chamado.prioridade,
        valorNovo: prioridade,
      },
    });

    return c;
  });

  return res.json(atualizado);
}

export async function atribuirTecnico(req: Request, res: Response) {
  const { tecnicoId } = atribuirTecnicoSchema.parse(req.body);
  const chamado = await buscarOu404(req.params.id);

  const tecnico = await prisma.usuario.findUnique({ where: { id: tecnicoId } });
  if (!tecnico || tecnico.role !== "TECNICO") {
    throw new AppError("Usuário informado não é um técnico válido", 400);
  }

  const atualizado = await prisma.$transaction(async (tx: Prisma.TransactionClient) => {
    const c = await tx.chamado.update({
      where: { id: chamado.id },
      data: { tecnicoId },
      include: includePadrao,
    });

    await tx.historicoChamado.create({
      data: {
        chamadoId: chamado.id,
        autorId: req.usuario!.sub,
        campo: "tecnico",
        valorAntigo: chamado.tecnicoId,
        valorNovo: tecnicoId,
      },
    });

    return c;
  });

  return res.json(atualizado);
}

export async function adicionarComentario(req: Request, res: Response) {
  const { texto } = criarComentarioSchema.parse(req.body);
  const chamado = await buscarOu404(req.params.id);

  const comentario = await prisma.comentario.create({
    data: { texto, chamadoId: chamado.id, autorId: req.usuario!.sub },
    include: { autor: { select: { id: true, nome: true } } },
  });

  return res.status(201).json(comentario);
}

export async function excluirChamado(req: Request, res: Response) {
  await buscarOu404(req.params.id);
  await prisma.chamado.delete({ where: { id: req.params.id } });
  return res.status(204).send();
}

async function buscarOu404(id: string) {
  const chamado = await prisma.chamado.findUnique({ where: { id } });
  if (!chamado) throw new AppError("Chamado não encontrado", 404);
  return chamado;
}
