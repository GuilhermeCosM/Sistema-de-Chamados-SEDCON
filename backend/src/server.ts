import "dotenv/config";
import { app } from "./app";

const PORT = process.env.PORT || 3333;

app.listen(PORT, () => {
  console.log(`🚀 API de Chamados rodando em http://localhost:${PORT}`);
  console.log(`📄 Documentação Swagger em http://localhost:${PORT}/docs`);
});
