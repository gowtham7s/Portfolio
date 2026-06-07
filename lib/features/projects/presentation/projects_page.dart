import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/repositories/portfolio_repository.dart';
import '../../../domain/entities/project_entity.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/section_heading.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/animated_section.dart';
import '../../../core/widgets/tech_badge.dart';
import '../../../core/widgets/shimmer_box.dart';

class ProjectsPage extends ConsumerStatefulWidget {
  final bool embedded;
  const ProjectsPage({super.key, this.embedded = false});

  @override
  ConsumerState<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends ConsumerState<ProjectsPage> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    final content = Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 96 : 24,
        vertical: 80,
      ),
      child: projectsAsync.when(
        loading: () => const SectionShimmer(),
        error: (e, _) => Text('Error: $e'),
        data: (projects) {
          final categories = [
            'All',
            ...{...projects.map((p) => p.category)}
          ];
          final filtered = _filter == 'All'
              ? projects
              : projects.where((p) => p.category == _filter).toList();

          return Column(
            children: [
              const SectionHeading(
                title: 'Projects',
                subtitle: 'Featured Work',
              ),
              const SizedBox(height: 32),
              // Filter chips
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: categories
                    .map((cat) => _FilterChip(
                          label: cat,
                          selected: _filter == cat,
                          onTap: () => setState(() => _filter = cat),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 40),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = constraints.maxWidth > 900 ? 3 : constraints.maxWidth > 600 ? 2 : 1;
                  return Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: filtered
                        .asMap()
                        .entries
                        .map((e) => AnimatedSection(
                              delay: Duration(milliseconds: e.key * 80),
                              child: SizedBox(
                                width: cols > 1
                                    ? (constraints.maxWidth - 24 * (cols - 1)) / cols
                                    : constraints.maxWidth,
                                child: _ProjectCard(project: e.value),
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );

    return widget.embedded ? content : Scaffold(body: SingleChildScrollView(child: content));
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.primaryGradient : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : AppTheme.darkBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppTheme.darkTextMuted,
          ),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final ProjectEntity project;
  const _ProjectCard({required this.project});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = widget.project;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: Matrix4.identity()
          ..translate(0.0, _hovering ? -6.0 : 0.0),
        child: GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary.withOpacity(0.3),
                        AppTheme.secondary.withOpacity(0.2),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.phone_iphone_rounded,
                    size: 64,
                    color: Colors.white54,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category + Featured
                    Row(
                      children: [
                        TechBadge(label: p.category),
                        if (p.featured) ...[
                          const SizedBox(width: 8),
                          TechBadge(
                            label: '⭐ Featured',
                            color: AppTheme.warning,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(p.title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      p.shortDescription,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Achievements
                    ...p.achievements.map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                size: 14, color: AppTheme.success),
                            const SizedBox(width: 6),
                            Expanded(
                                child: Text(a,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(fontSize: 12))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Tech tags
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: p.technologies
                          .take(4)
                          .map((t) => TechBadge(label: t))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    // Action links
                    Row(
                      children: [
                        if (p.githubUrl.isNotEmpty)
                          _ActionLink(
                            icon: Icons.code_rounded,
                            label: 'Code',
                            url: p.githubUrl,
                          ),
                        if (p.appStoreUrl.isNotEmpty)
                          _ActionLink(
                            icon: Icons.apple_rounded,
                            label: 'App Store',
                            url: p.appStoreUrl,
                          ),
                        if (p.playStoreUrl.isNotEmpty)
                          _ActionLink(
                            icon: Icons.android_rounded,
                            label: 'Play Store',
                            url: p.playStoreUrl,
                          ),
                        if (p.liveUrl.isNotEmpty)
                          _ActionLink(
                            icon: Icons.open_in_new_rounded,
                            label: 'Live',
                            url: p.liveUrl,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  const _ActionLink(
      {required this.icon, required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) launchUrl(uri);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppTheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
