import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../providers/auth_provider.dart";
import "../config/sedcon_logo.dart";
import "home_screen.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _modoRegistro = false;
  bool _carregando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);
    final auth = context.read<AuthProvider>();

    final sucesso = _modoRegistro
        ? await auth.registrar(_nomeController.text.trim(), _emailController.text.trim(), _senhaController.text)
        : await auth.login(_emailController.text.trim(), _senhaController.text);

    if (!mounted) return;
    setState(() => _carregando = false);

    if (sucesso) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else if (auth.erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.erro!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SedconLogo(size: 88),
                  const SizedBox(height: 16),
                  Text(
                    "Sistema de Chamados SEDCON",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _modoRegistro ? "Crie sua conta" : "Entre com suas credenciais",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 32),
                  if (_modoRegistro) ...[
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(labelText: "Nome", prefixIcon: Icon(Icons.person)),
                      validator: (v) => (v == null || v.trim().length < 2) ? "Informe seu nome" : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: "E-mail", prefixIcon: Icon(Icons.email)),
                    validator: (v) => (v == null || !v.contains("@")) ? "E-mail inválido" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _senhaController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Senha", prefixIcon: Icon(Icons.lock)),
                    validator: (v) => (v == null || v.length < 6) ? "Mínimo de 6 caracteres" : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _carregando ? null : _enviar,
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: _carregando
                        ? const SizedBox(
                            height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(_modoRegistro ? "Criar conta" : "Entrar"),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => setState(() => _modoRegistro = !_modoRegistro),
                    child: Text(_modoRegistro ? "Já tenho conta" : "Não tenho conta, quero me registrar"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
