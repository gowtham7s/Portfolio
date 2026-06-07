class SkillCategory {
  final String id;
  final String name;
  final String icon;
  final List<Skill> skills;

  const SkillCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.skills,
  });
}

class Skill {
  final String name;
  final int percentage;
  final int years;

  const Skill({
    required this.name,
    required this.percentage,
    required this.years,
  });
}
