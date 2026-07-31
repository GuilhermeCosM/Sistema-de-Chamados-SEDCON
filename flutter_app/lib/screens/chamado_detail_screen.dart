import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:provider/provider.dart";
import "../models/chamado.dart";
import "../models/usuario.dart";
import "../providers/auth_provider.dart";
import "../services/api_client.dart";
import "../services/chamado_service.dart";
import "../widgets/status_badge.dart";
import "../widgets/prioridade_badge.dart";
import "../widgets/chamado_progress_bar.dart";

class ChamadoDetailScreen extends StatefulWidget {
  final String chamadoId;
  const ChamadoDetailScreen({super.key, required this.chamadoId});

  @override
  State<ChamadoDetailScreen> createState() => _ChamadoDetailScreenState();
}

class _ChamadoDetailScreenState extends State<ChamadoDetailScreen> {
  final _chamadoService = ChamadoService(ApiClient());
  final _comentarioController = TextEditingController();

  late Future<Map<String, dynamic>> _futureDetalhe;
  bool _alterouAlgo = false;
  bool _enviandoComentario = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    setState(() {
      _futureDetalhe = _chamadoService.buscarDetalheCompleto(widget.chamadoId);
    });
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _mudarStatus(StatusChamado novo) async {
    try {
      await _chamadoService.atualizarStatus(widget.chamadoId, novo);
      _alterouAlgo = true;
      _carregar();
    } catch (e) {
      _mostrarErro(e);
    }
  }

  Future<void> _mudarPrioridade(Prioridade nova) async {
    try {
      await _chamadoService.atualizarPrioridade(widget.chamadoId, nova);
      _alterouAlgo = true;
      _carregar();
    } catch (e) {
      _mostrarErro(e);
    }
  }

  Future<void> _enviarComentario() async {
    final texto = _comentarioController.text.trim();
    if (texto.isEmpty) return;

    setState(() => _enviandoComentario = true);
    try {
      await _chamadoService.adicionarComentario(widget.chamadoId, texto);
      _comentarioController.clear();
      _carregar();
    } catch (e) {
      _mostrarErro(e);
    } finally {
      if (mounted) setState(() => _enviandoComentario = false);
    }
  }

  void _mostrarErro(Object e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;
    final podeGerenciar = usuario != null && usuario.role != Role.cliente;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.of(context).pop(_alterouAlgo);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Detalhe do Chamado")),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _futureDetalhe,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final chamado = snapshot.data!["chamado"] as Chamado;
            final comentarios = snapshot.data!["comentarios"] as List<Map<String, dynamic>>;
            final historicos = snapshot.data!["historicos"] as List<Map<String, dynamic>>;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(chamado.titulo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusBadge(status: chamado.status),
                    PrioridadeBadge(prioridade: chamado.prioridade),
                    if (chamado.categoria != null && chamado.categoria!.isNotEmpty)
                      Chip(label: Text(chamado.categoria!)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(chamado.descricao, style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 20),
                ChamadoProgressBar(status: chamado.status),
                const Divider(height: 32),
                _linhaInfo("Solicitante", chamado.solicitante.nome),
                _linhaInfo("Técnico responsável", chamado.tecnico?.nome ?? "Não atribuído"),
                _linhaInfo("Aberto em", DateFormat("dd/MM/yyyy HH:mm").format(chamado.criadoEm)),
                if (podeGerenciar) ...[
                  const Divider(height: 32),
                  Text("Atualizar status", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: StatusChamado.values.map((s) {
                      return ChoiceChip(
                        label: Text(statusLabel(s)),
                        selected: chamado.status == s,
                        onSelected: (_) => _mudarStatus(s),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text("Atualizar prioridade", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: Prioridade.values.map((p) {
                      return ChoiceChip(
                        label: Text(prioridadeLabel(p)),
                        selected: chamado.prioridade == p,
                        onSelected: (_) => _mudarPrioridade(p),
                      );
                    }).toList(),
                  ),
                ],
                const Divider(height: 32),
                Text("Comentários", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (comentarios.isEmpty)
                  Text("Nenhum comentário ainda", style: TextStyle(color: Colors.grey.shade600)),
                ...comentarios.map((c) => _cartaoComentario(c)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _comentarioController,
                        decoration: const InputDecoration(
                          hintText: "Escreva um comentário...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _enviandoComentario ? null : _enviarComentario,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Text("Histórico", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (historicos.isEmpty)
                  Text("Sem alterações registradas", style: TextStyle(color: Colors.grey.shade600)),
                ...historicos.map((h) => _linhaHistorico(h)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _linhaInfo(String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 150, child: Text(rotulo, style: TextStyle(color: Colors.grey.shade600))),
          Expanded(child: Text(valor, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _cartaoComentario(Map<String, dynamic> c) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c["autorNome"] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(c["texto"] as String),
          ],
        ),
      ),
    );
  }

  Widget _linhaHistorico(Map<String, dynamic> h) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        "• ${h["autorNome"]} alterou ${h["campo"]}: ${h["valorAntigo"] ?? "—"} → ${h["valorNovo"]}",
        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
      ),
    );
  }
}
