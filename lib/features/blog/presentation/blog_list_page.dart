import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/portfolio_repository.dart';
import '../../../domain/entities/blog_entity.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/section_heading.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/animated_section.dart';
import '../../../core/widgets/tech_badge.dart';
import '../../../core/widgets/shimmer_box.dart';

class BlogListPage extends ConsumerStatefulWidget {
  final bool embedded;
  const BlogListPage({super.key, this.embedded = false});

  @override
  ConsumerState<BlogListPage> createState() => _BlogListPageState();
}

class _BlogListPageState extends ConsumerState<BlogListPage> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  int _currentPage = 1;
  static const _pageSize = 6;

  @override
  Widget build(BuildContext context) {
    final blogsAsync = ref.watch(blogsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    final content = Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 96 : 24,
        vertical: 80,
      ),
      child: blogsAsync.when(
        loading: () => const SectionShimmer(),
        error: (e, _) => Text('Error: $e'),
        data: (allBlogs) {
          final published =
              allBlogs.where((b) => b.isPublished).toList();
          final filtered = _applyFilters(published);
          final paginated = _paginate(filtered);

          return Column(
            children: [
              const SectionHeading(
                title: 'Blog',
                subtitle: 'Thoughts & Insights',
              ),
              const SizedBox(height: 32),
              // Search
              _SearchBar(
                onChanged: (q) =>
                    setState(() => _searchQuery = q),
              ),
              const SizedBox(height: 20),
              // Categories
              _CategoryFilter(
                selected: _selectedCategory,
                onSelect: (c) =>
                    setState(() => _selectedCategory = c),
              ),
              const SizedBox(height: 40),
              // Featured post
              if (_selectedCategory == 'All' && _searchQuery.isEmpty)
                _FeaturedPost(
                  blog: published.firstWhere(
                    (b) => b.featured,
                    orElse: () => published.first,
                  ),
                ),
              const SizedBox(height: 32),
              // Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = constraints.maxWidth > 900 ? 3 : constraints.maxWidth > 600 ? 2 : 1;
                  return Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: paginated
                        .asMap()
                        .entries
                        .map((e) => AnimatedSection(
                              delay: Duration(
                                  milliseconds: e.key * 60),
                              child: SizedBox(
                                width: cols > 1
                                    ? (constraints.maxWidth -
                                            24 * (cols - 1)) /
                                        cols
                                    : constraints.maxWidth,
                                child: _BlogCard(blog: e.value),
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 32),
              // Pagination
              _Pagination(
                total: filtered.length,
                current: _currentPage,
                pageSize: _pageSize,
                onPage: (p) => setState(() => _currentPage = p),
              ),
            ],
          );
        },
      ),
    );

    return widget.embedded
        ? content
        : Scaffold(body: SingleChildScrollView(child: content));
  }

  List<BlogEntity> _applyFilters(List<BlogEntity> blogs) {
    return blogs.where((b) {
      final catMatch = _selectedCategory == 'All' ||
          b.category == _selectedCategory;
      final query = _searchQuery.toLowerCase();
      final searchMatch = query.isEmpty ||
          b.title.toLowerCase().contains(query) ||
          b.excerpt.toLowerCase().contains(query) ||
          b.tags.any((t) => t.toLowerCase().contains(query));
      return catMatch && searchMatch;
    }).toList();
  }

  List<BlogEntity> _paginate(List<BlogEntity> blogs) {
    final start = (_currentPage - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, blogs.length);
    if (start >= blogs.length) return [];
    return blogs.sublist(start, end);
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search articles...',
          prefixIcon: const Icon(Icons.search_rounded),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.darkBorder),
          ),
        ),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _CategoryFilter(
      {required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: blogCategories
            .map(
              (c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onSelect(c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      gradient:
                          selected == c ? AppTheme.primaryGradient : null,
                      color: selected == c ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected == c
                            ? Colors.transparent
                            : AppTheme.darkBorder,
                      ),
                    ),
                    child: Text(
                      c,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected == c
                            ? Colors.white
                            : AppTheme.darkTextMuted,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _FeaturedPost extends StatelessWidget {
  final BlogEntity blog;
  const _FeaturedPost({required this.blog});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => context.go('/blog/${blog.slug}'),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            // Cover
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20)),
              child: Container(
                width: 240,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withOpacity(0.5),
                      AppTheme.secondary.withOpacity(0.3),
                    ],
                  ),
                ),
                child: const Icon(Icons.article_rounded,
                    size: 64, color: Colors.white54),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TechBadge(label: '⭐ Featured', color: AppTheme.warning),
                    const SizedBox(height: 12),
                    Text(blog.title, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      blog.excerpt,
                      style: theme.textTheme.bodyLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        TechBadge(label: blog.category),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time_rounded,
                            size: 14, color: AppTheme.darkTextMuted),
                        const SizedBox(width: 4),
                        Text('${blog.readTime} min read',
                            style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlogCard extends StatefulWidget {
  final BlogEntity blog;
  const _BlogCard({required this.blog});

  @override
  State<_BlogCard> createState() => _BlogCardState();
}

class _BlogCardState extends State<_BlogCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final b = widget.blog;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go('/blog/${b.slug}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..translate(0.0, _hovering ? -6.0 : 0.0),
          child: GlassCard(
            padding: EdgeInsets.zero,
            borderColor: _hovering
                ? AppTheme.primary.withOpacity(0.4)
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20)),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary.withOpacity(0.25),
                          AppTheme.secondary.withOpacity(0.15),
                        ],
                      ),
                    ),
                    child: const Icon(Icons.article_rounded,
                        size: 48, color: Colors.white38),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          TechBadge(label: b.category),
                          const Spacer(),
                          Text(
                            DateFormat('MMM d, y').format(b.publishedAt),
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        b.title,
                        style: theme.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        b.excerpt,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 13, color: AppTheme.darkTextMuted),
                          const SizedBox(width: 4),
                          Text('${b.readTime} min',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontSize: 11)),
                          const SizedBox(width: 12),
                          Icon(Icons.remove_red_eye_rounded,
                              size: 13, color: AppTheme.darkTextMuted),
                          const SizedBox(width: 4),
                          Text('${b.views}',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  final int total;
  final int current;
  final int pageSize;
  final ValueChanged<int> onPage;

  const _Pagination({
    required this.total,
    required this.current,
    required this.pageSize,
    required this.onPage,
  });

  @override
  Widget build(BuildContext context) {
    final totalPages = (total / pageSize).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (i) {
        final page = i + 1;
        final isActive = page == current;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GestureDetector(
            onTap: () => onPage(page),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: isActive ? AppTheme.primaryGradient : null,
                color: isActive ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isActive
                      ? Colors.transparent
                      : AppTheme.darkBorder,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '$page',
                style: TextStyle(
                  color: isActive ? Colors.white : AppTheme.darkTextMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
