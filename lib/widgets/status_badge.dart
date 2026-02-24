import 'package:flutter/material.dart';
import '../core/colors.dart';

/// A status badge widget with theme-aware styling.
class StatusBadge extends StatelessWidget {
  final String status;
  final bool filled;

  const StatusBadge({super.key, required this.status, this.filled = true});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getStatusColor(status);
    final icon = AppColors.getStatusIcon(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? color.withOpacity(0.2) : Colors.transparent,
        border: Border.all(
          color: filled ? color.withOpacity(0.5) : color,
          width: filled ? 0 : 1.5,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            status.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
