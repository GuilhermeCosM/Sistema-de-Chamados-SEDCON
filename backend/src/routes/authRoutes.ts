import { Router } from "express";
import { registrar, login, perfil } from "../controllers/authController";
import { asyncHandler } from "../middlewares/errorHandler";
import { autenticar } from "../middlewares/auth";

const router = Router();

router.post("/registrar", asyncHandler(registrar));
router.post("/login", asyncHandler(login));
router.get("/perfil", autenticar, asyncHandler(perfil));

export default router;
