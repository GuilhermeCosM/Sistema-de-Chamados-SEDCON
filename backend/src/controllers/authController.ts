import { Request, Response } from "express";
import bcrypt from "bcryptjs";
import { prisma } from "../config/prisma";
import { gerarToken } from "../utils/jwt";
import { registrarSchema, loginSchema } from "../schemas/authSchemas";
import { AppError } from "../middlewares/errorHandler";

export async function registrar(req: Request, res: Response) {
  const { nome, email, senha, role } = registrarSchema.parse(req.body);

  const usuarioExistente = await prisma.usuario.findUnique({ where: { email } });
  if (usuarioExistente) {
    throw new AppError("Já existe um usuário com este e-mail", 409);
  }

  const senhaHash = await bcrypt.hash(senha, 10);

  const usuario = await prisma.usuario.create({
    data: { nome, email, senhaHash, role: role ?? "CLIENTE" },
    select: { id: true, nome: true, email: true, role: true, criadoEm: true },
  });

  const token = gerarToken({ sub: usuario.id, role: usuario.role });

  return res.status(201).json({ usuario, token });
}

export async function login(req: Request, res: Response) {
  const { email, senha } = loginSchema.parse(req.body);

  const usuario = await prisma.usuario.findUnique({ where: { email } });
  if (!usuario) {
    throw new AppError("Credenciais inválidas", 401);
  }

  const senhaValida = await bcrypt.compare(senha, usuario.senhaHash);
  if (!senhaValida) {
    throw new AppError("Credenciais inválidas", 401);
  }

  const token = gerarToken({ sub: usuario.id, role: usuario.role });

  return res.json({
    usuario: { id: usuario.id, nome: usuario.nome, email: usuario.email, role: usuario.role },
    token,
  });
}

export async function perfil(req: Request, res: Response) {
  const usuario = await prisma.usuario.findUnique({
    where: { id: req.usuario!.sub },
    select: { id: true, nome: true, email: true, role: true, criadoEm: true },
  });

  if (!usuario) throw new AppError("Usuário não encontrado", 404);

  return res.json(usuario);
}
