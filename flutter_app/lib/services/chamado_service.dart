import "../models/chamado.dart";
import "api_client.dart";

class ChamadoService {
  final ApiClient _client;
  ChamadoService(this._client);

  Future<List<Chamado>> listar({StatusChamado? status, Prioridade? prioridade}) async {
    final query = <String, String>{};
    if (status != null) query["status"] = statusToApiString(status);
    if (prioridade != null) query["prioridade"] = prioridadeToApiString(prioridade);

    final resposta = await _client.get("/chamados", query: query);
    final lista = (resposta["dados"] as List).cast<Map<String, dynamic>>();
    return lista.map(Chamado.fromJson).toList();
  }

  Future<Chamado> buscarPorId(String id) async {
    final resposta = await _client.get("/chamados/$id");
    return Chamado.fromJson(resposta as Map<String, dynamic>);
  }

  /// Busca o chamado junto com comentários e histórico já formatados
  /// para exibição direta na tela de detalhe.
  Future<Map<String, dynamic>> buscarDetalheCompleto(String id) async {
    final resposta = await _client.get("/chamados/$id") as Map<String, dynamic>;

    final comentarios = ((resposta["comentarios"] as List?) ?? [])
        .cast<Map<String, dynamic>>()
        .map((c) => {
              "texto": c["texto"],
              "autorNome": (c["autor"] as Map<String, dynamic>)["nome"],
            })
        .toList();

    final historicos = ((resposta["historicos"] as List?) ?? [])
        .cast<Map<String, dynamic>>()
        .map((h) => {
              "campo": h["campo"],
              "valorAntigo": h["valorAntigo"],
              "valorNovo": h["valorNovo"],
              "autorNome": (h["autor"] as Map<String, dynamic>)["nome"],
            })
        .toList();

    return {
      "chamado": Chamado.fromJson(resposta),
      "comentarios": comentarios,
      "historicos": historicos,
    };
  }

  Future<Chamado> criar({
    required String titulo,
    required String descricao,
    String? categoria,
    Prioridade? prioridade,
  }) async {
    final resposta = await _client.post("/chamados", {
      "titulo": titulo,
      "descricao": descricao,
      if (categoria != null && categoria.isNotEmpty) "categoria": categoria,
      if (prioridade != null) "prioridade": prioridadeToApiString(prioridade),
    });
    return Chamado.fromJson(resposta as Map<String, dynamic>);
  }

  Future<Chamado> atualizarStatus(String id, StatusChamado status) async {
    final resposta = await _client.patch("/chamados/$id/status", {
      "status": statusToApiString(status),
    });
    return Chamado.fromJson(resposta as Map<String, dynamic>);
  }

  Future<Chamado> atualizarPrioridade(String id, Prioridade prioridade) async {
    final resposta = await _client.patch("/chamados/$id/prioridade", {
      "prioridade": prioridadeToApiString(prioridade),
    });
    return Chamado.fromJson(resposta as Map<String, dynamic>);
  }

  Future<void> adicionarComentario(String id, String texto) async {
    await _client.post("/chamados/$id/comentarios", {"texto": texto});
  }
}
