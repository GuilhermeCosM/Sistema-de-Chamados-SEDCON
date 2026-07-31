import express from "express";
import cors from "cors";
import swaggerUi from "swagger-ui-express";
import authRoutes from "./routes/authRoutes";
import chamadoRoutes from "./routes/chamadoRoutes";
import usuarioRoutes from "./routes/usuarioRoutes";
import { errorHandler } from "./middlewares/errorHandler";
import { swaggerDocument } from "./docs/swagger";

export const app = express();

app.use(cors());
app.use(express.json());

app.get("/health", (_req, res) => res.json({ status: "ok" }));

app.use("/docs", swaggerUi.serve, swaggerUi.setup(swaggerDocument));

app.use("/auth", authRoutes);
app.use("/chamados", chamadoRoutes);
app.use("/usuarios", usuarioRoutes);

app.use(errorHandler);
