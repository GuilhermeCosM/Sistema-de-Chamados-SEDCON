import { Router } from "express";
import { listarTecnicos } from "../controllers/usuarioController";
import { asyncHandler } from "../middlewares/errorHandler";
import { autenticar, autorizar } from "../middlewares/auth";

const router = Router();

router.use(autenticar);
router.get("/tecnicos", autorizar("ADMIN", "TECNICO"), asyncHandler(listarTecnicos));

export default router;
