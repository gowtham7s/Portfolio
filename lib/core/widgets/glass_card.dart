import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A glass-card widget with blur and border effect.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final double borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 20,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark ? AppTheme.glassLight : AppTheme.glassDark);
    final bColor = borderColor ??
        (isDark ? AppTheme.glassBorderLight : AppTheme.glassBorderDark);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: bColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.06),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
