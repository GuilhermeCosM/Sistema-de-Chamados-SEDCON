import "package:flutter/foundation.dart";
import "../models/usuario.dart";
import "../services/api_client.dart";
import "../services/auth_service.dart";

enum AuthStatus { carregando, autenticado, naoAutenticado }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService(ApiClient());

  AuthStatus status = AuthStatus.carregando;
  Usuario? usuario;
  String? erro;

  AuthProvider() {
    _verificarSessao();
  }

  Future<void> _verificarSessao() async {
    final atual = await _authService.usuarioAtual();
    usuario = atual;
    status = atual != null ? AuthStatus.autenticado : AuthStatus.naoAutenticado;
    notifyListeners();
  }

  Future<bool> login(String email, String senha) async {
    erro = null;
    try {
      usuario = await _authService.login(email, senha);
      status = AuthStatus.autenticado;
      notifyListeners();
      return true;
    } catch (e) {
      erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> registrar(String nome, String email, String senha) async {
    erro = null;
    try {
      usuario = await _authService.registrar(nome, email, senha);
      status = AuthStatus.autenticado;
      notifyListeners();
      return true;
    } catch (e) {
      erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    usuario = null;
    status = AuthStatus.naoAutenticado;
    notifyListeners();
  }
}
