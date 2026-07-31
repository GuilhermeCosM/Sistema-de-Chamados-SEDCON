import request from "supertest";
import { app } from "../src/app";

describe("Autenticação", () => {
  it("registra um novo usuário com sucesso", async () => {
    const resposta = await request(app).post("/auth/registrar").send({
      nome: "Maria Teste",
      email: "maria@teste.com",
      senha: "123456",
    });

    expect(resposta.status).toBe(201);
    expect(resposta.body.usuario.email).toBe("maria@teste.com");
    expect(resposta.body.usuario.role).toBe("CLIENTE");
    expect(resposta.body.token).toBeDefined();
    expect(resposta.body.usuario.senhaHash).toBeUndefined();
  });

  it("não permite registrar dois usuários com o mesmo e-mail", async () => {
    await request(app).post("/auth/registrar").send({
      nome: "Maria Teste",
      email: "maria@teste.com",
      senha: "123456",
    });

    const segundaTentativa = await request(app).post("/auth/registrar").send({
      nome: "Maria Duplicada",
      email: "maria@teste.com",
      senha: "654321",
    });

    expect(segundaTentativa.status).toBe(409);
  });

  it("rejeita registro com dados inválidos (senha curta)", async () => {
    const resposta = await request(app).post("/auth/registrar").send({
      nome: "Zé",
      email: "ze@teste.com",
      senha: "123",
    });

    expect(resposta.status).toBe(400);
  });

  it("autentica um usuário com credenciais corretas", async () => {
    await request(app).post("/auth/registrar").send({
      nome: "Maria Teste",
      email: "maria@teste.com",
      senha: "123456",
    });

    const login = await request(app).post("/auth/login").send({
      email: "maria@teste.com",
      senha: "123456",
    });

    expect(login.status).toBe(200);
    expect(login.body.token).toBeDefined();
  });

  it("rejeita login com senha errada", async () => {
    await request(app).post("/auth/registrar").send({
      nome: "Maria Teste",
      email: "maria@teste.com",
      senha: "123456",
    });

    const login = await request(app).post("/auth/login").send({
      email: "maria@teste.com",
      senha: "senha-errada",
    });

    expect(login.status).toBe(401);
  });

  it("bloqueia acesso a rota protegida sem token", async () => {
    const resposta = await request(app).get("/auth/perfil");
    expect(resposta.status).toBe(401);
  });
});