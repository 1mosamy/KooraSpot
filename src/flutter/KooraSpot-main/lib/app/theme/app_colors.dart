import 'package:flutter/material.dart';

/// Centralized color tokens extracted from Stitch design system.
class AppColors {
  AppColors._();

  // ── Primary ──────────────────────────────────────────────
  static const Color primary = Color(0xFF016D47);
  static const Color primaryDark = Color(0xFF005234);
  static const Color primaryLight = Color(0xFF81D8A9);
  static const Color primaryContainer = Color(0xFF016D47);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryShadow = Color(0x63016D47); // 39% opacity

  // ── Secondary / Accent ───────────────────────────────────
  static const Color secondary = Color(0xFF57615B);
  static const Color navy = Color(0xFF1A237E);

  // ── Background ───────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF6F6F8);
  static const Color backgroundLightAlt = Color(0xFFF9F9FC);
  static const Color backgroundDark = Color(0xFF121320);
  static const Color backgroundDarkAlt = Color(0xFF0F2317);

  // ── Surface ──────────────────────────────────────────────
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFEEEEF0);
  static const Color surfaceContainerLow = Color(0xFFF3F3F6);
  static const Color surfaceContainerHigh = Color(0xFFE8E8EA);

  // ── Text / On-Surface ────────────────────────────────────
  static const Color onSurface = Color(0xFF1A1C1E);
  static const Color onSurfaceVariant = Color(0xFF3F4942);
  static const Color textSecondary = Color(0xFF64748B); // slate-500
  static const Color textTertiary = Color(0xFF94A3B8); // slate-400
  static const Color textHint = Color(0xFF94A3B8);

  // ── Outline / Border ─────────────────────────────────────
  static const Color outline = Color(0xFF6F7A72);
  static const Color outlineVariant = Color(0xFFBEC9C0);
  static const Color border = Color(0xFFF1F5F9); // slate-100
  static const Color borderDark = Color(0xFF334155); // slate-700
  static const Color inputBorder = Color(0xFFE2E8F0); // slate-200

  // ── Error ────────────────────────────────────────────────
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);

  // ── Status ───────────────────────────────────────────────
  static const Color success = Color(0xFF016D47);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);

  // ── Slot States ──────────────────────────────────────────
  static const Color slotAvailable = Color(0xFFFFFFFF);
  static const Color slotAvailableBorder = Color(0x4D10B981); // emerald-500/30
  static const Color slotSelected = Color(0xFF016D47);
  static const Color slotBooked = Color(0xFFF1F5F9); // gray-100
  static const Color slotBookedText = Color(0xFF9CA3AF); // gray-400

  // ── Card ─────────────────────────────────────────────────
  static const Color cardShadow = Color(0x0A000000); // black/4%
  static const Color cardBorder = Color(0xFFF1F5F9);

  // ── Misc ─────────────────────────────────────────────────
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color scrim = Color(0x80000000);
}
