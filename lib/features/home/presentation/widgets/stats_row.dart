import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/profile_entity.dart';

class StatsRow extends StatelessWidget {
  final List<StatItem> stats;
  const StatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 32,
      runSpacing: 20,
      children: stats.map((s) => _StatCard(stat: s)).toList(),
    );
  }
}

class _StatCard extends StatefulWidget {
  final StatItem stat;
  const _StatCard({required this.stat});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: _hovering
              ? AppTheme.primary.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovering
                ? AppTheme.primary.withOpacity(0.3)
                : AppTheme.darkBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (b) => AppTheme.primaryGradient.createShader(b),
              child: Text(
                widget.stat.value,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(widget.stat.label, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
