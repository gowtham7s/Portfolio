import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/section_heading.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/animated_section.dart';
import '../../../../domain/entities/testimonial_entity.dart';

class TestimonialsSection extends StatelessWidget {
  final List<TestimonialEntity> testimonials;
  const TestimonialsSection({super.key, required this.testimonials});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 96 : 24,
        vertical: 80,
      ),
      child: Column(
        children: [
          const SectionHeading(
            title: 'Testimonials',
            subtitle: 'What Colleagues Say',
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 900 ? 3 : 1;
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: testimonials
                    .asMap()
                    .entries
                    .map(
                      (e) => AnimatedSection(
                        delay: Duration(milliseconds: e.key * 100),
                        child: SizedBox(
                          width: columns == 3
                              ? (constraints.maxWidth - 48) / 3
                              : constraints.maxWidth,
                          child: _TestimonialCard(t: e.value),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final TestimonialEntity t;
  const _TestimonialCard({required this.t});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stars
          Row(
            children: List.generate(
              t.rating,
              (_) => const Padding(
                padding: EdgeInsets.only(right: 2),
                child: Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: AppTheme.warning,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '"${t.content}"',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.primary,
                child: Text(
                  t.name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.name, style: theme.textTheme.titleMedium),
                    Text(
                      '${t.role} · ${t.company}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
