import 'package:flutter/material.dart';

/// Border radius tokens from Stitch design system.
class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double modal = 40;
  static const double full = 9999;

  // Pre-built BorderRadius
  static final BorderRadius smAll = BorderRadius.circular(sm);
  static final BorderRadius mdAll = BorderRadius.circular(md);
  static final BorderRadius lgAll = BorderRadius.circular(lg);
  static final BorderRadius xlAll = BorderRadius.circular(xl);
  static final BorderRadius xxlAll = BorderRadius.circular(xxl);
  static final BorderRadius modalTop = const BorderRadius.vertical(
    top: Radius.circular(modal),
  );
  static final BorderRadius fullAll = BorderRadius.circular(full);
}
