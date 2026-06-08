import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../data/repositories/portfolio_repository.dart';
import '../widgets/cms_tab_scaffold.dart';
import '../widgets/cms_state_mixin.dart';

// ─── Projects Tab ─────────────────────────────────────────────────────────────
class ProjectsAdminTab extends ConsumerStatefulWidget {
  const ProjectsAdminTab({super.key});
  @override
  ConsumerState<ProjectsAdminTab> createState() => _ProjectsAdminTabState();
}

class _ProjectsAdminTabState extends ConsumerState<ProjectsAdminTab>
    with CmsStateMixin {
  void _openEdit(BuildContext ctx, Map<String, dynamic>? existing) {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => _ProjectEditDialog(
        existing: existing,
        onSave: (data) async {
          await cmsOp(() async {
            final result = await cmsService!.getProjectsWrapped();
            List<Map<String, dynamic>> items = result.projects
                .cast<Map<String, dynamic>>();
            if (existing == null) {
              items = [...items, data];
            } else {
              items = items
                  .map((p) => p['id'] == data['id'] ? data : p)
                  .toList();
            }
            await cmsService!.saveProjectsWrapped(
              sha: result.sha,
              projects: items,
              commitMessage: existing == null
                  ? 'cms: add project "${data['title']}"'
                  : 'cms: edit project "${data['title']}"',
            );
            ref.invalidate(projectsProvider);
            showStatus('Saved! Site rebuilding (~2 min)...');
          });
        },
      ),
    );
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Text('Delete Project?'),
        content: Text('Delete "${item['title']}"?'),
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
      final result = await cmsService!.getProjectsWrapped();
      final items = result.projects
          .cast<Map<String, dynamic>>()
          .where((p) => p['id'] != item['id'])
          .toList();
      await cmsService!.saveProjectsWrapped(
        sha: result.sha,
        projects: items,
        commitMessage: 'cms: delete project "${item['title']}"',
      );
      ref.invalidate(projectsProvider);
      showStatus('Deleted. Site rebuilding (~2 min)...');
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(projectsProvider);
    return CmsTabScaffold(
      title: 'Projects',
      isSaving: saving,
      statusMsg: statusMsg,
      isError: isError,
      needsConfig: !cmsConfigured,
      onDismissStatus: clearStatus,
      actions: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('New Project'),
          onPressed: () => _openEdit(context, null),
        ),
      ],
      body: async.when(
        loading: () => const CircularProgressIndicator(),
        error: (e, _) => Text('Error: $e'),
        data: (projects) => Column(
          children: projects.map((p) {
            final raw = {
              'id': p.id,
              'title': p.title,
              'shortDescription': p.shortDescription,
              'description': p.description,
              'thumbnail': p.thumbnail,
              'technologies': p.technologies,
              'category': p.category,
              'featured': p.featured,
              'githubUrl': p.githubUrl,
              'appStoreUrl': p.appStoreUrl,
              'playStoreUrl': p.playStoreUrl,
              'liveUrl': p.liveUrl,
              'achievements': p.achievements,
              'screenshots': const [],
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
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.phone_iphone_rounded,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${p.category} · ${p.technologies.take(3).join(', ')}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.darkTextMuted),
                          ),
                        ],
                      ),
                    ),
                    if (p.featured)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Featured',
                          style: TextStyle(
                            color: AppTheme.warning,
                            fontSize: 11,
                          ),
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

class _ProjectEditDialog extends StatefulWidget {
  final Map<String, dynamic>? existing;
  final Future<void> Function(Map<String, dynamic>) onSave;
  const _ProjectEditDialog({this.existing, required this.onSave});
  @override
  State<_ProjectEditDialog> createState() => _ProjectEditDialogState();
}

class _ProjectEditDialogState extends State<_ProjectEditDialog> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _title,
      _short,
      _desc,
      _cat,
      _tech,
      _github,
      _appStore,
      _playStore,
      _live,
      _achievements;
  bool _featured = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?['title'] ?? '');
    _short = TextEditingController(text: e?['shortDescription'] ?? '');
    _desc = TextEditingController(text: e?['description'] ?? '');
    _cat = TextEditingController(text: e?['category'] ?? '');
    _tech = TextEditingController(
      text: (e?['technologies'] as List?)?.join(', ') ?? '',
    );
    _github = TextEditingController(text: e?['githubUrl'] ?? '');
    _appStore = TextEditingController(text: e?['appStoreUrl'] ?? '');
    _playStore = TextEditingController(text: e?['playStoreUrl'] ?? '');
    _live = TextEditingController(text: e?['liveUrl'] ?? '');
    _achievements = TextEditingController(
      text: (e?['achievements'] as List?)?.join('\n') ?? '',
    );
    _featured = e?['featured'] as bool? ?? false;
  }

  @override
  void dispose() {
    for (final c in [
      _title,
      _short,
      _desc,
      _cat,
      _tech,
      _github,
      _appStore,
      _playStore,
      _live,
      _achievements,
    ])
      c.dispose();
    super.dispose();
  }

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
            key: _key,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      widget.existing == null ? 'New Project' : 'Edit Project',
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
                        _field(
                          _title,
                          'Title *',
                          required: true,
                          icon: Icons.title_rounded,
                        ),
                        const SizedBox(height: 10),
                        _field(
                          _short,
                          'Short Description *',
                          required: true,
                          icon: Icons.short_text_rounded,
                        ),
                        const SizedBox(height: 10),
                        _field(
                          _desc,
                          'Full Description',
                          lines: 4,
                          icon: Icons.description_rounded,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _field(
                                _cat,
                                'Category',
                                icon: Icons.category_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SwitchListTile(
                                value: _featured,
                                onChanged: (v) => setState(() => _featured = v),
                                title: const Text('Featured'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _field(
                          _tech,
                          'Technologies (comma separated)',
                          icon: Icons.code_rounded,
                        ),
                        const SizedBox(height: 10),
                        _field(
                          _achievements,
                          'Achievements (one per line)',
                          lines: 3,
                          icon: Icons.star_rounded,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _field(
                                _github,
                                'GitHub URL',
                                icon: Icons.link_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _field(
                                _live,
                                'Live URL',
                                icon: Icons.public_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _field(
                                _appStore,
                                'App Store URL',
                                icon: Icons.apple_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _field(
                                _playStore,
                                'Play Store URL',
                                icon: Icons.android_rounded,
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
                              if (!_key.currentState!.validate()) return;
                              setState(() => _saving = true);
                              final data = {
                                'id':
                                    widget.existing?['id'] ??
                                    _title.text.trim().toLowerCase().replaceAll(
                                      RegExp(r'[^a-z0-9]'),
                                      '-',
                                    ),
                                'title': _title.text.trim(),
                                'shortDescription': _short.text.trim(),
                                'description': _desc.text.trim(),
                                'thumbnail':
                                    widget.existing?['thumbnail'] ?? '',
                                'screenshots': const [],
                                'technologies': _tech.text
                                    .split(',')
                                    .map((t) => t.trim())
                                    .where((t) => t.isNotEmpty)
                                    .toList(),
                                'category': _cat.text.trim(),
                                'featured': _featured,
                                'githubUrl': _github.text.trim(),
                                'appStoreUrl': _appStore.text.trim(),
                                'playStoreUrl': _playStore.text.trim(),
                                'liveUrl': _live.text.trim(),
                                'achievements': _achievements.text
                                    .split('\n')
                                    .map((a) => a.trim())
                                    .where((a) => a.isNotEmpty)
                                    .toList(),
                              };
                              await widget.onSave(data);
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

  Widget _field(
    TextEditingController ctrl,
    String label, {
    bool required = false,
    int lines = 1,
    IconData? icon,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: lines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        alignLabelWithHint: lines > 1,
      ),
      validator: required
          ? (v) => (v == null || v.isEmpty) ? 'Required' : null
          : null,
    );
  }
}

// ─── Certifications Tab ───────────────────────────────────────────────────────
class CertificationsAdminTab extends ConsumerStatefulWidget {
  const CertificationsAdminTab({super.key});
  @override
  ConsumerState<CertificationsAdminTab> createState() =>
      _CertificationsAdminTabState();
}

class _CertificationsAdminTabState extends ConsumerState<CertificationsAdminTab>
    with CmsStateMixin {
  void _openEdit(BuildContext ctx, Map<String, dynamic>? existing) {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => _CertEditDialog(
        existing: existing,
        onSave: (data) async {
          await cmsOp(() async {
            final result = await cmsService!.getCertificationsWrapped();
            List<Map<String, dynamic>> items = result.certifications
                .cast<Map<String, dynamic>>();
            if (existing == null) {
              items = [...items, data];
            } else {
              items = items
                  .map((c) => c['id'] == data['id'] ? data : c)
                  .toList();
            }
            await cmsService!.saveCertifications(
              sha: result.sha,
              certifications: items,
              commitMessage: existing == null
                  ? 'cms: add cert "${data['title']}"'
                  : 'cms: edit cert "${data['title']}"',
            );
            ref.invalidate(certificationsProvider);
            showStatus('Saved! Site rebuilding (~2 min)...');
          });
        },
      ),
    );
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Text('Delete Certification?'),
        content: Text('Delete "${item['title']}"?'),
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
      final result = await cmsService!.getCertificationsWrapped();
      final items = result.certifications
          .cast<Map<String, dynamic>>()
          .where((c) => c['id'] != item['id'])
          .toList();
      await cmsService!.saveCertifications(
        sha: result.sha,
        certifications: items,
        commitMessage: 'cms: delete cert "${item['title']}"',
      );
      ref.invalidate(certificationsProvider);
      showStatus('Deleted. Site rebuilding (~2 min)...');
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(certificationsProvider);
    return CmsTabScaffold(
      title: 'Certifications',
      isSaving: saving,
      statusMsg: statusMsg,
      isError: isError,
      needsConfig: !cmsConfigured,
      onDismissStatus: clearStatus,
      actions: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('New Cert'),
          onPressed: () => _openEdit(context, null),
        ),
      ],
      body: async.when(
        loading: () => const CircularProgressIndicator(),
        error: (e, _) => Text('Error: $e'),
        data: (certs) => Column(
          children: certs.map((c) {
            final raw = {
              'id': c.id,
              'title': c.title,
              'issuer': c.issuer,
              'issuerLogo': c.issuerLogo,
              'date': c.date,
              'credentialUrl': c.credentialUrl,
              'pdfUrl': c.pdfUrl,
              'color': c.color,
              'badge': c.badge,
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
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: AppTheme.accent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${c.issuer} · ${c.date}',
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

class _CertEditDialog extends StatefulWidget {
  final Map<String, dynamic>? existing;
  final Future<void> Function(Map<String, dynamic>) onSave;
  const _CertEditDialog({this.existing, required this.onSave});
  @override
  State<_CertEditDialog> createState() => _CertEditDialogState();
}

class _CertEditDialogState extends State<_CertEditDialog> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _title, _issuer, _date, _credUrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?['title'] ?? '');
    _issuer = TextEditingController(text: e?['issuer'] ?? '');
    _date = TextEditingController(text: e?['date'] ?? '');
    _credUrl = TextEditingController(text: e?['credentialUrl'] ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _issuer.dispose();
    _date.dispose();
    _credUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.darkSurface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      widget.existing == null
                          ? 'New Certification'
                          : 'Edit Certification',
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
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    prefixIcon: Icon(Icons.verified_rounded),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _issuer,
                        decoration: const InputDecoration(
                          labelText: 'Issuer',
                          prefixIcon: Icon(Icons.business_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _date,
                        decoration: const InputDecoration(
                          labelText: 'Date (e.g. Jul 2025)',
                          prefixIcon: Icon(Icons.calendar_today_rounded),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _credUrl,
                  decoration: const InputDecoration(
                    labelText: 'Credential URL',
                    prefixIcon: Icon(Icons.link_rounded),
                  ),
                ),
                const SizedBox(height: 20),
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
                              if (!_key.currentState!.validate()) return;
                              setState(() => _saving = true);
                              final data = {
                                'id':
                                    widget.existing?['id'] ??
                                    _title.text.trim().toLowerCase().replaceAll(
                                      RegExp(r'[^a-z0-9]'),
                                      '-',
                                    ),
                                'title': _title.text.trim(),
                                'issuer': _issuer.text.trim(),
                                'issuerLogo':
                                    widget.existing?['issuerLogo'] ?? '',
                                'date': _date.text.trim(),
                                'credentialUrl': _credUrl.text.trim(),
                                'pdfUrl': widget.existing?['pdfUrl'] ?? '',
                                'color': widget.existing?['color'] ?? '#6C63FF',
                                'badge': widget.existing?['badge'] ?? '',
                              };
                              await widget.onSave(data);
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

// ─── Experience Tab ───────────────────────────────────────────────────────────
class ExperienceAdminTab extends ConsumerStatefulWidget {
  const ExperienceAdminTab({super.key});
  @override
  ConsumerState<ExperienceAdminTab> createState() => _ExperienceAdminTabState();
}

class _ExperienceAdminTabState extends ConsumerState<ExperienceAdminTab>
    with CmsStateMixin {
  void _openEdit(BuildContext ctx, Map<String, dynamic>? existing) {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => _ExperienceEditDialog(
        existing: existing,
        onSave: (data) async {
          await cmsOp(() async {
            final result = await cmsService!.getExperiencesWrapped();
            List<Map<String, dynamic>> items = result.experiences
                .cast<Map<String, dynamic>>();
            if (existing == null) {
              items = [...items, data];
            } else {
              items = items
                  .map((e) => e['id'] == data['id'] ? data : e)
                  .toList();
            }
            await cmsService!.saveExperiences(
              sha: result.sha,
              experiences: items,
              commitMessage: existing == null
                  ? 'cms: add experience "${data['role']}"'
                  : 'cms: edit experience "${data['role']}"',
            );
            ref.invalidate(experienceProvider);
            showStatus('Saved! Site rebuilding (~2 min)...');
          });
        },
      ),
    );
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Text('Delete Experience?'),
        content: Text('Delete "${item['role']}" at ${item['company']}?'),
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
      final result = await cmsService!.getExperiencesWrapped();
      final items = result.experiences
          .cast<Map<String, dynamic>>()
          .where((e) => e['id'] != item['id'])
          .toList();
      await cmsService!.saveExperiences(
        sha: result.sha,
        experiences: items,
        commitMessage: 'cms: delete experience "${item['role']}"',
      );
      ref.invalidate(experienceProvider);
      showStatus('Deleted. Site rebuilding (~2 min)...');
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(experienceProvider);
    return CmsTabScaffold(
      title: 'Experience',
      isSaving: saving,
      statusMsg: statusMsg,
      isError: isError,
      needsConfig: !cmsConfigured,
      onDismissStatus: clearStatus,
      actions: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('Add Experience'),
          onPressed: () => _openEdit(context, null),
        ),
      ],
      body: async.when(
        loading: () => const CircularProgressIndicator(),
        error: (e, _) => Text('Error: $e'),
        data: (exps) => Column(
          children: exps.map((exp) {
            final raw = {
              'id': exp.id,
              'role': exp.role,
              'company': exp.company,
              'location': exp.location,
              'startDate': exp.startDate,
              'endDate': exp.endDate,
              'isCurrent': exp.isCurrent,
              'logo': exp.logo,
              'color': exp.color,
              'highlights': exp.highlights,
              'technologies': exp.technologies,
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
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.work_rounded,
                        color: AppTheme.secondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exp.role,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${exp.company} · ${exp.startDate} – ${exp.endDate}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.darkTextMuted),
                          ),
                        ],
                      ),
                    ),
                    if (exp.isCurrent)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Current',
                          style: TextStyle(
                            color: AppTheme.success,
                            fontSize: 11,
                          ),
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

class _ExperienceEditDialog extends StatefulWidget {
  final Map<String, dynamic>? existing;
  final Future<void> Function(Map<String, dynamic>) onSave;
  const _ExperienceEditDialog({this.existing, required this.onSave});
  @override
  State<_ExperienceEditDialog> createState() => _ExperienceEditDialogState();
}

class _ExperienceEditDialogState extends State<_ExperienceEditDialog> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _role,
      _company,
      _location,
      _start,
      _end,
      _tech,
      _highlights;
  bool _isCurrent = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _role = TextEditingController(text: e?['role'] ?? '');
    _company = TextEditingController(text: e?['company'] ?? '');
    _location = TextEditingController(text: e?['location'] ?? '');
    _start = TextEditingController(text: e?['startDate'] ?? '');
    _end = TextEditingController(text: e?['endDate'] ?? 'Present');
    _tech = TextEditingController(
      text: (e?['technologies'] as List?)?.join(', ') ?? '',
    );
    _highlights = TextEditingController(
      text: (e?['highlights'] as List?)?.join('\n') ?? '',
    );
    _isCurrent = e?['isCurrent'] as bool? ?? false;
  }

  @override
  void dispose() {
    for (final c in [
      _role,
      _company,
      _location,
      _start,
      _end,
      _tech,
      _highlights,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.darkSurface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _key,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      widget.existing == null
                          ? 'Add Experience'
                          : 'Edit Experience',
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
                          controller: _role,
                          decoration: const InputDecoration(
                            labelText: 'Job Title *',
                            prefixIcon: Icon(Icons.badge_rounded),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _company,
                                decoration: const InputDecoration(
                                  labelText: 'Company *',
                                  prefixIcon: Icon(Icons.business_rounded),
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Required'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _location,
                                decoration: const InputDecoration(
                                  labelText: 'Location',
                                  prefixIcon: Icon(Icons.location_on_rounded),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _start,
                                decoration: const InputDecoration(
                                  labelText: 'Start Date (e.g. Jan 2020)',
                                  prefixIcon: Icon(Icons.date_range_rounded),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _end,
                                decoration: const InputDecoration(
                                  labelText: 'End Date / Present',
                                  prefixIcon: Icon(Icons.date_range_rounded),
                                ),
                                enabled: !_isCurrent,
                              ),
                            ),
                          ],
                        ),
                        SwitchListTile(
                          value: _isCurrent,
                          onChanged: (v) {
                            setState(() {
                              _isCurrent = v;
                              if (v) _end.text = 'Present';
                            });
                          },
                          title: const Text('Currently working here'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        TextFormField(
                          controller: _highlights,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Highlights (one per line)',
                            prefixIcon: Icon(Icons.list_rounded),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _tech,
                          decoration: const InputDecoration(
                            labelText: 'Technologies (comma separated)',
                            prefixIcon: Icon(Icons.code_rounded),
                          ),
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
                              if (!_key.currentState!.validate()) return;
                              setState(() => _saving = true);
                              final data = {
                                'id':
                                    widget.existing?['id'] ??
                                    '${_company.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-')}-${DateTime.now().millisecondsSinceEpoch}',
                                'role': _role.text.trim(),
                                'company': _company.text.trim(),
                                'location': _location.text.trim(),
                                'startDate': _start.text.trim(),
                                'endDate': _end.text.trim(),
                                'isCurrent': _isCurrent,
                                'logo': widget.existing?['logo'] ?? '',
                                'color': widget.existing?['color'] ?? '#6C63FF',
                                'highlights': _highlights.text
                                    .split('\n')
                                    .map((h) => h.trim())
                                    .where((h) => h.isNotEmpty)
                                    .toList(),
                                'technologies': _tech.text
                                    .split(',')
                                    .map((t) => t.trim())
                                    .where((t) => t.isNotEmpty)
                                    .toList(),
                              };
                              await widget.onSave(data);
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

// ─── Skills Tab ───────────────────────────────────────────────────────────────
class SkillsAdminTab extends ConsumerStatefulWidget {
  const SkillsAdminTab({super.key});
  @override
  ConsumerState<SkillsAdminTab> createState() => _SkillsAdminTabState();
}

class _SkillsAdminTabState extends ConsumerState<SkillsAdminTab>
    with CmsStateMixin {
  Future<void> _editSkill(
    String catId,
    int skillIndex,
    Map<String, dynamic> skill,
  ) async {
    final nameCtrl = TextEditingController(
      text: skill['name'] as String? ?? '',
    );
    final pctCtrl = TextEditingController(text: '${skill['percentage'] ?? 80}');
    final yrsCtrl = TextEditingController(text: '${skill['years'] ?? 1}');
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        title: const Text('Edit Skill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Skill Name'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: pctCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Proficiency %',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: yrsCtrl,
                    decoration: const InputDecoration(labelText: 'Years'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {
              'name': nameCtrl.text.trim(),
              'percentage': int.tryParse(pctCtrl.text) ?? 80,
              'years': int.tryParse(yrsCtrl.text) ?? 1,
            }),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == null) return;
    await cmsOp(() async {
      final data = await cmsService!.getSkillsWrapped();
      final categories = (data.skills['categories'] as List)
          .cast<Map<String, dynamic>>();
      final catIdx = categories.indexWhere((c) => c['id'] == catId);
      if (catIdx == -1) return;
      final skills = List<Map<String, dynamic>>.from(
        categories[catIdx]['skills'] as List,
      );
      skills[skillIndex] = result;
      categories[catIdx] = {...categories[catIdx], 'skills': skills};
      await cmsService!.saveSkills(
        sha: data.sha,
        skills: {...data.skills, 'categories': categories},
        commitMessage: 'cms: update skill "${result['name']}"',
      );
      ref.invalidate(skillsProvider);
      showStatus('Saved! Site rebuilding (~2 min)...');
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(skillsProvider);
    return CmsTabScaffold(
      title: 'Skills',
      isSaving: saving,
      statusMsg: statusMsg,
      isError: isError,
      needsConfig: !cmsConfigured,
      onDismissStatus: clearStatus,
      body: async.when(
        loading: () => const CircularProgressIndicator(),
        error: (e, _) => Text('Error: $e'),
        data: (categories) => Column(
          children: categories.map((cat) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          cat.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Text(
                          '${cat.skills.length} skills',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.darkTextMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...cat.skills.asMap().entries.map((entry) {
                      final i = entry.key;
                      final s = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        s.name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${s.percentage}%',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: AppTheme.primary),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: s.percentage / 100,
                                    backgroundColor: AppTheme.darkBorder,
                                    valueColor: const AlwaysStoppedAnimation(
                                      AppTheme.primary,
                                    ),
                                    minHeight: 4,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_rounded, size: 16),
                              onPressed: () => _editSkill(cat.id, i, {
                                'name': s.name,
                                'percentage': s.percentage,
                                'years': s.years,
                              }),
                            ),
                          ],
                        ),
                      );
                    }),
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

// ─── Profile Tab ─────────────────────────────────────────────────────────────
class ProfileAdminTab extends ConsumerStatefulWidget {
  const ProfileAdminTab({super.key});
  @override
  ConsumerState<ProfileAdminTab> createState() => _ProfileAdminTabState();
}

class _ProfileAdminTabState extends ConsumerState<ProfileAdminTab>
    with CmsStateMixin {
  final _key = GlobalKey<FormState>();
  TextEditingController? _name,
      _title,
      _subtitle,
      _summary,
      _location,
      _email,
      _phone,
      _taglines;
  bool _loaded = false;

  @override
  void dispose() {
    for (final c in [
      _name,
      _title,
      _subtitle,
      _summary,
      _location,
      _email,
      _phone,
      _taglines,
    ]) {
      c?.dispose();
    }
    super.dispose();
  }

  void _initControllers(profile) {
    if (_loaded) return;
    _name = TextEditingController(text: profile.name);
    _title = TextEditingController(text: profile.title);
    _subtitle = TextEditingController(text: profile.subtitle);
    _summary = TextEditingController(text: profile.summary);
    _location = TextEditingController(text: profile.location);
    _email = TextEditingController(text: profile.email);
    _phone = TextEditingController(text: profile.phone);
    _taglines = TextEditingController(
      text: (profile.taglines as List).join('\n'),
    );
    _loaded = true;
  }

  Future<void> _save(profile) async {
    if (!_key.currentState!.validate()) return;
    await cmsOp(() async {
      final result = await cmsService!.getProfile();
      final updated = {
        ...result.profile,
        'name': _name!.text.trim(),
        'title': _title!.text.trim(),
        'subtitle': _subtitle!.text.trim(),
        'summary': _summary!.text.trim(),
        'location': _location!.text.trim(),
        'email': _email!.text.trim(),
        'phone': _phone!.text.trim(),
        'taglines': _taglines!.text
            .split('\n')
            .map((t) => t.trim())
            .where((t) => t.isNotEmpty)
            .toList(),
      };
      await cmsService!.saveProfile(
        sha: result.sha,
        profile: updated,
        commitMessage: 'cms: update profile',
      );
      ref.invalidate(profileProvider);
      showStatus('Profile saved! Site rebuilding (~2 min)...');
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(profileProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ),
      error: (e, _) =>
          Padding(padding: const EdgeInsets.all(32), child: Text('Error: $e')),
      data: (profile) {
        _initControllers(profile);
        return CmsTabScaffold(
          title: 'Profile',
          isSaving: saving,
          statusMsg: statusMsg,
          isError: isError,
          needsConfig: !cmsConfigured,
          onDismissStatus: clearStatus,
          actions: [
            ElevatedButton.icon(
              icon: const Icon(Icons.save_rounded, size: 16),
              label: const Text('Save Profile'),
              onPressed: () => _save(profile),
            ),
          ],
          body: Form(
            key: _key,
            child: Column(
              children: [
                GlassCard(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          prefixIcon: Icon(Icons.person_rounded),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _title,
                        decoration: const InputDecoration(
                          labelText: 'Job Title *',
                          prefixIcon: Icon(Icons.work_rounded),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _subtitle,
                        decoration: const InputDecoration(
                          labelText: 'Subtitle / Specializations',
                          prefixIcon: Icon(Icons.subtitles_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _summary,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Professional Summary',
                          prefixIcon: Icon(Icons.description_rounded),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _email,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_rounded),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _phone,
                              decoration: const InputDecoration(
                                labelText: 'Phone',
                                prefixIcon: Icon(Icons.phone_rounded),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _location,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          prefixIcon: Icon(Icons.location_on_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _taglines,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: 'Typewriter Taglines (one per line)',
                          prefixIcon: Icon(Icons.format_quote_rounded),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
