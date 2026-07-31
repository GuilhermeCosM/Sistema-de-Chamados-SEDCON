import "../models/usuario.dart";
import "api_client.dart";

class AuthService {
  final ApiClient _client;
  AuthService(this._client);

  Future<Usuario> login(String email, String senha) async {
    final resposta = await _client.post(
      "/auth/login",
      {"email": email, "senha": senha},
      autenticado: false,
    );

    await _client.salvarToken(resposta["token"] as String);
    return Usuario.fromJson(resposta["usuario"] as Map<String, dynamic>);
  }

  Future<Usuario> registrar(String nome, String email, String senha) async {
    final resposta = await _client.post(
      "/auth/registrar",
      {"nome": nome, "email": email, "senha": senha},
      autenticado: false,
    );

    await _client.salvarToken(resposta["token"] as String);
    return Usuario.fromJson(resposta["usuario"] as Map<String, dynamic>);
  }

  Future<Usuario?> usuarioAtual() async {
    final token = await _client.obterToken();
    if (token == null) return null;

    try {
      final resposta = await _client.get("/auth/perfil");
      return Usuario.fromJson(resposta as Map<String, dynamic>);
    } catch (_) {
      await _client.limparToken();
      return null;
    }
  }

  Future<void> logout() async {
    await _client.limparToken();
  }
}
