import { Router } from "express";
import {
  criarChamado,
  listarChamados,
  buscarChamadoPorId,
  atualizarStatus,
  atualizarPrioridade,
  atribuirTecnico,
  adicionarComentario,
  excluirChamado,
} from "../controllers/chamadoController";
import { asyncHandler } from "../middlewares/errorHandler";
import { autenticar, autorizar } from "../middlewares/auth";

const router = Router();

router.use(autenticar); // todas as rotas de chamado exigem autenticação

router.post("/", asyncHandler(criarChamado));
router.get("/", asyncHandler(listarChamados));
router.get("/:id", asyncHandler(buscarChamadoPorId));

router.patch("/:id/status", asyncHandler(atualizarStatus));
router.patch("/:id/prioridade", autorizar("ADMIN", "TECNICO"), asyncHandler(atualizarPrioridade));
router.patch("/:id/tecnico", autorizar("ADMIN"), asyncHandler(atribuirTecnico));

router.post("/:id/comentarios", asyncHandler(adicionarComentario));

router.delete("/:id", autorizar("ADMIN"), asyncHandler(excluirChamado));

export default router;
