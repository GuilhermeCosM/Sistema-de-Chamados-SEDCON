import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../config/sedcon_logo.dart";
import "../models/chamado.dart";
import "../providers/auth_provider.dart";
import "../services/api_client.dart";
import "../services/chamado_service.dart";
import "../widgets/chamado_card.dart";
import "chamado_detail_screen.dart";
import "novo_chamado_screen.dart";
import "login_screen.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _chamadoService = ChamadoService(ApiClient());

  late Future<List<Chamado>> _futureChamados;
  StatusChamado? _filtroStatus;
  Prioridade? _filtroPrioridade;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    setState(() {
      _futureChamados = _chamadoService.listar(status: _filtroStatus, prioridade: _filtroPrioridade);
    });
  }

  Future<void> _abrirNovoChamado() async {
    final criado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const NovoChamadoScreen()),
    );
    if (criado == true) _carregar();
  }

  Future<void> _abrirDetalhe(Chamado chamado) async {
    final alterado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ChamadoDetailScreen(chamadoId: chamado.id)),
    );
    if (alterado == true) _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const SedconLogo(size: 32),
            const SizedBox(width: 10),
            const Text("Chamados SEDCON"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Sair",
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!mounted) return;
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (usuario != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Olá, ${usuario.nome} 👋", style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          _buildFiltros(),
          const SizedBox(height: 4),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _carregar(),
              child: FutureBuilder<List<Chamado>>(
                future: _futureChamados,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return _buildErro(snapshot.error.toString());
                  }
                  final chamados = snapshot.data ?? [];
                  if (chamados.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 80),
                        Center(child: Text("Nenhum chamado encontrado")),
                      ],
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: chamados.length,
                    itemBuilder: (context, index) {
                      final chamado = chamados[index];
                      return ChamadoCard(chamado: chamado, onTap: () => _abrirDetalhe(chamado));
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirNovoChamado,
        icon: const Icon(Icons.add),
        label: const Text("Novo chamado"),
      ),
    );
  }

  Widget _buildErro(String mensagem) {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Icon(Icons.error_outline, size: 48, color: Colors.grey.shade500),
        const SizedBox(height: 8),
        Center(child: Text(mensagem, textAlign: TextAlign.center)),
        const SizedBox(height: 16),
        Center(child: OutlinedButton(onPressed: _carregar, child: const Text("Tentar novamente"))),
      ],
    );
  }

  Widget _buildFiltros() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _chipStatus(null, "Todos"),
          ...StatusChamado.values.map((s) => _chipStatus(s, statusLabel(s))),
        ],
      ),
    );
  }

  Widget _chipStatus(StatusChamado? status, String label) {
    final selecionado = _filtroStatus == status;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selecionado,
        onSelected: (_) {
          _filtroStatus = status;
          _carregar();
        },
      ),
    );
  }
}
