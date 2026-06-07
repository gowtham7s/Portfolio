import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../data/repositories/portfolio_repository.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() =>
      _AdminDashboardPageState();
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
        title: ShaderMask(
          shaderCallback: (b) => AppTheme.primaryGradient.createShader(b),
          child: Text(
            'Admin Dashboard',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white),
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
              onSelect: (i) =>
                  setState(() => _selectedIndex = i),
            ),
      body: isDesktop
          ? Row(
              children: [
                _AdminSidebar(
                  sections: _sections,
                  selectedIndex: _selectedIndex,
                  onSelect: (i) =>
                      setState(() => _selectedIndex = i),
                  inline: true,
                ),
                Expanded(child: _AdminContent(index: _selectedIndex)),
              ],
            )
          : _AdminContent(index: _selectedIndex),
    );
  }
}

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
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(icon,
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : AppTheme.darkTextMuted),
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

class _AdminContent extends ConsumerWidget {
  final int index;
  const _AdminContent({required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (index) {
      0 => const _OverviewTab(),
      1 => const _PlaceholderTab(title: 'Profile Management', icon: Icons.person_rounded),
      2 => const _PlaceholderTab(title: 'Skills Management', icon: Icons.code_rounded),
      3 => const _PlaceholderTab(title: 'Experience Management', icon: Icons.work_rounded),
      4 => const _PlaceholderTab(title: 'Projects Management', icon: Icons.phone_iphone_rounded),
      5 => const _BlogAdminTab(),
      6 => const _PlaceholderTab(title: 'Certifications', icon: Icons.verified_rounded),
      7 => const _PlaceholderTab(title: 'Testimonials', icon: Icons.format_quote_rounded),
      8 => const _SettingsTab(),
      _ => const _OverviewTab(),
    };
  }
}

// ─── Overview Tab ─────────────────────────────────────────────────────────────
class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blogsAsync = ref.watch(blogsProvider);
    final projectsAsync = ref.watch(projectsProvider);
    final certAsync = ref.watch(certificationsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard Overview',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Manage your portfolio content',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              blogsAsync.when(
                loading: () => _StatCard(
                    label: 'Blog Posts', value: '...', icon: Icons.article_rounded, color: AppTheme.primary),
                error: (_, __) => const SizedBox.shrink(),
                data: (blogs) => _StatCard(
                  label: 'Blog Posts',
                  value: '${blogs.length}',
                  icon: Icons.article_rounded,
                  color: AppTheme.primary,
                ),
              ),
              projectsAsync.when(
                loading: () => _StatCard(
                    label: 'Projects', value: '...', icon: Icons.phone_iphone_rounded, color: AppTheme.secondary),
                error: (_, __) => const SizedBox.shrink(),
                data: (p) => _StatCard(
                  label: 'Projects',
                  value: '${p.length}',
                  icon: Icons.phone_iphone_rounded,
                  color: AppTheme.secondary,
                ),
              ),
              certAsync.when(
                loading: () => _StatCard(
                    label: 'Certifications', value: '...', icon: Icons.verified_rounded, color: AppTheme.accent),
                error: (_, __) => const SizedBox.shrink(),
                data: (c) => _StatCard(
                  label: 'Certifications',
                  value: '${c.length}',
                  icon: Icons.verified_rounded,
                  color: AppTheme.accent,
                ),
              ),
              const _StatCard(
                label: 'Years Experience',
                value: '8+',
                icon: Icons.star_rounded,
                color: AppTheme.warning,
              ),
            ],
          ),
          const SizedBox(height: 32),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quick Actions',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _QuickAction(
                        icon: Icons.add_rounded,
                        label: 'New Blog Post',
                        color: AppTheme.primary),
                    _QuickAction(
                        icon: Icons.add_rounded,
                        label: 'New Project',
                        color: AppTheme.secondary),
                    _QuickAction(
                        icon: Icons.upload_rounded,
                        label: 'Update Resume',
                        color: AppTheme.accent),
                    _QuickAction(
                        icon: Icons.palette_rounded,
                        label: 'Theme Settings',
                        color: AppTheme.warning),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 180,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickAction(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
    );
  }
}

// ─── Blog Admin Tab ───────────────────────────────────────────────────────────
class _BlogAdminTab extends ConsumerWidget {
  const _BlogAdminTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blogsAsync = ref.watch(blogsProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Blog Management',
                  style: Theme.of(context).textTheme.headlineMedium),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('New Post'),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          blogsAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
            data: (blogs) => Column(
              children: blogs
                  .map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: b.isPublished
                                    ? AppTheme.success
                                    : AppTheme.warning,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(b.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  Text(
                                    '${b.category} · ${b.isPublished ? "Published" : "Draft"} · ${b.readTime} min read',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_rounded, size: 18),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_rounded,
                                  size: 18, color: AppTheme.error),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Settings Tab ─────────────────────────────────────────────────────────────
class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Theme',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.palette_rounded,
                      color: AppTheme.primary),
                  title: const Text('Primary Color'),
                  subtitle: const Text('#6C63FF'),
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
                  leading: const Icon(Icons.brightness_4_rounded,
                      color: AppTheme.secondary),
                  title: const Text('Default Theme'),
                  subtitle: const Text('Dark Mode'),
                  trailing: const Icon(Icons.dark_mode_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SEO',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue:
                      'Gowtham Selvaraj – Mobile Lead Developer',
                  decoration: const InputDecoration(
                    labelText: 'Site Title',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue:
                      'Personal portfolio of Gowtham Selvaraj, Mobile Lead Developer.',
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Meta Description',
                    prefixIcon: Icon(Icons.description_rounded),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Save SEO Settings'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Placeholder Tab ──────────────────────────────────────────────────────────
class _PlaceholderTab extends StatelessWidget {
  final String title;
  final IconData icon;
  const _PlaceholderTab({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassCard(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppTheme.primary),
            const SizedBox(height: 16),
            Text(title,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Full CRUD management for this section. Connect to Firebase to enable real-time updates.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add New'),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
