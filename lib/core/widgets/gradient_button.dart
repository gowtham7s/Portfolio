import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A gradient-bordered button with primary brand gradient.
class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;
  final double? width;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.outlined = false,
    this.width,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          transform: Matrix4.identity()
            ..scale(_hovering ? 1.03 : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: widget.outlined
                ? null
                : AppTheme.primaryGradient,
            color: widget.outlined ? Colors.transparent : null,
            borderRadius: BorderRadius.circular(12),
            border: widget.outlined
                ? Border.all(
                    color: AppTheme.primary,
                    width: 2,
                  )
                : null,
            boxShadow: _hovering && !widget.outlined
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon,
                    size: 18,
                    color: widget.outlined ? AppTheme.primary : Colors.white),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: widget.outlined ? AppTheme.primary : Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
