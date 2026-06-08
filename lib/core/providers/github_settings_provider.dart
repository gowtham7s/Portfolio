import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/github_cms_service.dart';

// ── GitHub Settings State ────────────────────────────────────────────────────
class GitHubSettings {
  final String token;
  final String owner;
  final String repo;
  final bool isConfigured;

  const GitHubSettings({
    this.token = '',
    this.owner = '',
    this.repo = '',
    this.isConfigured = false,
  });

  GitHubSettings copyWith({String? token, String? owner, String? repo}) {
    final t = token ?? this.token;
    final o = owner ?? this.owner;
    final r = repo ?? this.repo;
    return GitHubSettings(
      token: t,
      owner: o,
      repo: r,
      isConfigured: t.isNotEmpty && o.isNotEmpty && r.isNotEmpty,
    );
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────
final githubSettingsProvider =
    StateNotifierProvider<GitHubSettingsNotifier, GitHubSettings>((ref) {
      return GitHubSettingsNotifier();
    });

class GitHubSettingsNotifier extends StateNotifier<GitHubSettings> {
  GitHubSettingsNotifier() : super(const GitHubSettings()) {
    _load();
  }

  static const _keyToken = 'gh_cms_token';
  static const _keyOwner = 'gh_cms_owner';
  static const _keyRepo = 'gh_cms_repo';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken) ?? '';
    final owner = prefs.getString(_keyOwner) ?? '';
    final repo = prefs.getString(_keyRepo) ?? '';
    state = state.copyWith(token: token, owner: owner, repo: repo);
  }

  Future<void> save({
    required String token,
    required String owner,
    required String repo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyOwner, owner);
    await prefs.setString(_keyRepo, repo);
    state = state.copyWith(token: token, owner: owner, repo: repo);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyOwner);
    await prefs.remove(_keyRepo);
    state = const GitHubSettings();
  }
}

// ── Convenience provider: returns a ready-to-use service or null ─────────────
final githubCmsServiceProvider = Provider<GitHubCmsService?>((ref) {
  final settings = ref.watch(githubSettingsProvider);
  if (!settings.isConfigured) return null;
  return GitHubCmsService(
    owner: settings.owner,
    repo: settings.repo,
    token: settings.token,
  );
});
