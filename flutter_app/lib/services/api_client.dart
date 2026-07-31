import "dart:convert";
import "package:http/http.dart" as http;
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "../config/api_config.dart";

class ApiException implements Exception {
  final String mensagem;
  final int? statusCode;
  ApiException(this.mensagem, [this.statusCode]);

  @override
  String toString() => mensagem;
}

class ApiClient {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = "auth_token";

  Future<void> salvarToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> obterToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> limparToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<Map<String, String>> _headers({bool autenticado = true}) async {
    final headers = {"Content-Type": "application/json"};
    if (autenticado) {
      final token = await obterToken();
      if (token != null) headers["Authorization"] = "Bearer $token";
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse("${ApiConfig.baseUrl}$path").replace(queryParameters: query);
  }

  Future<dynamic> get(String path, {Map<String, String>? query, bool autenticado = true}) async {
    final resposta = await http.get(_uri(path, query), headers: await _headers(autenticado: autenticado));
    return _tratarResposta(resposta);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body, {bool autenticado = true}) async {
    final resposta = await http.post(
      _uri(path),
      headers: await _headers(autenticado: autenticado),
      body: jsonEncode(body),
    );
    return _tratarResposta(resposta);
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final resposta = await http.patch(_uri(path), headers: await _headers(), body: jsonEncode(body));
    return _tratarResposta(resposta);
  }

  Future<void> delete(String path) async {
    final resposta = await http.delete(_uri(path), headers: await _headers());
    _tratarResposta(resposta);
  }

  dynamic _tratarResposta(http.Response resposta) {
    if (resposta.statusCode == 204) return null;

    final corpo = resposta.body.isNotEmpty ? jsonDecode(resposta.body) : null;

    if (resposta.statusCode >= 200 && resposta.statusCode < 300) {
      return corpo;
    }

    final mensagem = corpo is Map && corpo["erro"] != null
        ? corpo["erro"] as String
        : "Erro inesperado (${resposta.statusCode})";

    throw ApiException(mensagem, resposta.statusCode);
  }
}
