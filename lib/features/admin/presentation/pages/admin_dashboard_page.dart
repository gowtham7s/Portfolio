import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/github_settings_provider.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../data/repositories/portfolio_repository.dart';

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
              onSelect: (i) => setState(() => _selectedIndex = i),
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

class _AdminContent extends ConsumerWidget {
  final int index;
  const _AdminContent({required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (index) {
      0 => const _OverviewTab(),
      1 => const _PlaceholderTab(
        title: 'Profile Management',
        icon: Icons.person_rounded,
      ),
      2 => const _PlaceholderTab(
        title: 'Skills Management',
        icon: Icons.code_rounded,
      ),
      3 => const _PlaceholderTab(
        title: 'Experience Management',
        icon: Icons.work_rounded,
      ),
      4 => const _PlaceholderTab(
        title: 'Projects Management',
        icon: Icons.phone_iphone_rounded,
      ),
      5 => const _BlogAdminTab(),
      6 => const _PlaceholderTab(
        title: 'Certifications',
        icon: Icons.verified_rounded,
      ),
      7 => const _PlaceholderTab(
        title: 'Testimonials',
        icon: Icons.format_quote_rounded,
      ),
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
          Text(
            'Dashboard Overview',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your portfolio content',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              blogsAsync.when(
                loading: () => _StatCard(
                  label: 'Blog Posts',
                  value: '...',
                  icon: Icons.article_rounded,
                  color: AppTheme.primary,
                ),
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
                  label: 'Projects',
                  value: '...',
                  icon: Icons.phone_iphone_rounded,
                  color: AppTheme.secondary,
                ),
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
                  label: 'Certifications',
                  value: '...',
                  icon: Icons.verified_rounded,
                  color: AppTheme.accent,
                ),
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
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _QuickAction(
                      icon: Icons.add_rounded,
                      label: 'New Blog Post',
                      color: AppTheme.primary,
                    ),
                    _QuickAction(
                      icon: Icons.add_rounded,
                      label: 'New Project',
                      color: AppTheme.secondary,
                    ),
                    _QuickAction(
                      icon: Icons.upload_rounded,
                      label: 'Update Resume',
                      color: AppTheme.accent,
                    ),
                    _QuickAction(
                      icon: Icons.palette_rounded,
                      label: 'Theme Settings',
                      color: AppTheme.warning,
                    ),
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

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
  });

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
class _BlogAdminTab extends ConsumerStatefulWidget {
  const _BlogAdminTab();

  @override
  ConsumerState<_BlogAdminTab> createState() => _BlogAdminTabState();
}

class _BlogAdminTabState extends ConsumerState<_BlogAdminTab> {
  bool _saving = false;
  String? _statusMsg;
  bool _isError = false;

  Future<void> _deleteBlog(Map<String, dynamic> blog) async {
    final service = ref.read(githubCmsServiceProvider);
    if (service == null) {
      _showStatus('Configure GitHub CMS in Settings first.', isError: true);
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Text('Delete Post?'),
        content: Text('Delete "${blog['title']}"? This cannot be undone.'),
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
    setState(() => _saving = true);
    try {
      final result = await service.getBlogs();
      final blogs = result.blogs
          .cast<Map<String, dynamic>>()
          .where((b) => b['id'] != blog['id'])
          .toList();
      await service.saveBlogs(
        sha: result.sha,
        blogs: blogs,
        commitMessage: 'cms: delete blog "${blog['title']}"',
      );
      ref.invalidate(blogsProvider);
      _showStatus('Post deleted. Site rebuilding (~2 min)...');
    } catch (e) {
      _showStatus('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _togglePublish(Map<String, dynamic> blog) async {
    final service = ref.read(githubCmsServiceProvider);
    if (service == null) {
      _showStatus('Configure GitHub CMS in Settings first.', isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final result = await service.getBlogs();
      final blogs = result.blogs.cast<Map<String, dynamic>>().map((b) {
        if (b['id'] == blog['id']) {
          final current = b['status'] as String? ?? 'draft';
          return {
            ...b,
            'status': current == 'published' ? 'draft' : 'published',
          };
        }
        return b;
      }).toList();
      await service.saveBlogs(
        sha: result.sha,
        blogs: blogs,
        commitMessage: 'cms: toggle publish "${blog['title']}"',
      );
      ref.invalidate(blogsProvider);
      _showStatus('Status updated. Site rebuilding (~2 min)...');
    } catch (e) {
      _showStatus('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showStatus(String msg, {bool isError = false}) {
    setState(() {
      _statusMsg = msg;
      _isError = isError;
    });
  }

  void _openEditDialog(BuildContext context, Map<String, dynamic>? existing) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _BlogEditDialog(
        existing: existing,
        onSave: (blogData) async {
          final service = ref.read(githubCmsServiceProvider);
          if (service == null) {
            _showStatus(
              'Configure GitHub CMS in Settings first.',
              isError: true,
            );
            return;
          }
          setState(() => _saving = true);
          try {
            final result = await service.getBlogs();
            List<Map<String, dynamic>> blogs = result.blogs
                .cast<Map<String, dynamic>>();
            if (existing == null) {
              blogs = [...blogs, blogData];
            } else {
              blogs = blogs
                  .map((b) => b['id'] == blogData['id'] ? blogData : b)
                  .toList();
            }
            await service.saveBlogs(
              sha: result.sha,
              blogs: blogs,
              commitMessage: existing == null
                  ? 'cms: add blog "${blogData['title']}"'
                  : 'cms: edit blog "${blogData['title']}"',
            );
            ref.invalidate(blogsProvider);
            _showStatus('Saved! Site rebuilding (~2 min)...');
          } catch (e) {
            _showStatus('Error: $e', isError: true);
          } finally {
            if (mounted) setState(() => _saving = false);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blogsAsync = ref.watch(blogsProvider);
    final isConfigured = ref.watch(githubSettingsProvider).isConfigured;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Blog Management',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(),
              if (_saving)
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('New Post'),
                onPressed: () => _openEditDialog(context, null),
              ),
            ],
          ),
          if (!isConfigured) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.warning.withOpacity(0.4)),
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
                      'GitHub CMS not configured. Go to Settings tab to add your token.',
                      style: TextStyle(color: AppTheme.warning),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_statusMsg != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_isError ? AppTheme.error : AppTheme.success)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (_isError ? AppTheme.error : AppTheme.success)
                      .withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isError ? Icons.error_rounded : Icons.check_circle_rounded,
                    color: _isError ? AppTheme.error : AppTheme.success,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _statusMsg!,
                      style: TextStyle(
                        color: _isError ? AppTheme.error : AppTheme.success,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _statusMsg = null),
                    icon: const Icon(Icons.close_rounded, size: 14),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          blogsAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
            data: (blogs) => Column(
              children: blogs.map((b) {
                final raw = {
                  'id': b.id,
                  'title': b.title,
                  'slug': b.slug,
                  'excerpt': b.excerpt,
                  'content': b.content,
                  'author': b.author,
                  'publishedAt': b.publishedAt.toIso8601String().substring(
                    0,
                    10,
                  ),
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
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
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
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: b.isPublished
                                    ? AppTheme.success
                                    : AppTheme.warning,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
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
                                style: Theme.of(context).textTheme.bodyMedium,
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
        ],
      ),
    );
  }
}

// ─── Blog Edit Dialog ─────────────────────────────────────────────────────────
class _BlogEditDialog extends StatefulWidget {
  final Map<String, dynamic>? existing;
  final Future<void> Function(Map<String, dynamic>) onSave;

  const _BlogEditDialog({this.existing, required this.onSave});

  @override
  State<_BlogEditDialog> createState() => _BlogEditDialogState();
}

class _BlogEditDialogState extends State<_BlogEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _excerpt;
  late final TextEditingController _content;
  late final TextEditingController _category;
  late final TextEditingController _tags;
  late final TextEditingController _readTime;
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
    _tags = TextEditingController(
      text: (e?['tags'] as List?)?.join(', ') ?? '',
    );
    _readTime = TextEditingController(text: e?['readTime']?.toString() ?? '5');
    _isPublished = (e?['status'] as String?) == 'published';
    _isFeatured = e?['featured'] as bool? ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _excerpt.dispose();
    _content.dispose();
    _category.dispose();
    _tags.dispose();
    _readTime.dispose();
    super.dispose();
  }

  String _slugify(String text) => text
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '-');

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isEdit ? 'Edit Post' : 'New Blog Post',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                        const SizedBox(height: 12),
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
                        const SizedBox(height: 12),
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
                        const SizedBox(height: 12),
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
                            const SizedBox(width: 12),
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
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _tags,
                          decoration: const InputDecoration(
                            labelText: 'Tags (comma separated)',
                            prefixIcon: Icon(Icons.tag_rounded),
                          ),
                        ),
                        const SizedBox(height: 12),
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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
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
                      label: Text(_saving ? 'Saving...' : 'Save & Publish'),
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
    final settings = ref.read(githubSettingsProvider);
    _tokenCtrl.text = settings.token;
    _ownerCtrl.text = settings.owner;
    _repoCtrl.text = settings.repo;
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
            ? 'Connected! GitHub CMS is ready. Edits will trigger a redeploy.'
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

          // ── GitHub CMS Card ──────────────────────────────────────────────
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
                        backgroundColor: AppTheme.success.withOpacity(0.1),
                        side: BorderSide(
                          color: AppTheme.success.withOpacity(0.3),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Save your GitHub token once. When you edit content from the admin panel, '
                  'it commits directly to your repo and triggers a GitHub Actions redeploy (~2 min).',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _ownerCtrl,
                  decoration: const InputDecoration(
                    labelText: 'GitHub Username / Owner',
                    hintText: 'e.g. gowtham7s',
                    prefixIcon: Icon(Icons.person_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _repoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Repository Name',
                    hintText: 'e.g. Portfolio',
                    prefixIcon: Icon(Icons.folder_rounded),
                  ),
                ),
                const SizedBox(height: 16),
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
                // How to get token instructions
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: AppTheme.darkSurface,
                        title: const Text('How to get a GitHub Token'),
                        content: const SingleChildScrollView(
                          child: Text(
                            'Steps:\n\n'
                            '1. Go to github.com → Click your avatar → Settings\n\n'
                            '2. Scroll down to "Developer settings" (bottom left)\n\n'
                            '3. Click "Personal access tokens" → "Fine-grained tokens"\n\n'
                            '4. Click "Generate new token"\n\n'
                            '5. Give it a name (e.g. "Portfolio CMS")\n\n'
                            '6. Under Repository access → select "Only select repositories" → pick your Portfolio repo\n\n'
                            '7. Under Permissions → Contents → set to "Read and write"\n\n'
                            '8. Click "Generate token" and copy it here.\n\n'
                            'The token is stored only in your browser (SharedPreferences) and never sent anywhere except GitHub API.',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Got it'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'How to get a GitHub token? Tap to learn more →',
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
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (_isError ? AppTheme.error : AppTheme.success)
                            .withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isError
                              ? Icons.error_rounded
                              : Icons.check_circle_rounded,
                          color: _isError ? AppTheme.error : AppTheme.success,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _statusMsg!,
                            style: TextStyle(
                              color: _isError
                                  ? AppTheme.error
                                  : AppTheme.success,
                            ),
                          ),
                        ),
                      ],
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
                        _validating
                            ? 'Validating...'
                            : 'Save & Test Connection',
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
                            color: AppTheme.error.withOpacity(0.3),
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

          // ── Theme Card ───────────────────────────────────────────────────
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
                  leading: const Icon(
                    Icons.brightness_4_rounded,
                    color: AppTheme.secondary,
                  ),
                  title: const Text('Default Theme'),
                  subtitle: const Text('Dark Mode'),
                  trailing: const Icon(Icons.dark_mode_rounded),
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
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
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
