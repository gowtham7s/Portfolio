import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

/// Generic shimmer loading placeholder.
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
      highlightColor:
          isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Section-level shimmer loading layout
class SectionShimmer extends StatelessWidget {
  const SectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 120, height: 32, borderRadius: 16),
          const SizedBox(height: 16),
          const ShimmerBox(width: 280, height: 20),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: List.generate(
                6,
                (_) => ShimmerBox(
                      width: 280,
                      height: 160,
                      borderRadius: 16,
                    )),
          ),
        ],
      ),
    );
  }
}
