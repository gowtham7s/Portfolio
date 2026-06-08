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
    final file = await _getFile('blogs.json');
    final data = jsonDecode(file.content) as Map<String, dynamic>;
    final items = data['blogs'] as List<dynamic>;
    return (blogs: items, sha: file.sha);
  }

  Future<void> saveBlogs({
    required String sha,
    required List<Map<String, dynamic>> blogs,
    String commitMessage = 'cms: update blogs',
  }) async {
    await _putFile(
      filename: 'blogs.json',
      sha: sha,
      json: {'blogs': blogs},
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

  // ── Experience ───────────────────────────────────────────────────────────
  Future<({List<dynamic> experiences, String sha})> getExperiences() async {
    final r = await readJsonArray('experience.json');
    // experience.json has a wrapper object: { "experiences": [...] }
    if (r.items.isNotEmpty &&
        r.items[0] is Map &&
        (r.items[0] as Map).containsKey('experiences')) {
      // Unlikely but guard
    }
    return (experiences: r.items, sha: r.sha);
  }

  Future<({List<dynamic> experiences, String sha})>
  getExperiencesWrapped() async {
    final file = await _getFile('experience.json');
    final data = jsonDecode(file.content) as Map<String, dynamic>;
    final items = data['experiences'] as List<dynamic>;
    return (experiences: items, sha: file.sha);
  }

  Future<void> saveExperiences({
    required String sha,
    required List<Map<String, dynamic>> experiences,
    String commitMessage = 'cms: update experience',
  }) async {
    await _putFile(
      filename: 'experience.json',
      sha: sha,
      json: {'experiences': experiences},
      commitMessage: commitMessage,
    );
  }

  // ── Projects ─────────────────────────────────────────────────────────────
  Future<({List<dynamic> projects, String sha})> getProjectsWrapped() async {
    final file = await _getFile('projects.json');
    final data = jsonDecode(file.content) as Map<String, dynamic>;
    final items = data['projects'] as List<dynamic>;
    return (projects: items, sha: file.sha);
  }

  Future<void> saveProjectsWrapped({
    required String sha,
    required List<Map<String, dynamic>> projects,
    String commitMessage = 'cms: update projects',
  }) async {
    await _putFile(
      filename: 'projects.json',
      sha: sha,
      json: {'projects': projects},
      commitMessage: commitMessage,
    );
  }

  // ── Certifications ────────────────────────────────────────────────────────
  Future<({List<dynamic> certifications, String sha})>
  getCertificationsWrapped() async {
    final file = await _getFile('certifications.json');
    final data = jsonDecode(file.content) as Map<String, dynamic>;
    final items = data['certifications'] as List<dynamic>;
    return (certifications: items, sha: file.sha);
  }

  Future<void> saveCertifications({
    required String sha,
    required List<Map<String, dynamic>> certifications,
    String commitMessage = 'cms: update certifications',
  }) async {
    await _putFile(
      filename: 'certifications.json',
      sha: sha,
      json: {'certifications': certifications},
      commitMessage: commitMessage,
    );
  }

  // ── Skills ────────────────────────────────────────────────────────────────
  Future<({Map<String, dynamic> skills, String sha})> getSkillsWrapped() async {
    final file = await _getFile('skills.json');
    return (
      skills: jsonDecode(file.content) as Map<String, dynamic>,
      sha: file.sha,
    );
  }

  Future<void> saveSkills({
    required String sha,
    required Map<String, dynamic> skills,
    String commitMessage = 'cms: update skills',
  }) async {
    await _putFile(
      filename: 'skills.json',
      sha: sha,
      json: skills,
      commitMessage: commitMessage,
    );
  }

  // ── Testimonials ──────────────────────────────────────────────────────────
  Future<({List<dynamic> testimonials, String sha})>
  getTestimonialsWrapped() async {
    final file = await _getFile('testimonials.json');
    final data = jsonDecode(file.content) as Map<String, dynamic>;
    final items = data['testimonials'] as List<dynamic>;
    return (testimonials: items, sha: file.sha);
  }

  Future<void> saveTestimonials({
    required String sha,
    required List<Map<String, dynamic>> testimonials,
    String commitMessage = 'cms: update testimonials',
  }) async {
    await _putFile(
      filename: 'testimonials.json',
      sha: sha,
      json: {'testimonials': testimonials},
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
