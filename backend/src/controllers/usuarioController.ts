import { Request, Response } from "express";
import { prisma } from "../config/prisma";

export async function listarTecnicos(req: Request, res: Response) {
  const tecnicos = await prisma.usuario.findMany({
    where: { role: "TECNICO" },
    select: { id: true, nome: true, email: true },
    orderBy: { nome: "asc" },
  });
  return res.json(tecnicos);
}
