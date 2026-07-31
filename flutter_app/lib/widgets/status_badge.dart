import "package:flutter/material.dart";
import "../models/chamado.dart";
import "../config/app_theme.dart";

class StatusBadge extends StatelessWidget {
  final StatusChamado status;
  const StatusBadge({super.key, required this.status});

  Color _cor() {
    switch (status) {
      case StatusChamado.aberto:
        return AppColors.statusAberto;
      case StatusChamado.emAndamento:
        return AppColors.statusEmAndamento;
      case StatusChamado.aguardandoCliente:
        return AppColors.statusAguardando;
      case StatusChamado.resolvido:
        return AppColors.statusResolvido;
      case StatusChamado.fechado:
        return AppColors.statusFechado;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cor = _cor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cor.withOpacity(0.4)),
      ),
      child: Text(
        statusLabel(status),
        style: TextStyle(color: cor, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
