import "package:flutter/material.dart";
import "../models/chamado.dart";
import "../services/api_client.dart";
import "../services/chamado_service.dart";

class NovoChamadoScreen extends StatefulWidget {
  const NovoChamadoScreen({super.key});

  @override
  State<NovoChamadoScreen> createState() => _NovoChamadoScreenState();
}

class _NovoChamadoScreenState extends State<NovoChamadoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _chamadoService = ChamadoService(ApiClient());

  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _categoriaController = TextEditingController();

  Prioridade _prioridade = Prioridade.media;
  bool _salvando = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    try {
      await _chamadoService.criar(
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        categoria: _categoriaController.text.trim(),
        prioridade: _prioridade,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Novo Chamado")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _tituloController,
              decoration: const InputDecoration(labelText: "Título", border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().length < 3) ? "Título muito curto" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(labelText: "Descrição", border: OutlineInputBorder()),
              maxLines: 5,
              validator: (v) => (v == null || v.trim().length < 10) ? "Descreva melhor o problema" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoriaController,
              decoration: const InputDecoration(
                labelText: "Categoria (opcional)",
                hintText: "Ex: Hardware, Software, Rede",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Prioridade>(
              value: _prioridade,
              decoration: const InputDecoration(labelText: "Prioridade", border: OutlineInputBorder()),
              items: Prioridade.values
                  .map((p) => DropdownMenuItem(value: p, child: Text(prioridadeLabel(p))))
                  .toList(),
              onChanged: (valor) => setState(() => _prioridade = valor ?? Prioridade.media),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _salvando ? null : _salvar,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: _salvando
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text("Abrir chamado"),
            ),
          ],
        ),
      ),
    );
  }
}
