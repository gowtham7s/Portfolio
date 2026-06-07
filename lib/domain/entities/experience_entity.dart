class ExperienceEntity {
  final String id;
  final String role;
  final String company;
  final String location;
  final String startDate;
  final String endDate;
  final bool isCurrent;
  final String logo;
  final String color;
  final List<String> highlights;
  final List<String> technologies;

  const ExperienceEntity({
    required this.id,
    required this.role,
    required this.company,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.isCurrent,
    required this.logo,
    required this.color,
    required this.highlights,
    required this.technologies,
  });
}
