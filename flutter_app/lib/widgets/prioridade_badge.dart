import "package:flutter/material.dart";
import "../models/chamado.dart";
import "../config/app_theme.dart";

class PrioridadeBadge extends StatelessWidget {
  final Prioridade prioridade;
  const PrioridadeBadge({super.key, required this.prioridade});

  Color _cor() {
    switch (prioridade) {
      case Prioridade.baixa:
        return AppColors.statusResolvido;
      case Prioridade.media:
        return AppColors.textSecondary;
      case Prioridade.alta:
        return AppColors.statusEmAndamento;
      case Prioridade.urgente:
        return AppColors.destructive;
    }
  }

  IconData _icone() {
    switch (prioridade) {
      case Prioridade.baixa:
        return Icons.arrow_downward;
      case Prioridade.media:
        return Icons.remove;
      case Prioridade.alta:
        return Icons.arrow_upward;
      case Prioridade.urgente:
        return Icons.priority_high;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cor = _cor();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_icone(), size: 14, color: cor),
        const SizedBox(width: 2),
        Text(
          prioridadeLabel(prioridade),
          style: TextStyle(color: cor, fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ],
    );
  }
}
