import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Reusable scaffold for CMS tabs: header row + status banner + body.
class CmsTabScaffold extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final Widget body;
  final String? statusMsg;
  final bool isError;
  final bool isSaving;
  final VoidCallback? onDismissStatus;
  final bool needsConfig;

  const CmsTabScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.statusMsg,
    this.isError = false,
    this.isSaving = false,
    this.onDismissStatus,
    this.needsConfig = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const Spacer(),
              if (isSaving)
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ...actions,
            ],
          ),
          if (needsConfig) ...[
            const SizedBox(height: 12),
            _banner(
              context,
              icon: Icons.warning_rounded,
              color: AppTheme.warning,
              text:
                  'GitHub CMS not configured. Go to Settings → GitHub CMS to connect.',
            ),
          ],
          if (statusMsg != null) ...[
            const SizedBox(height: 12),
            _banner(
              context,
              icon: isError ? Icons.error_rounded : Icons.check_circle_rounded,
              color: isError ? AppTheme.error : AppTheme.success,
              text: statusMsg!,
              onDismiss: onDismissStatus,
            ),
          ],
          const SizedBox(height: 24),
          body,
        ],
      ),
    );
  }

  Widget _banner(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String text,
    VoidCallback? onDismiss,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: color, fontSize: 13)),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close_rounded, size: 14, color: color),
            ),
        ],
      ),
    );
  }
}
