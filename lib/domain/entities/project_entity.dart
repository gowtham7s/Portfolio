class ProjectEntity {
  final String id;
  final String title;
  final String shortDescription;
  final String description;
  final String thumbnail;
  final List<String> screenshots;
  final List<String> technologies;
  final String category;
  final bool featured;
  final String githubUrl;
  final String appStoreUrl;
  final String playStoreUrl;
  final String liveUrl;
  final List<String> achievements;

  const ProjectEntity({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.description,
    required this.thumbnail,
    required this.screenshots,
    required this.technologies,
    required this.category,
    required this.featured,
    required this.githubUrl,
    required this.appStoreUrl,
    required this.playStoreUrl,
    required this.liveUrl,
    required this.achievements,
  });
}
