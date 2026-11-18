import { Router } from "express";
import { z } from "zod";
import { asyncHandler } from "../middlewares/errorHandler";
import { autenticar } from "../middlewares/auth";
import { executarAgente } from "../agent/agente";

const router = Router();

router.use(autenticar);

const corpoSchema = z.object({
  mensagem: z.string().trim().min(1).max(2000),
  // Conversa anterior (somente texto). O cliente reenvia a cada chamada.
  historico: z
    .array(z.object({ role: z.enum(["user", "assistant"]), content: z.string().max(4000) }))
    .max(10)
    .default([]),
  // Alterações (status, prioridade, técnico, comentário) ficam desligadas por padrão
  permitirAcoes: z.boolean().default(false),
});

router.post(
  "/",
  asyncHandler(async (req, res) => {
    const { mensagem, historico, permitirAcoes } = corpoSchema.parse(req.body);
    const resultado = await executarAgente({ mensagem, historico, permitirAcoes, usuario: req.usuario! });
    return res.json(resultado);
  })
);

export default router;