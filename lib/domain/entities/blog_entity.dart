class BlogEntity {
  final String id;
  final String title;
  final String slug;
  final String excerpt;
  final String content;
  final String category;
  final List<String> tags;
  final String author;
  final DateTime publishedAt;
  final DateTime updatedAt;
  final String status; // 'published' | 'draft'
  final bool featured;
  final String coverImage;
  final int readTime;
  final int views;

  const BlogEntity({
    required this.id,
    required this.title,
    required this.slug,
    required this.excerpt,
    required this.content,
    required this.category,
    required this.tags,
    required this.author,
    required this.publishedAt,
    required this.updatedAt,
    required this.status,
    required this.featured,
    required this.coverImage,
    required this.readTime,
    required this.views,
  });

  bool get isPublished => status == 'published';
}

const List<String> blogCategories = [
  'All',
  'Flutter',
  'iOS',
  'SwiftUI',
  'Career',
  'Motivation',
  'Software Engineering',
  'Architecture',
  'Interview Preparation',
  'Leadership',
  'Inspiration',
];
