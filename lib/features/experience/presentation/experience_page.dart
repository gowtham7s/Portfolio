import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/portfolio_repository.dart';
import '../../../domain/entities/experience_entity.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/section_heading.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/animated_section.dart';
import '../../../core/widgets/tech_badge.dart';
import '../../../core/widgets/shimmer_box.dart';

class ExperiencePage extends ConsumerWidget {
  final bool embedded;
  const ExperiencePage({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expAsync = ref.watch(experienceProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    final content = Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 96 : 24,
        vertical: 80,
      ),
      child: expAsync.when(
        loading: () => const SectionShimmer(),
        error: (e, _) => Text('Error: $e'),
        data: (experiences) => Column(
          children: [
            const SectionHeading(
              title: 'Experience',
              subtitle: 'Career Journey',
            ),
            const SizedBox(height: 56),
            ...experiences.asMap().entries.map(
              (e) => AnimatedSection(
                delay: Duration(milliseconds: e.key * 100),
                child: _ExperienceCard(
                  exp: e.value,
                  isLast: e.key == experiences.length - 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return embedded
        ? content
        : Scaffold(body: SingleChildScrollView(child: content));
  }
}

class _ExperienceCard extends StatefulWidget {
  final ExperienceEntity exp;
  final bool isLast;
  const _ExperienceCard({required this.exp, required this.isLast});

  @override
  State<_ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<_ExperienceCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exp = widget.exp;
    final color = _parseColor(exp.color);

    // Use Stack so the timeline line can fill height naturally without
    // IntrinsicHeight + Expanded conflicts that cause overflow errors.
    return Stack(
      children: [
        // Continuous vertical timeline line drawn behind the dot and card
        if (!widget.isLast)
          Positioned(
            left: 9, // horizontally centred under the 20 px dot
            top: 24,
            bottom: 0,
            child: Container(width: 2, color: AppTheme.darkBorder),
          ),

        // Main content row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline dot
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8),
                ],
              ),
            ),

            const SizedBox(width: 20),

            // Card — Expanded gives it all remaining horizontal space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ──────────────────────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Company logo
                          if (exp.logo.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minWidth: 40,
                                  maxWidth: 80,
                                  minHeight: 45,
                                  maxHeight: 45,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    exp.logo,
                                    height: 45,
                                    fit: BoxFit.contain,
                                    alignment: Alignment.center,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 45,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.business_rounded,
                                        color: color,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                Text(
                                  exp.role,
                                  style: theme.textTheme.titleLarge,
                                ),
                                if (exp.isCurrent)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.success.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Current',
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: AppTheme.success,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Company · Location — softWraps naturally, no overflow
                      Text(
                        '${exp.company}  ·  ${exp.location}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                        softWrap: true,
                      ),

                      const SizedBox(height: 4),

                      Text(
                        '${exp.startDate} – ${exp.endDate}',
                        style: theme.textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 16),

                      // ── Highlights ──────────────────────────────────────
                      ...exp.highlights
                          .take(_expanded ? exp.highlights.length : 2)
                          .map(
                            (h) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Bullet dot — fixed size, won't overflow
                                  Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.only(
                                      top: 7,
                                      right: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  // Text fills remaining width and wraps
                                  Expanded(
                                    child: Text(
                                      h,
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                      if (exp.highlights.length > 2)
                        TextButton(
                          onPressed: () =>
                              setState(() => _expanded = !_expanded),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            _expanded ? 'Show less ↑' : 'Show more ↓',
                            style: TextStyle(color: color),
                          ),
                        ),

                      // ── Tech badges ─────────────────────────────────────
                      if (exp.technologies.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: exp.technologies
                              .map((t) => TechBadge(label: t, color: color))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppTheme.primary;
    }
  }
}
