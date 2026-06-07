import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Section heading with a gradient underline accent.
class SectionHeading extends StatelessWidget {
  final String title;
  final String? subtitle;
  final CrossAxisAlignment alignment;

  const SectionHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.alignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: alignment,
      children: [
        // Label chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primary.withOpacity(0.15),
                AppTheme.secondary.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primary.withOpacity(0.3),
            ),
          ),
          child: ShaderMask(
            shaderCallback: (bounds) =>
                AppTheme.primaryGradient.createShader(bounds),
            child: Text(
              title.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (subtitle != null) ...[
          Text(
            subtitle!,
            style: theme.textTheme.displaySmall,
            textAlign: alignment == CrossAxisAlignment.center
                ? TextAlign.center
                : TextAlign.start,
          ),
          const SizedBox(height: 12),
        ],
        // Gradient underline
        Container(
          width: 64,
          height: 4,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
