class ProfileEntity {
  final String name;
  final String title;
  final String subtitle;
  final List<String> taglines;
  final String summary;
  final String location;
  final String email;
  final String phone;
  final String photo;
  final String resume;
  final Map<String, String> social;
  final List<StatItem> stats;

  const ProfileEntity({
    required this.name,
    required this.title,
    required this.subtitle,
    required this.taglines,
    required this.summary,
    required this.location,
    required this.email,
    required this.phone,
    required this.photo,
    required this.resume,
    required this.social,
    required this.stats,
  });
}

class StatItem {
  final String label;
  final String value;
  const StatItem({required this.label, required this.value});
}
