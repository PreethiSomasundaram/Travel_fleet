import 'package:flutter/material.dart';

/// Utility class for color gradients and theme-aware color management.
class AppColors {
  AppColors._();

  // ── Light Mode Gradients ──────────────────────────────────────────────────
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [Color(0xFF0066CC), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get successGradient => const LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get warningGradient => const LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get errorGradient => const LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Status Colors ─────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ── Utility Methods ───────────────────────────────────────────────────────
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'active':
      case 'paid':
      case 'approved':
        return success;
      case 'pending':
      case 'in_progress':
        return warning;
      case 'cancelled':
      case 'rejected':
      case 'failed':
        return error;
      default:
        return info;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
        return Icons.check_circle;
      case 'active':
      case 'approved':
        return Icons.verified;
      case 'pending':
      case 'in_progress':
        return Icons.schedule;
      case 'cancelled':
      case 'rejected':
      case 'failed':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}
