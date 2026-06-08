import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Reads and writes JSON files in the GitHub repo via the Contents API.
/// Every write triggers a GitHub Actions rebuild → site updates in ~2 min.
class GitHubCmsService {
  final String owner;
  final String repo;
  final String token; // Personal Access Token with repo scope

  static const _base = 'https://api.github.com';

  GitHubCmsService({
    required this.owner,
    required this.repo,
    required this.token,
  });

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $token',
    'Accept': 'application/vnd.github+json',
    'X-GitHub-Api-Version': '2022-11-28',
    'Content-Type': 'application/json',
  };

  /// Fetches the current JSON content + SHA for a file in assets/data/
  Future<({String content, String sha})> _getFile(String filename) async {
    final url = '$_base/repos/$owner/$repo/contents/assets/data/$filename';
    final res = await http.get(Uri.parse(url), headers: _headers);
    if (res.statusCode != 200) {
      throw GitHubCmsException(
        'Failed to read $filename: ${res.statusCode} ${res.body}',
      );
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final encoded = data['content'] as String;
    // GitHub returns base64 with newlines — strip them before decoding
    final decoded = utf8.decode(base64.decode(encoded.replaceAll('\n', '')));
    return (content: decoded, sha: data['sha'] as String);
  }

  /// Writes updated JSON back to the repo, triggering a redeploy.
  Future<void> _putFile({
    required String filename,
    required String sha,
    required Object json,
    required String commitMessage,
  }) async {
    final url = '$_base/repos/$owner/$repo/contents/assets/data/$filename';
    final body = jsonEncode({
      'message': commitMessage,
      'content': base64.encode(
        utf8.encode(const JsonEncoder.withIndent('  ').convert(json)),
      ),
      'sha': sha,
    });
    final res = await http.put(Uri.parse(url), headers: _headers, body: body);
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw GitHubCmsException(
        'Failed to write $filename: ${res.statusCode} ${res.body}',
      );
    }
    debugPrint('[GitHubCMS] Updated $filename — deploy triggered.');
  }

  // ── Generic helper: read entire JSON array ──────────────────────────────
  Future<({List<dynamic> items, String sha})> readJsonArray(
    String filename,
  ) async {
    final file = await _getFile(filename);
    final items = jsonDecode(file.content) as List<dynamic>;
    return (items: items, sha: file.sha);
  }

  // ── Generic helper: write entire JSON array ─────────────────────────────
  Future<void> writeJsonArray({
    required String filename,
    required String sha,
    required List<dynamic> items,
    required String commitMessage,
  }) async {
    await _putFile(
      filename: filename,
      sha: sha,
      json: items,
      commitMessage: commitMessage,
    );
  }

  // ── Blogs ────────────────────────────────────────────────────────────────
  Future<({List<dynamic> blogs, String sha})> getBlogs() async {
    final r = await readJsonArray('blogs.json');
    return (blogs: r.items, sha: r.sha);
  }

  Future<void> saveBlogs({
    required String sha,
    required List<Map<String, dynamic>> blogs,
    String commitMessage = 'cms: update blogs',
  }) async {
    await writeJsonArray(
      filename: 'blogs.json',
      sha: sha,
      items: blogs,
      commitMessage: commitMessage,
    );
  }

  // ── Projects ─────────────────────────────────────────────────────────────
  Future<({List<dynamic> projects, String sha})> getProjects() async {
    final r = await readJsonArray('projects.json');
    return (projects: r.items, sha: r.sha);
  }

  Future<void> saveProjects({
    required String sha,
    required List<Map<String, dynamic>> projects,
    String commitMessage = 'cms: update projects',
  }) async {
    await writeJsonArray(
      filename: 'projects.json',
      sha: sha,
      items: projects,
      commitMessage: commitMessage,
    );
  }

  // ── Profile ──────────────────────────────────────────────────────────────
  Future<({Map<String, dynamic> profile, String sha})> getProfile() async {
    final file = await _getFile('profile.json');
    return (
      profile: jsonDecode(file.content) as Map<String, dynamic>,
      sha: file.sha,
    );
  }

  Future<void> saveProfile({
    required String sha,
    required Map<String, dynamic> profile,
    String commitMessage = 'cms: update profile',
  }) async {
    await _putFile(
      filename: 'profile.json',
      sha: sha,
      json: profile,
      commitMessage: commitMessage,
    );
  }

  // ── Validate token ───────────────────────────────────────────────────────
  Future<bool> validateToken() async {
    try {
      final res = await http.get(
        Uri.parse('$_base/repos/$owner/$repo'),
        headers: _headers,
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

class GitHubCmsException implements Exception {
  final String message;
  const GitHubCmsException(this.message);

  @override
  String toString() => 'GitHubCmsException: $message';
}
