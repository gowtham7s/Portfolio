import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/github_settings_provider.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../data/repositories/portfolio_repository.dart';
import '../widgets/cms_tab_scaffold.dart';
import '../widgets/cms_state_mixin.dart';
import 'admin_content_tabs.dart';

// ─── Dashboard ────────────────────────────────────────────────────────────────
class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});
  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  int _selectedIndex = 0;

  static const _sections = [
    ('Overview', Icons.dashboard_rounded),
    ('Profile', Icons.person_rounded),
    ('Skills', Icons.code_rounded),
    ('Experience', Icons.work_rounded),
    ('Projects', Icons.phone_iphone_rounded),
    ('Blog', Icons.article_rounded),
    ('Certifications', Icons.verified_rounded),
    ('Testimonials', Icons.format_quote_rounded),
    ('Settings', Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkSurface,
        elevation: 0,
        leading: isDesktop
            ? null
            : Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
        title: ShaderMask(
          shaderCallback: (b) => AppTheme.primaryGradient.createShader(b),
          child: Text(
            'Admin Dashboard',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: const Text('View Site'),
            onPressed: () => context.go('/'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/admin/login');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: isDesktop
          ? null
          : _AdminSidebar(
              sections: _sections,
              selectedIndex: _selectedIndex,
              onSelect: (i) {
                setState(() => _selectedIndex = i);
                Navigator.pop(context);
              },
            ),
      body: isDesktop
          ? Row(
              children: [
                _AdminSidebar(
                  sections: _sections,
                  selectedIndex: _selectedIndex,
                  onSelect: (i) => setState(() => _selectedIndex = i),
                  inline: true,
                ),
                Expanded(
                  child: _AdminContent(
                    index: _selectedIndex,
                    onNavigate: (i) => setState(() => _selectedIndex = i),
                  ),
                ),
              ],
            )
          : _AdminContent(
              index: _selectedIndex,
              onNavigate: (i) => setState(() => _selectedIndex = i),
            ),
    );
  }
}

// ─── Sidebar ──────────────────────────────────────────────────────────────────
class _AdminSidebar extends StatelessWidget {
  final List<(String, IconData)> sections;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool inline;

  const _AdminSidebar({
    required this.sections,
    required this.selectedIndex,
    required this.onSelect,
    this.inline = false,
  });

  @override
  Widget build(BuildContext context) {
    final sidebar = Container(
      width: 220,
      color: AppTheme.darkSurface,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: sections.length,
        itemBuilder: (context, i) {
          final (label, icon) = sections[i];
          final isSelected = i == selectedIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: isSelected ? Colors.white : AppTheme.darkTextMuted,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.darkTextMuted,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    return inline ? sidebar : Drawer(child: SafeArea(child: sidebar));
  }
}

// ─── Content Router ───────────────────────────────────────────────────────────
class _AdminContent extends ConsumerWidget {
  final int index;
  final ValueChanged<int> onNavigate;
  const _AdminContent({required this.index, required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (index) {
      0 => _OverviewTab(onNavigate: onNavigate),
      1 => const ProfileAdminTab(),
      2 => const SkillsAdminTab(),
      3 => const ExperienceAdminTab(),
      4 => const ProjectsAdminTab(),
      5 => const _BlogAdminTab(),
      6 => const CertificationsAdminTab(),
      7 => const _TestimonialsTab(),
      8 => const _SettingsTab(),
      _ => _OverviewTab(onNavigate: onNavigate),
    };
  }
}

// ─── Overview Tab ─────────────────────────────────────────────────────────────
class _OverviewTab extends ConsumerWidget {
  final ValueChanged<int> onNavigate;
  const _OverviewTab({required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blogsAsync = ref.watch(blogsProvider);
    final projectsAsync = ref.watch(projectsProvider);
    final certAsync = ref.watch(certificationsProvider);
    final expAsync = ref.watch(experienceProvider);
    final isConfigured = ref.watch(githubSettingsProvider).isConfigured;

    final visitorData = [120, 85, 210, 165, 300, 245, 189];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Overview',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Manage your portfolio content',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.darkTextMuted),
          ),

          if (!isConfigured) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.warning.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_rounded,
                    color: AppTheme.warning,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'GitHub CMS not connected. Go to Settings to enable live editing.',
                      style: TextStyle(color: AppTheme.warning, fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: () => onNavigate(8),
                    child: const Text(
                      'Setup Now',
                      style: TextStyle(color: AppTheme.warning),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 28),
          Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _QuickActionButton(
                icon: Icons.add_rounded,
                label: 'New Blog Post',
                color: AppTheme.primary,
                onTap: () => onNavigate(5),
              ),
              _QuickActionButton(
                icon: Icons.add_rounded,
                label: 'New Project',
                color: AppTheme.secondary,
                onTap: () => onNavigate(4),
              ),
              _QuickActionButton(
                icon: Icons.person_rounded,
                label: 'Edit Profile',
                color: AppTheme.accent,
                onTap: () => onNavigate(1),
              ),
              _QuickActionButton(
                icon: Icons.verified_rounded,
                label: 'Add Certification',
                color: AppTheme.warning,
                onTap: () => onNavigate(6),
              ),
              _QuickActionButton(
                icon: Icons.work_rounded,
                label: 'Add Experience',
                color: AppTheme.success,
                onTap: () => onNavigate(3),
              ),
              _QuickActionButton(
                icon: Icons.settings_rounded,
                label: 'CMS Settings',
                color: AppTheme.darkTextMuted,
                onTap: () => onNavigate(8),
              ),
            ],
          ),

          const SizedBox(height: 32),
          Text('Stats', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              blogsAsync.when(
                loading: () => _StatCard(
                  label: 'Blog Posts',
                  value: '…',
                  icon: Icons.article_rounded,
                  color: AppTheme.primary,
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (b) => _StatCard(
                  label: 'Blog Posts',
                  value: '${b.length}',
                  sub: '${b.where((p) => p.isPublished).length} published',
                  icon: Icons.article_rounded,
                  color: AppTheme.primary,
                  onTap: () => onNavigate(5),
                ),
              ),
              projectsAsync.when(
                loading: () => _StatCard(
                  label: 'Projects',
                  value: '…',
                  icon: Icons.phone_iphone_rounded,
                  color: AppTheme.secondary,
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (p) => _StatCard(
                  label: 'Projects',
                  value: '${p.length}',
                  sub: '${p.where((x) => x.featured).length} featured',
                  icon: Icons.phone_iphone_rounded,
                  color: AppTheme.secondary,
                  onTap: () => onNavigate(4),
                ),
              ),
              certAsync.when(
                loading: () => _StatCard(
                  label: 'Certifications',
                  value: '…',
                  icon: Icons.verified_rounded,
                  color: AppTheme.accent,
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (c) => _StatCard(
                  label: 'Certifications',
                  value: '${c.length}',
                  icon: Icons.verified_rounded,
                  color: AppTheme.accent,
                  onTap: () => onNavigate(6),
                ),
              ),
              expAsync.when(
                loading: () => _StatCard(
                  label: 'Experience',
                  value: '…',
                  icon: Icons.work_rounded,
                  color: AppTheme.warning,
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (e) => _StatCard(
                  label: 'Experience',
                  value: '${e.length}',
                  sub: 'companies',
                  icon: Icons.work_rounded,
                  color: AppTheme.warning,
                  onTap: () => onNavigate(3),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Site Visits – Last 7 Days',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Demo Data',
                        style: TextStyle(color: AppTheme.primary, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Connect Google Analytics for real visitor data.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.darkTextMuted,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 350,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => AppTheme.darkCard,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                              BarTooltipItem(
                                '${rod.toY.round()} visits',
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= days.length)
                                return const SizedBox.shrink();
                              return Text(
                                days[idx],
                                style: const TextStyle(
                                  color: AppTheme.darkTextMuted,
                                  fontSize: 11,
                                ),
                              );
                            },
                            reservedSize: 28,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}',
                              style: const TextStyle(
                                color: AppTheme.darkTextMuted,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => const FlLine(
                          color: AppTheme.darkBorder,
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: visitorData
                          .asMap()
                          .entries
                          .map(
                            (e) => BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value.toDouble(),
                                  width: 22,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                  gradient: const LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      AppTheme.primary,
                                      AppTheme.secondary,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          Text('All Sections', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _SectionCard(
                label: 'Profile',
                icon: Icons.person_rounded,
                color: AppTheme.primary,
                onTap: () => onNavigate(1),
              ),
              _SectionCard(
                label: 'Skills',
                icon: Icons.code_rounded,
                color: AppTheme.secondary,
                onTap: () => onNavigate(2),
              ),
              _SectionCard(
                label: 'Experience',
                icon: Icons.work_rounded,
                color: AppTheme.accent,
                onTap: () => onNavigate(3),
              ),
              _SectionCard(
                label: 'Projects',
                icon: Icons.phone_iphone_rounded,
                color: AppTheme.warning,
                onTap: () => onNavigate(4),
              ),
              _SectionCard(
                label: 'Blog',
                icon: Icons.article_rounded,
                color: AppTheme.success,
                onTap: () => onNavigate(5),
              ),
              _SectionCard(
                label: 'Certifications',
                icon: Icons.verified_rounded,
                color: AppTheme.primary,
                onTap: () => onNavigate(6),
              ),
              _SectionCard(
                label: 'Testimonials',
                icon: Icons.format_quote_rounded,
                color: AppTheme.secondary,
                onTap: () => onNavigate(7),
              ),
              _SectionCard(
                label: 'Settings',
                icon: Icons.settings_rounded,
                color: AppTheme.darkTextMuted,
                onTap: () => onNavigate(8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 13)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.sub,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        width: 170,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            if (sub != null)
              Text(
                sub!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.darkTextMuted),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SectionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        width: 130,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Icon(
              Icons.arrow_forward_rounded,
              size: 14,
              color: AppTheme.darkTextMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Blog Admin Tab ───────────────────────────────────────────────────────────
class _BlogAdminTab extends ConsumerStatefulWidget {
  const _BlogAdminTab();
  @override
  ConsumerState<_BlogAdminTab> createState() => _BlogAdminTabState();
}

class _BlogAdminTabState extends ConsumerState<_BlogAdminTab>
    with CmsStateMixin {
  Future<void> _deleteBlog(Map<String, dynamic> blog) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Text('Delete Post?'),
        content: Text("Delete \"${blog['title']}\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await cmsOp(() async {
      final result = await cmsService!.getBlogs();
      final blogs = (result.blogs as List)
          .cast<Map<String, dynamic>>()
          .map(
            (b) => {
              ...b,
              'tags': (b['tags'] as List?)?.cast<String>() ?? <String>[],
            },
          )
          .where((b) => b['id'] != blog['id'])
          .toList();
      final blogTitle = blog['title'] as String? ?? '';
      await cmsService!.saveBlogs(
        sha: result.sha,
        blogs: blogs,
        commitMessage: 'cms: delete blog "$blogTitle"',
      );
      ref.invalidate(blogsProvider);
      showStatus('Deleted. Site rebuilding (~2 min)...');
    });
  }

  Future<void> _togglePublish(Map<String, dynamic> blog) async {
    await cmsOp(() async {
      final result = await cmsService!.getBlogs();
      final blogs = (result.blogs as List).cast<Map<String, dynamic>>().map((
        b,
      ) {
        final normalized = {
          ...b,
          'tags': (b['tags'] as List?)?.cast<String>() ?? <String>[],
        };
        if (b['id'] == blog['id']) {
          final current = b['status'] as String? ?? 'draft';
          return {
            ...normalized,
            'status': current == 'published' ? 'draft' : 'published',
          };
        }
        return normalized;
      }).toList();
      final blogTitle = blog['title'] as String? ?? '';
      await cmsService!.saveBlogs(
        sha: result.sha,
        blogs: blogs,
        commitMessage: 'cms: toggle publish "$blogTitle"',
      );
      ref.invalidate(blogsProvider);
      showStatus('Status updated. Site rebuilding (~2 min)...');
    });
  }

  void _openEditDialog(BuildContext context, Map<String, dynamic>? existing) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _BlogEditDialog(
        existing: existing,
        onSave: (blogData) async {
          await cmsOp(() async {
            final result = await cmsService!.getBlogs();
            // Properly convert each blog to ensure nested lists are typed correctly
            List<Map<String, dynamic>> blogs = (result.blogs as List)
                .cast<Map<String, dynamic>>()
                .map(
                  (b) => {
                    ...b,
                    'tags': (b['tags'] as List?)?.cast<String>() ?? <String>[],
                  },
                )
                .toList();
            if (existing == null) {
              blogs = [...blogs, blogData];
            } else {
              blogs = blogs
                  .map((b) => b['id'] == blogData['id'] ? blogData : b)
                  .toList();
            }
            final bTitle = blogData['title'] as String? ?? '';
            await cmsService!.saveBlogs(
              sha: result.sha,
              blogs: blogs,
              commitMessage: existing == null
                  ? 'cms: add blog "$bTitle"'
                  : 'cms: edit blog "$bTitle"',
            );
            ref.invalidate(blogsProvider);
            showStatus('Saved! Site rebuilding (~2 min)...');
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blogsAsync = ref.watch(blogsProvider);
    return CmsTabScaffold(
      title: 'Blog Management',
      isSaving: saving,
      statusMsg: statusMsg,
      isError: isError,
      needsConfig: !cmsConfigured,
      onDismissStatus: clearStatus,
      actions: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('New Post'),
          onPressed: () => _openEditDialog(context, null),
        ),
      ],
      body: blogsAsync.when(
        loading: () => const CircularProgressIndicator(),
        error: (e, _) => Text('Error: \$e'),
        data: (blogs) => Column(
          children: blogs.map((b) {
            final raw = {
              'id': b.id,
              'title': b.title,
              'slug': b.slug,
              'excerpt': b.excerpt,
              'content': b.content,
              'author': b.author,
              'publishedAt': b.publishedAt.toIso8601String().substring(0, 10),
              'updatedAt': b.updatedAt.toIso8601String().substring(0, 10),
              'readTime': b.readTime,
              'views': b.views,
              'category': b.category,
              'tags': b.tags,
              'status': b.status,
              'featured': b.featured,
              'coverImage': b.coverImage,
            };
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _togglePublish(raw),
                      child: Tooltip(
                        message: b.isPublished
                            ? 'Click to unpublish'
                            : 'Click to publish',
                        child: Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: b.isPublished
                                ? AppTheme.success
                                : AppTheme.warning,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${b.category} · ${b.isPublished ? "Published" : "Draft"} · ${b.readTime} min read',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.darkTextMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      onPressed: () => _openEditDialog(context, raw),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_rounded,
                        size: 18,
                        color: AppTheme.error,
                      ),
                      onPressed: () => _deleteBlog(raw),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _BlogEditDialog extends StatefulWidget {
  final Map<String, dynamic>? existing;
  final Future<void> Function(Map<String, dynamic>) onSave;
  const _BlogEditDialog({this.existing, required this.onSave});
  @override
  State<_BlogEditDialog> createState() => _BlogEditDialogState();
}

class _BlogEditDialogState extends State<_BlogEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title,
      _excerpt,
      _content,
      _category,
      _tags,
      _readTime;
  bool _isPublished = false;
  bool _isFeatured = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?['title'] ?? '');
    _excerpt = TextEditingController(text: e?['excerpt'] ?? '');
    _content = TextEditingController(text: e?['content'] ?? '');
    _category = TextEditingController(text: e?['category'] ?? 'Flutter');

    // Handle tags - can be List<String> or List<dynamic>
    String tagsText = '';
    if (e?['tags'] != null) {
      final tagsList = e!['tags'];
      if (tagsList is List) {
        tagsText = tagsList.map((t) => t.toString()).join(', ');
      }
    }
    _tags = TextEditingController(text: tagsText);

    _readTime = TextEditingController(text: '${e?['readTime'] ?? 5}');
    _isPublished = (e?['status'] as String?) == 'published';
    _isFeatured = e?['featured'] as bool? ?? false;
  }

  @override
  void dispose() {
    for (final c in [_title, _excerpt, _content, _category, _tags, _readTime])
      c.dispose();
    super.dispose();
  }

  String _slugify(String text) => text
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '-');

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.darkSurface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      widget.existing == null ? 'New Blog Post' : 'Edit Post',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _title,
                          decoration: const InputDecoration(
                            labelText: 'Title *',
                            prefixIcon: Icon(Icons.title_rounded),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _excerpt,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Excerpt *',
                            prefixIcon: Icon(Icons.short_text_rounded),
                            alignLabelWithHint: true,
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _content,
                          maxLines: 8,
                          decoration: const InputDecoration(
                            labelText: 'Content (Markdown) *',
                            prefixIcon: Icon(Icons.article_rounded),
                            alignLabelWithHint: true,
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _category,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                  prefixIcon: Icon(Icons.category_rounded),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _readTime,
                                decoration: const InputDecoration(
                                  labelText: 'Read Time (min)',
                                  prefixIcon: Icon(Icons.timer_rounded),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _tags,
                          decoration: const InputDecoration(
                            labelText: 'Tags (comma separated)',
                            prefixIcon: Icon(Icons.tag_rounded),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: SwitchListTile(
                                value: _isPublished,
                                onChanged: (v) =>
                                    setState(() => _isPublished = v),
                                title: const Text('Published'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: SwitchListTile(
                                value: _isFeatured,
                                onChanged: (v) =>
                                    setState(() => _isFeatured = v),
                                title: const Text('Featured'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: _saving
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_rounded, size: 16),
                      label: const Text('Save'),
                      onPressed: _saving
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;
                              setState(() => _saving = true);
                              final tags = _tags.text
                                  .split(',')
                                  .map((t) => t.trim())
                                  .where((t) => t.isNotEmpty)
                                  .toList();
                              final blogData = {
                                'id':
                                    widget.existing?['id'] ??
                                    DateTime.now().millisecondsSinceEpoch
                                        .toString(),
                                'title': _title.text.trim(),
                                'slug':
                                    widget.existing?['slug'] ??
                                    _slugify(_title.text.trim()),
                                'excerpt': _excerpt.text.trim(),
                                'content': _content.text,
                                'author': 'Gowtham Selvaraj',
                                'publishedAt':
                                    widget.existing?['publishedAt'] ??
                                    DateTime.now().toIso8601String().substring(
                                      0,
                                      10,
                                    ),
                                'updatedAt': DateTime.now()
                                    .toIso8601String()
                                    .substring(0, 10),
                                'readTime': int.tryParse(_readTime.text) ?? 5,
                                'views': widget.existing?['views'] ?? 0,
                                'category': _category.text.trim(),
                                'tags': tags,
                                'status': _isPublished ? 'published' : 'draft',
                                'featured': _isFeatured,
                                'coverImage':
                                    widget.existing?['coverImage'] ?? '',
                              };
                              await widget.onSave(blogData);
                              if (context.mounted) Navigator.pop(context);
                            },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Testimonials Tab ─────────────────────────────────────────────────────────
class _TestimonialsTab extends ConsumerStatefulWidget {
  const _TestimonialsTab();
  @override
  ConsumerState<_TestimonialsTab> createState() => _TestimonialsTabState();
}

class _TestimonialsTabState extends ConsumerState<_TestimonialsTab>
    with CmsStateMixin {
  Future<void> _delete(Map<String, dynamic> item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Text('Delete Testimonial?'),
        content: Text("Delete testimonial from \"${item['name']}\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await cmsOp(() async {
      final result = await cmsService!.getTestimonialsWrapped();
      final items = result.testimonials
          .cast<Map<String, dynamic>>()
          .where((t) => t['id'] != item['id'])
          .toList();
      final iName = item['name'] as String? ?? '';
      await cmsService!.saveTestimonials(
        sha: result.sha,
        testimonials: items,
        commitMessage: 'cms: delete testimonial "$iName"',
      );
      ref.invalidate(testimonialsProvider);
      showStatus('Deleted. Site rebuilding (~2 min)...');
    });
  }

  void _openEdit(BuildContext ctx, Map<String, dynamic>? existing) {
    final nameCtrl = TextEditingController(text: existing?['name'] ?? '');
    final roleCtrl = TextEditingController(text: existing?['role'] ?? '');
    final companyCtrl = TextEditingController(text: existing?['company'] ?? '');
    final textCtrl = TextEditingController(text: existing?['content'] ?? '');
    final ratingCtrl = TextEditingController(
      text: '${existing?['rating'] ?? 5}',
    );
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: Text(existing == null ? 'New Testimonial' : 'Edit Testimonial'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: roleCtrl,
                      decoration: const InputDecoration(labelText: 'Role'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: companyCtrl,
                      decoration: const InputDecoration(labelText: 'Company'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: textCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Testimonial Text',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ratingCtrl,
                decoration: const InputDecoration(labelText: 'Rating (1-5)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final data = {
                'id':
                    existing?['id'] ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                'name': nameCtrl.text.trim(),
                'role': roleCtrl.text.trim(),
                'company': companyCtrl.text.trim(),
                'content': textCtrl.text.trim(),
                'rating': int.tryParse(ratingCtrl.text) ?? 5,
                'avatar': existing?['avatar'] ?? '',
              };
              await cmsOp(() async {
                final result = await cmsService!.getTestimonialsWrapped();
                List<Map<String, dynamic>> items = result.testimonials
                    .cast<Map<String, dynamic>>();
                if (existing == null) {
                  items = [...items, data];
                } else {
                  items = items
                      .map((t) => t['id'] == data['id'] ? data : t)
                      .toList();
                }
                final dName = data['name'] as String? ?? '';
                await cmsService!.saveTestimonials(
                  sha: result.sha,
                  testimonials: items,
                  commitMessage: 'cms: update testimonial "$dName"',
                );
                ref.invalidate(testimonialsProvider);
                showStatus('Saved! Site rebuilding (~2 min)...');
              });
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(testimonialsProvider);
    return CmsTabScaffold(
      title: 'Testimonials',
      isSaving: saving,
      statusMsg: statusMsg,
      isError: isError,
      needsConfig: !cmsConfigured,
      onDismissStatus: clearStatus,
      actions: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('Add Testimonial'),
          onPressed: () => _openEdit(context, null),
        ),
      ],
      body: async.when(
        loading: () => const CircularProgressIndicator(),
        error: (e, _) => Text('Error: \$e'),
        data: (testimonials) => Column(
          children: testimonials.map((t) {
            final raw = {
              'id': t.id,
              'name': t.name,
              'role': t.role,
              'company': t.company,
              'content': t.content,
              'rating': t.rating,
              'avatar': t.avatar,
            };
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.format_quote_rounded,
                      color: AppTheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${t.role} · ${t.company} · ⭐ ${t.rating}/5',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.darkTextMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      onPressed: () => _openEdit(context, raw),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_rounded,
                        size: 18,
                        color: AppTheme.error,
                      ),
                      onPressed: () => _delete(raw),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Settings Tab ─────────────────────────────────────────────────────────────
class _SettingsTab extends ConsumerStatefulWidget {
  const _SettingsTab();
  @override
  ConsumerState<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<_SettingsTab> {
  final _tokenCtrl = TextEditingController();
  final _ownerCtrl = TextEditingController();
  final _repoCtrl = TextEditingController();
  bool _obscureToken = true;
  bool _validating = false;
  String? _statusMsg;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    final s = ref.read(githubSettingsProvider);
    _tokenCtrl.text = s.token;
    _ownerCtrl.text = s.owner;
    _repoCtrl.text = s.repo;
  }

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _ownerCtrl.dispose();
    _repoCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveAndValidate() async {
    final token = _tokenCtrl.text.trim();
    final owner = _ownerCtrl.text.trim();
    final repo = _repoCtrl.text.trim();
    if (token.isEmpty || owner.isEmpty || repo.isEmpty) {
      setState(() {
        _statusMsg = 'All fields are required.';
        _isError = true;
      });
      return;
    }
    setState(() {
      _validating = true;
      _statusMsg = null;
    });
    await ref
        .read(githubSettingsProvider.notifier)
        .save(token: token, owner: owner, repo: repo);
    final service = ref.read(githubCmsServiceProvider);
    final ok = await service?.validateToken() ?? false;
    if (mounted) {
      setState(() {
        _validating = false;
        _statusMsg = ok
            ? 'Connected! GitHub CMS is ready. Edits will trigger a redeploy (~2 min).'
            : 'Token saved but connection failed. Check token & repo name.';
        _isError = !ok;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(githubSettingsProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),

          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (b) =>
                          AppTheme.primaryGradient.createShader(b),
                      child: const Icon(
                        Icons.hub_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'GitHub CMS',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Spacer(),
                    if (settings.isConfigured)
                      Chip(
                        label: const Text(
                          'Connected',
                          style: TextStyle(
                            color: AppTheme.success,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: AppTheme.success.withValues(
                          alpha: 0.1,
                        ),
                        side: BorderSide(
                          color: AppTheme.success.withValues(alpha: 0.3),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Save your GitHub token once. Admin edits commit directly to your repo and trigger a GitHub Actions redeploy (~2 min).',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.darkTextMuted,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _ownerCtrl,
                  decoration: const InputDecoration(
                    labelText: 'GitHub Username / Owner',
                    hintText: 'e.g. gowtham7s',
                    prefixIcon: Icon(Icons.person_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _repoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Repository Name',
                    hintText: 'e.g. Portfolio',
                    prefixIcon: Icon(Icons.folder_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tokenCtrl,
                  obscureText: _obscureToken,
                  decoration: InputDecoration(
                    labelText: 'Personal Access Token (PAT)',
                    hintText: 'ghp_xxxxxxxxxxxxxxxxxxxx',
                    prefixIcon: const Icon(Icons.key_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureToken
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                      ),
                      onPressed: () =>
                          setState(() => _obscureToken = !_obscureToken),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppTheme.darkSurface,
                      title: const Text('How to get a GitHub Token'),
                      content: const SingleChildScrollView(
                        child: Text(
                          '1. Go to github.com → Avatar → Settings\n\n'
                          '2. Developer settings → Fine-grained tokens\n\n'
                          '3. Generate new token → name it "Portfolio CMS"\n\n'
                          '4. Repository access → select Portfolio repo\n\n'
                          '5. Permissions → Contents → Read and write\n\n'
                          '6. Generate & copy the token here.\n\n'
                          'Token is stored only in your browser (SharedPreferences).',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Got it'),
                        ),
                      ],
                    ),
                  ),
                  child: Text(
                    'How to get a GitHub token? →',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_statusMsg != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (_isError ? AppTheme.error : AppTheme.success)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (_isError ? AppTheme.error : AppTheme.success)
                            .withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      _statusMsg!,
                      style: TextStyle(
                        color: _isError ? AppTheme.error : AppTheme.success,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: _validating
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_rounded, size: 16),
                      label: Text(
                        _validating ? 'Validating…' : 'Save & Test Connection',
                      ),
                      onPressed: _validating ? null : _saveAndValidate,
                    ),
                    if (settings.isConfigured) ...[
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () async {
                          await ref
                              .read(githubSettingsProvider.notifier)
                              .clear();
                          _tokenCtrl.clear();
                          _ownerCtrl.clear();
                          _repoCtrl.clear();
                          setState(() => _statusMsg = null);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.error,
                          side: BorderSide(
                            color: AppTheme.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Text('Disconnect'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Theme', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(
                    Icons.palette_rounded,
                    color: AppTheme.primary,
                  ),
                  title: const Text('Primary Color'),
                  subtitle: const Text('#6C63FF – Purple'),
                  trailing: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.color_lens_rounded,
                    color: AppTheme.secondary,
                  ),
                  title: const Text('Secondary Color'),
                  subtitle: const Text('#00D9FF – Cyan'),
                  trailing: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppTheme.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.brightness_4_rounded,
                    color: AppTheme.darkTextMuted,
                  ),
                  title: const Text('Default Theme'),
                  subtitle: const Text('Dark Mode'),
                  trailing: const Icon(Icons.dark_mode_rounded),
                ),
                const SizedBox(height: 8),
                Text(
                  'To change theme colors, edit lib/core/theme/app_theme.dart in your codebase.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.darkTextMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
