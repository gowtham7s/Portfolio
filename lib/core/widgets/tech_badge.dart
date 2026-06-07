import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A chip/badge for technology tags.
class TechBadge extends StatelessWidget {
  final String label;
  final Color? color;

  const TechBadge({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AppTheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: badgeColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
