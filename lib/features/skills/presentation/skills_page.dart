import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/portfolio_repository.dart';
import '../../../domain/entities/skill_entity.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/section_heading.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/animated_section.dart';
import '../../../core/widgets/shimmer_box.dart';

class SkillsPage extends ConsumerWidget {
  final bool embedded;
  const SkillsPage({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skillsAsync = ref.watch(skillsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    final content = Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 96 : 24,
        vertical: 80,
      ),
      child: skillsAsync.when(
        loading: () => const SectionShimmer(),
        error: (e, _) => Text('Error: $e'),
        data: (categories) => Column(
          children: [
            const SectionHeading(
              title: 'Skills',
              subtitle: 'Technical Expertise',
            ),
            const SizedBox(height: 48),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossCount = constraints.maxWidth > 900 ? 2 : 1;
                return Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: categories
                      .asMap()
                      .entries
                      .map(
                        (e) => AnimatedSection(
                          delay: Duration(milliseconds: e.key * 80),
                          child: SizedBox(
                            width: crossCount == 2
                                ? (constraints.maxWidth - 24) / 2
                                : constraints.maxWidth,
                            child: _SkillCategoryCard(category: e.value),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );

    return embedded ? content : Scaffold(body: SingleChildScrollView(child: content));
  }
}

class _SkillCategoryCard extends StatelessWidget {
  final SkillCategory category;
  const _SkillCategoryCard({required this.category});

  static final _iconMap = <String, IconData>{
    'phone_iphone': Icons.phone_iphone_rounded,
    'architecture': Icons.architecture,
    'tune': Icons.tune_rounded,
    'cloud': Icons.cloud_rounded,
    'build': Icons.build_rounded,
    'security': Icons.security_rounded,
    'people': Icons.people_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = _iconMap[category.icon] ?? Icons.code_rounded;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Text(
                category.name,
                style: theme.textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...category.skills.map((skill) => _SkillBar(skill: skill)),
        ],
      ),
    );
  }
}

class _SkillBar extends StatefulWidget {
  final Skill skill;
  const _SkillBar({required this.skill});

  @override
  State<_SkillBar> createState() => _SkillBarState();
}

class _SkillBarState extends State<_SkillBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = widget.skill.percentage;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.skill.name, style: theme.textTheme.titleMedium),
              Row(
                children: [
                  Text(
                    '${widget.skill.years}y',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppTheme.secondary),
                  ),
                  const SizedBox(width: 8),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (_, __) => Text(
                      '${(pct * _animation.value).round()}%',
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: AppTheme.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (_, __) => LinearProgressIndicator(
                  value: (pct / 100) * _animation.value,
                  backgroundColor: AppTheme.darkBorder,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
