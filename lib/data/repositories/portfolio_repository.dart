import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/json_data_source.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/entities/skill_entity.dart';
import '../../domain/entities/experience_entity.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/blog_entity.dart';
import '../../domain/entities/certification_entity.dart';
import '../../domain/entities/testimonial_entity.dart';

// Providers that expose each data type via Riverpod AsyncNotifier
final profileProvider = FutureProvider<ProfileEntity>((ref) async {
  return JsonDataSource.instance.getProfile();
});

final skillsProvider = FutureProvider<List<SkillCategory>>((ref) async {
  return JsonDataSource.instance.getSkills();
});

final experienceProvider =
    FutureProvider<List<ExperienceEntity>>((ref) async {
  return JsonDataSource.instance.getExperiences();
});

final projectsProvider = FutureProvider<List<ProjectEntity>>((ref) async {
  return JsonDataSource.instance.getProjects();
});

final blogsProvider = FutureProvider<List<BlogEntity>>((ref) async {
  return JsonDataSource.instance.getBlogs();
});

final certificationsProvider =
    FutureProvider<List<CertificationEntity>>((ref) async {
  return JsonDataSource.instance.getCertifications();
});

final testimonialsProvider =
    FutureProvider<List<TestimonialEntity>>((ref) async {
  return JsonDataSource.instance.getTestimonials();
});
