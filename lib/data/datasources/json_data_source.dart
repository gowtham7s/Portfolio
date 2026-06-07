import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/entities/skill_entity.dart';
import '../../domain/entities/experience_entity.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/blog_entity.dart';
import '../../domain/entities/certification_entity.dart';
import '../../domain/entities/testimonial_entity.dart';

/// Reads all data from local JSON assets – acts as the single source of truth.
/// Replace with Firebase / REST implementation by swapping this class only.
class JsonDataSource {
  JsonDataSource._();
  static final JsonDataSource instance = JsonDataSource._();

  Future<Map<String, dynamic>> _load(String path) async {
    final raw = await rootBundle.loadString(path);
    return json.decode(raw) as Map<String, dynamic>;
  }

  // ─── Profile ──────────────────────────────────────────────────────────────
  Future<ProfileEntity> getProfile() async {
    final data = await _load('assets/data/profile.json');
    final social = Map<String, String>.from(data['social'] as Map);
    final stats = (data['stats'] as List)
        .map((s) => StatItem(label: s['label'], value: s['value']))
        .toList();
    return ProfileEntity(
      name: data['name'],
      title: data['title'],
      subtitle: data['subtitle'],
      taglines: List<String>.from(data['taglines']),
      summary: data['summary'],
      location: data['location'],
      email: data['email'],
      phone: data['phone'],
      photo: data['photo'],
      resume: data['resume'],
      social: social,
      stats: stats,
    );
  }

  // ─── Skills ───────────────────────────────────────────────────────────────
  Future<List<SkillCategory>> getSkills() async {
    final data = await _load('assets/data/skills.json');
    return (data['categories'] as List).map((cat) {
      return SkillCategory(
        id: cat['id'],
        name: cat['name'],
        icon: cat['icon'],
        skills: (cat['skills'] as List)
            .map((s) => Skill(
                  name: s['name'],
                  percentage: s['percentage'],
                  years: s['years'],
                ))
            .toList(),
      );
    }).toList();
  }

  // ─── Experience ───────────────────────────────────────────────────────────
  Future<List<ExperienceEntity>> getExperiences() async {
    final data = await _load('assets/data/experience.json');
    return (data['experiences'] as List)
        .map((e) => ExperienceEntity(
              id: e['id'],
              role: e['role'],
              company: e['company'],
              location: e['location'],
              startDate: e['startDate'],
              endDate: e['endDate'],
              isCurrent: e['isCurrent'] ?? false,
              logo: e['logo'] ?? '',
              color: e['color'] ?? '#6C63FF',
              highlights: List<String>.from(e['highlights']),
              technologies: List<String>.from(e['technologies']),
            ))
        .toList();
  }

  // ─── Projects ─────────────────────────────────────────────────────────────
  Future<List<ProjectEntity>> getProjects() async {
    final data = await _load('assets/data/projects.json');
    return (data['projects'] as List)
        .map((p) => ProjectEntity(
              id: p['id'],
              title: p['title'],
              shortDescription: p['shortDescription'],
              description: p['description'],
              thumbnail: p['thumbnail'] ?? '',
              screenshots: List<String>.from(p['screenshots']),
              technologies: List<String>.from(p['technologies']),
              category: p['category'],
              featured: p['featured'] ?? false,
              githubUrl: p['githubUrl'] ?? '',
              appStoreUrl: p['appStoreUrl'] ?? '',
              playStoreUrl: p['playStoreUrl'] ?? '',
              liveUrl: p['liveUrl'] ?? '',
              achievements: List<String>.from(p['achievements']),
            ))
        .toList();
  }

  // ─── Blogs ────────────────────────────────────────────────────────────────
  Future<List<BlogEntity>> getBlogs() async {
    final data = await _load('assets/data/blogs.json');
    return (data['blogs'] as List)
        .map((b) => BlogEntity(
              id: b['id'],
              title: b['title'],
              slug: b['slug'],
              excerpt: b['excerpt'],
              content: b['content'],
              category: b['category'],
              tags: List<String>.from(b['tags']),
              author: b['author'],
              publishedAt: DateTime.parse(b['publishedAt']),
              updatedAt: DateTime.parse(b['updatedAt']),
              status: b['status'],
              featured: b['featured'] ?? false,
              coverImage: b['coverImage'] ?? '',
              readTime: b['readTime'] ?? 5,
              views: b['views'] ?? 0,
            ))
        .toList();
  }

  // ─── Certifications ───────────────────────────────────────────────────────
  Future<List<CertificationEntity>> getCertifications() async {
    final data = await _load('assets/data/certifications.json');
    return (data['certifications'] as List)
        .map((c) => CertificationEntity(
              id: c['id'],
              title: c['title'],
              issuer: c['issuer'],
              issuerLogo: c['issuerLogo'] ?? '',
              date: c['date'],
              credentialUrl: c['credentialUrl'] ?? '',
              pdfUrl: c['pdfUrl'] ?? '',
              color: c['color'] ?? '#6C63FF',
              badge: c['badge'] ?? '',
            ))
        .toList();
  }

  // ─── Testimonials ─────────────────────────────────────────────────────────
  Future<List<TestimonialEntity>> getTestimonials() async {
    final data = await _load('assets/data/testimonials.json');
    return (data['testimonials'] as List)
        .map((t) => TestimonialEntity(
              id: t['id'],
              name: t['name'],
              role: t['role'],
              company: t['company'],
              avatar: t['avatar'] ?? '',
              content: t['content'],
              rating: t['rating'] ?? 5,
            ))
        .toList();
  }
}
