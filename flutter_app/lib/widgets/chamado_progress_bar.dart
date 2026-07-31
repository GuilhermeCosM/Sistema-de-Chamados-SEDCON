import "package:flutter/material.dart";
import "../models/chamado.dart";
import "../config/app_theme.dart";

/// Stepper horizontal mostrando visualmente o progresso do chamado,
/// da abertura até o fechamento.
class ChamadoProgressBar extends StatelessWidget {
  final StatusChamado status;
  const ChamadoProgressBar({super.key, required this.status});

  static const List<StatusChamado> _etapas = [
    StatusChamado.aberto,
    StatusChamado.emAndamento,
    StatusChamado.aguardandoCliente,
    StatusChamado.resolvido,
    StatusChamado.fechado,
  ];

  String _rotuloCurto(StatusChamado s) {
    switch (s) {
      case StatusChamado.aberto:
        return "Aberto";
      case StatusChamado.emAndamento:
        return "Andamento";
      case StatusChamado.aguardandoCliente:
        return "Aguardando";
      case StatusChamado.resolvido:
        return "Resolvido";
      case StatusChamado.fechado:
        return "Fechado";
    }
  }

  @override
  Widget build(BuildContext context) {
    final indiceAtual = _etapas.indexOf(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: List.generate(_etapas.length * 2 - 1, (i) {
            if (i.isOdd) {
              final indiceEsquerda = i ~/ 2;
              final concluido = indiceEsquerda < indiceAtual;
              return Expanded(
                child: Container(
                  height: 3,
                  color: concluido ? AppColors.primary : AppColors.border,
                ),
              );
            }
            final idx = i ~/ 2;
            return _bolinha(idx, indiceAtual);
          }),
        ),
        const SizedBox(height: 6),
        Row(
          children: _etapas.map((etapa) {
            final atual = etapa == status;
            return Expanded(
              child: Text(
                _rotuloCurto(etapa),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: atual ? FontWeight.bold : FontWeight.normal,
                  color: atual ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _bolinha(int idx, int indiceAtual) {
    final concluido = idx < indiceAtual;
    final atual = idx == indiceAtual;
    final preenchido = concluido || atual;

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: preenchido ? AppColors.primary : Colors.white,
        border: Border.all(color: preenchido ? AppColors.primary : AppColors.border, width: 2),
        boxShadow: atual
            ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 6, spreadRadius: 1)]
            : null,
      ),
      child: concluido
          ? const Icon(Icons.check, size: 13, color: Colors.white)
          : (atual
              ? Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  ),
                )
              : null),
    );
  }
}
