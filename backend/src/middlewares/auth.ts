import { Request, Response, NextFunction } from "express";
import { verificarToken } from "../utils/jwt";

export function autenticar(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({ erro: "Token não fornecido" });
  }

  const [, token] = authHeader.split(" ");

  try {
    const payload = verificarToken(token);
    req.usuario = payload;
    return next();
  } catch {
    return res.status(401).json({ erro: "Token inválido ou expirado" });
  }
}

// Middleware para restringir rotas a determinados perfis (ex: apenas ADMIN)
export function autorizar(...rolesPermitidas: Array<"ADMIN" | "TECNICO" | "CLIENTE">) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.usuario || !rolesPermitidas.includes(req.usuario.role)) {
      return res.status(403).json({ erro: "Você não tem permissão para esta ação" });
    }
    return next();
  };
}
