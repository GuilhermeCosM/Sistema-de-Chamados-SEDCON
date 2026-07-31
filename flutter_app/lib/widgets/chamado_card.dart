import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "../models/chamado.dart";
import "../config/app_theme.dart";
import "status_badge.dart";
import "prioridade_badge.dart";

class ChamadoCard extends StatelessWidget {
  final Chamado chamado;
  final VoidCallback onTap;

  const ChamadoCard({super.key, required this.chamado, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final formatador = DateFormat("dd/MM/yyyy HH:mm");

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      chamado.titulo,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PrioridadeBadge(prioridade: chamado.prioridade),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                chamado.descricao,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: chamado.status.index / (StatusChamado.values.length - 1),
                  minHeight: 5,
                  backgroundColor: AppColors.border,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(status: chamado.status),
                  Text(
                    formatador.format(chamado.criadoEm),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
