import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/github_settings_provider.dart';
import '../../../../core/services/github_cms_service.dart';

/// Mixin for ConsumerState classes that need GitHub CMS operations.
mixin CmsStateMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool saving = false;
  String? statusMsg;
  bool isError = false;

  GitHubCmsService? get cmsService => ref.read(githubCmsServiceProvider);
  bool get cmsConfigured => ref.read(githubSettingsProvider).isConfigured;

  void showStatus(String msg, {bool error = false}) {
    if (mounted) {
      setState(() {
        statusMsg = msg;
        isError = error;
        saving = false;
      });
    }
  }

  void clearStatus() {
    if (mounted) setState(() => statusMsg = null);
  }

  void setSaving() {
    if (mounted) setState(() => saving = true);
  }

  /// Wraps a CMS operation with loading/error handling.
  Future<void> cmsOp(Future<void> Function() fn) async {
    if (!cmsConfigured) {
      showStatus('GitHub CMS not configured. Go to Settings tab.', error: true);
      return;
    }
    setSaving();
    try {
      await fn();
    } on GitHubCmsException catch (e) {
      showStatus('GitHub Error: ${e.message}', error: true);
    } catch (e) {
      showStatus('Error: $e', error: true);
    }
  }
}
