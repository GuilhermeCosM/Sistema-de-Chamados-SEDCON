import request from "supertest";
import { app } from "../src/app";

type Role = "ADMIN" | "TECNICO" | "CLIENTE";

export async function criarUsuarioEAutenticar(role: Role, sufixo = "1") {
  const email = `${role.toLowerCase()}${sufixo}@teste.com`;

  const resposta = await request(app).post("/auth/registrar").send({
    nome: `Usuario ${role} ${sufixo}`,
    email,
    senha: "123456",
    role,
  });

  return {
    usuario: resposta.body.usuario,
    token: resposta.body.token as string,
  };
}