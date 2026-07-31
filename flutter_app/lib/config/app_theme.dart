import "package:flutter/material.dart";

/// Paleta de cores baseada no projeto SEDCON/PROCON-RJ
/// (azul institucional #1553B5 + neutros levemente azulados).
class AppColors {
  static const Color primary = Color(0xFF1553B5);
  static const Color primaryDark = Color(0xFF0F3E8A);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFAFAFB);
  static const Color border = Color(0xFFE7E9ED);
  static const Color textPrimary = Color(0xFF23272E);
  static const Color textSecondary = Color(0xFF5C6370);
  static const Color destructive = Color(0xFFC52020);

  // Cores semânticas de status (mantidas por reconhecimento universal:
  // azul = novo, laranja = em progresso, verde = concluído, etc.)
  static const Color statusAberto = Color(0xFF1553B5);
  static const Color statusEmAndamento = Color(0xFFE08A2E);
  static const Color statusAguardando = Color(0xFF8347C6);
  static const Color statusResolvido = Color(0xFF1C9C63);
  static const Color statusFechado = Color(0xFF6B7280);
}

class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      brightness: Brightness.light,
      error: AppColors.destructive,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: const TextStyle(color: AppColors.textPrimary),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textPrimary),
      ),
    );
  }
}
