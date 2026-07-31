import request from "supertest";
import { app } from "../src/app";
import { criarUsuarioEAutenticar } from "./helpers";

describe("Chamados", () => {
  it("permite que um CLIENTE crie um chamado", async () => {
    const { token } = await criarUsuarioEAutenticar("CLIENTE");

    const resposta = await request(app)
      .post("/chamados")
      .set("Authorization", `Bearer ${token}`)
      .send({
        titulo: "Computador não liga",
        descricao: "O computador da sala 3 não liga desde ontem",
      });

    expect(resposta.status).toBe(201);
    expect(resposta.body.titulo).toBe("Computador não liga");
    expect(resposta.body.status).toBe("ABERTO");
  });

  it("bloqueia a criação de chamado sem autenticação", async () => {
    const resposta = await request(app).post("/chamados").send({
      titulo: "Sem token",
      descricao: "Não deveria funcionar",
    });

    expect(resposta.status).toBe(401);
  });

  it("um CLIENTE só vê os próprios chamados, mas ADMIN vê todos", async () => {
    const cliente1 = await criarUsuarioEAutenticar("CLIENTE", "1");
    const cliente2 = await criarUsuarioEAutenticar("CLIENTE", "2");
    const admin = await criarUsuarioEAutenticar("ADMIN");

    await request(app)
      .post("/chamados")
      .set("Authorization", `Bearer ${cliente1.token}`)
      .send({ titulo: "Chamado do cliente 1", descricao: "Descrição válida aqui" });

    await request(app)
      .post("/chamados")
      .set("Authorization", `Bearer ${cliente2.token}`)
      .send({ titulo: "Chamado do cliente 2", descricao: "Descrição válida aqui" });

    const listaCliente1 = await request(app)
      .get("/chamados")
      .set("Authorization", `Bearer ${cliente1.token}`);

    const listaAdmin = await request(app)
      .get("/chamados")
      .set("Authorization", `Bearer ${admin.token}`);

    expect(listaCliente1.body.dados).toHaveLength(1);
    expect(listaAdmin.body.dados).toHaveLength(2);
  });

  it("impede que um CLIENTE altere a prioridade de um chamado", async () => {
    const { token } = await criarUsuarioEAutenticar("CLIENTE");

    const chamado = await request(app)
      .post("/chamados")
      .set("Authorization", `Bearer ${token}`)
      .send({ titulo: "Impressora com defeito", descricao: "Não imprime há 2 dias" });

    const resposta = await request(app)
      .patch(`/chamados/${chamado.body.id}/prioridade`)
      .set("Authorization", `Bearer ${token}`)
      .send({ prioridade: "URGENTE" });

    expect(resposta.status).toBe(403);
  });

  it("permite que um TECNICO altere a prioridade de um chamado", async () => {
    const cliente = await criarUsuarioEAutenticar("CLIENTE");
    const tecnico = await criarUsuarioEAutenticar("TECNICO");

    const chamado = await request(app)
      .post("/chamados")
      .set("Authorization", `Bearer ${cliente.token}`)
      .send({ titulo: "Rede lenta", descricao: "A internet está muito lenta no setor" });

    const resposta = await request(app)
      .patch(`/chamados/${chamado.body.id}/prioridade`)
      .set("Authorization", `Bearer ${tecnico.token}`)
      .send({ prioridade: "ALTA" });

    expect(resposta.status).toBe(200);
    expect(resposta.body.prioridade).toBe("ALTA");
  });

  it("registra histórico ao mudar o status do chamado", async () => {
    const { token } = await criarUsuarioEAutenticar("CLIENTE");

    const chamado = await request(app)
      .post("/chamados")
      .set("Authorization", `Bearer ${token}`)
      .send({ titulo: "Monitor piscando", descricao: "A tela fica piscando sem motivo aparente" });

    await request(app)
      .patch(`/chamados/${chamado.body.id}/status`)
      .set("Authorization", `Bearer ${token}`)
      .send({ status: "EM_ANDAMENTO" });

    const detalhe = await request(app)
      .get(`/chamados/${chamado.body.id}`)
      .set("Authorization", `Bearer ${token}`);

    expect(detalhe.body.status).toBe("EM_ANDAMENTO");
    expect(detalhe.body.historicos).toHaveLength(1);
    expect(detalhe.body.historicos[0].campo).toBe("status");
  });
});