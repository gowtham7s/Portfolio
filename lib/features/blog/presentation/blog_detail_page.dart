import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/portfolio_repository.dart';
import '../../../domain/entities/blog_entity.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/tech_badge.dart';

class BlogDetailPage extends ConsumerWidget {
  final String slug;
  const BlogDetailPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blogsAsync = ref.watch(blogsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      body: blogsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (blogs) {
          final blog = blogs.cast<BlogEntity?>().firstWhere(
                (b) => b?.slug == slug,
                orElse: () => null,
              );

          if (blog == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.article_outlined,
                      size: 64, color: AppTheme.darkTextMuted),
                  const SizedBox(height: 16),
                  const Text('Article not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/blog'),
                    child: const Text('Back to Blog'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Hero
                Container(
                  width: double.infinity,
                  height: 320,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary.withOpacity(0.4),
                        AppTheme.secondary.withOpacity(0.2),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 200 : 24,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TechBadge(label: blog.category),
                          const SizedBox(height: 16),
                          Text(
                            blog.title,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircleAvatar(
                                radius: 16,
                                backgroundColor: AppTheme.primary,
                                child: Icon(Icons.person_rounded,
                                    size: 18, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                blog.author,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.white70),
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.access_time_rounded,
                                  size: 14, color: Colors.white60),
                              const SizedBox(width: 4),
                              Text(
                                '${blog.readTime} min read',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.white60),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                DateFormat('MMM d, y')
                                    .format(blog.publishedAt),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.white60),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Content
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 0 : 24,
                        vertical: 48,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tags
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: blog.tags
                                .map((t) => TechBadge(label: t))
                                .toList(),
                          ),
                          const SizedBox(height: 32),
                          // Markdown content
                          MarkdownBody(
                            data: blog.content,
                            styleSheet: MarkdownStyleSheet(
                              h1: Theme.of(context).textTheme.displaySmall,
                              h2: Theme.of(context).textTheme.headlineMedium,
                              h3: Theme.of(context).textTheme.headlineSmall,
                              p: Theme.of(context).textTheme.bodyLarge,
                              code: const TextStyle(
                                fontFamily: 'monospace',
                                backgroundColor: AppTheme.darkCard,
                                color: AppTheme.secondary,
                              ),
                              blockquoteDecoration: BoxDecoration(
                                color:
                                    AppTheme.primary.withOpacity(0.08),
                                border: const Border(
                                  left: BorderSide(
                                      color: AppTheme.primary, width: 4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),
                          // Back button
                          TextButton.icon(
                            onPressed: () => context.go('/blog'),
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Back to Blog'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
