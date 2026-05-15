import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography scale extracted from Stitch design system.
/// All text uses Lexend; the KooraSpot wordmark uses Poppins.
class AppTextStyles {
  AppTextStyles._();

  // ── Headings ─────────────────────────────────────────────
  static TextStyle h1 = GoogleFonts.lexend(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.8,
    color: AppColors.onSurface,
  );

  static TextStyle h2 = GoogleFonts.lexend(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.32,
    color: AppColors.onSurface,
  );

  static TextStyle h3 = GoogleFonts.lexend(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.onSurface,
  );

  static TextStyle h4 = GoogleFonts.lexend(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: AppColors.onSurface,
  );

  // ── Body ─────────────────────────────────────────────────
  static TextStyle bodyLg = GoogleFonts.lexend(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.onSurface,
  );

  static TextStyle bodyMd = GoogleFonts.lexend(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.onSurface,
  );

  static TextStyle bodySm = GoogleFonts.lexend(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.onSurface,
  );

  // ── Labels ───────────────────────────────────────────────
  static TextStyle labelCaps = GoogleFonts.lexend(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 0.96,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle labelSm = GoogleFonts.lexend(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textSecondary,
  );

  // ── Button ───────────────────────────────────────────────
  static TextStyle button = GoogleFonts.lexend(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.32,
  );

  static TextStyle buttonSm = GoogleFonts.lexend(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );

  // ── Wordmark ─────────────────────────────────────────────
  static TextStyle wordmark = GoogleFonts.poppins(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.6,
    color: AppColors.onSurface,
  );

  // ── Nav ──────────────────────────────────────────────────
  static TextStyle navLabel = GoogleFonts.lexend(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );

  // ── Price / Stats ────────────────────────────────────────
  static TextStyle price = GoogleFonts.lexend(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.primary,
  );

  static TextStyle statValue = GoogleFonts.lexend(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.onSurface,
  );
}
