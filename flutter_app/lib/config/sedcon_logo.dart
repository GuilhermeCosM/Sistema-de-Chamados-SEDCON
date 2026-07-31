import "package:flutter/material.dart";
import "app_theme.dart";

/// Exibe a logo da SEDCON dentro de um selo azul, já que a imagem original
/// é branca/translúcida (feita para fundos escuros/coloridos).
class SedconLogo extends StatelessWidget {
  final double size;
  const SedconLogo({super.key, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.14),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Image.asset("assets/images/sedcon_logo.png", fit: BoxFit.contain),
    );
  }
}
