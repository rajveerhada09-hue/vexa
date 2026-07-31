// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

/// Centralized color tokens for Vexa Voice.
/// Dark-mode first. Pure black base. No loud gradients.
abstract final class AppColors {
  // ─── Core surfaces ───────────────────────────────────────────────
  static const Color background = Color(0xFF0B0B0B);
  static const Color surface = Color(0xFF121212);
  static const Color surfaceElevated = Color(0xFF1A1A1A);
  static const Color surfaceGlass = Color(0xFF161616); // base for glass cards

  // ─── Borders & dividers ──────────────────────────────────────────
  static const Color border = Color(0xFF2A2A2A);
  static const Color borderSubtle = Color(0xFF1F1F1F);
  static const Color divider = Color(0xFF222222);

  // ─── Primary (premium indigo – Linear / Stripe inspired) ─────────
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryHover = Color(0xFF818CF8);
  static const Color primaryPressed = Color(0xFF4F46E5);
  static const Color primaryMuted = Color(0xFF312E81);

  // ─── Semantic ────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ─── Text ────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textTertiary = Color(0xFF71717A);
  static const Color textDisabled = Color(0xFF52525B);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Icons ───────────────────────────────────────────────────────
  static const Color iconPrimary = Color(0xFFFFFFFF);
  static const Color iconSecondary = Color(0xFFA1A1AA);
  static const Color iconMuted = Color(0xFF71717A);

  // ─── Inputs ──────────────────────────────────────────────────────
  static const Color inputFill = Color(0xFF161616);
  static const Color inputBorder = Color(0xFF2A2A2A);
  static const Color inputBorderFocused = Color(0xFF6366F1);
  static const Color inputPlaceholder = Color(0xFF71717A);

  // ─── Overlays / glass ────────────────────────────────────────────
  static const Color overlay = Color(0x99000000); // 60% black
  static const Color glassBorder = Color(0x33FFFFFF); // subtle white edge
  static const Color glassHighlight = Color(0x0DFFFFFF);

  // ─── Navigation ──────────────────────────────────────────────────
  static const Color navBarBackground = Color(0xFF0B0B0B);
  static const Color navBarSelected = Color(0xFF6366F1);
  static const Color navBarUnselected = Color(0xFF71717A);

  // ─── Snackbar / toast ────────────────────────────────────────────
  static const Color snackbarBackground = Color(0xFF1A1A1A);
  static const Color snackbarBorder = Color(0xFF2A2A2A);
}