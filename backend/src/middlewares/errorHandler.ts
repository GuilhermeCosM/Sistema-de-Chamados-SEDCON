import { Request, Response, NextFunction } from "express";
import { ZodError } from "zod";

export class AppError extends Error {
  statusCode: number;
  constructor(message: string, statusCode = 400) {
    super(message);
    this.statusCode = statusCode;
  }
}

export function errorHandler(
  err: unknown,
  req: Request,
  res: Response,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  next: NextFunction
) {
  if (err instanceof ZodError) {
    return res.status(400).json({
      erro: "Dados inválidos",
      detalhes: err.issues.map((i) => ({ campo: i.path.join("."), mensagem: i.message })),
    });
  }

  if (err instanceof AppError) {
    return res.status(err.statusCode).json({ erro: err.message });
  }

  console.error(err);
  return res.status(500).json({ erro: "Erro interno do servidor" });
}

// Envolve handlers async para que erros caiam automaticamente no errorHandler
export function asyncHandler(
  fn: (req: Request, res: Response, next: NextFunction) => Promise<unknown>
) {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}
