import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "providers/auth_provider.dart";
import "config/app_theme.dart";
import "screens/login_screen.dart";
import "screens/home_screen.dart";

void main() {
  runApp(const ChamadosApp());
}

class ChamadosApp extends StatelessWidget {
  const ChamadosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: "Sistema de Chamados SEDCON",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _AuthGate(),
      ),
    );
  }
}

/// Decide qual tela mostrar de acordo com o status de autenticação.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.carregando:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.autenticado:
        return const HomeScreen();
      case AuthStatus.naoAutenticado:
        return const LoginScreen();
    }
  }
}
