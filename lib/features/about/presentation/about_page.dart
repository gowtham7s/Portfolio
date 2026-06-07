import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/portfolio_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/section_heading.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/animated_section.dart';
import '../../../core/widgets/shimmer_box.dart';

class AboutPage extends ConsumerWidget {
  final bool embedded;
  const AboutPage({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    final content = Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 96 : 24,
        vertical: 80,
      ),
      child: profileAsync.when(
        loading: () => const SectionShimmer(),
        error: (e, _) => Text('Error: $e'),
        data: (profile) => Column(
          children: [
            const SectionHeading(
              title: 'About Me',
              subtitle: 'My Story & Journey',
            ),
            const SizedBox(height: 56),
            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _AboutContent(profile: profile)),
                      const SizedBox(width: 48),
                      Expanded(flex: 2, child: _EducationCard()),
                    ],
                  )
                : Column(
                    children: [
                      _AboutContent(profile: profile),
                      const SizedBox(height: 32),
                      _EducationCard(),
                    ],
                  ),
            const SizedBox(height: 48),
            _CareerTimeline(),
          ],
        ),
      ),
    );

    return embedded ? content : Scaffold(body: SingleChildScrollView(child: content));
  }
}

class _AboutContent extends StatelessWidget {
  final dynamic profile;
  const _AboutContent({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Professional Summary',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            profile.summary,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.8),
          ),
          const SizedBox(height: 32),
          // Key highlights
          ...[
            _Highlight(
              icon: Icons.people_rounded,
              title: 'Team Leadership',
              text: 'Led 8+ developers across multiple squads',
            ),
            _Highlight(
              icon: Icons.speed_rounded,
              title: 'Performance',
              text: 'Reduced crash rates from 8% to <2% via Crashlytics',
            ),
            _Highlight(
              icon: Icons.rocket_launch_rounded,
              title: 'Delivery',
              text: 'CI/CD pipelines cut deploy time from 90 min → 20 min',
            ),
            _Highlight(
              icon: Icons.architecture_rounded,
              title: 'Architecture',
              text: 'Enterprise SDK ecosystem adopted by 5+ teams',
            ),
          ],
        ],
      ),
    );
  }
}

class _Highlight extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  const _Highlight(
      {required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600)),
                Text(text, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EducationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedSection(
      delay: const Duration(milliseconds: 150),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Education', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 20),
            _EduItem(
              degree: 'Master of Business Administration',
              institution: 'KV Institute of Management and Information Studies',
              grade: '7.1 CGPA',
            ),
            const Divider(height: 32),
            _EduItem(
              degree: 'Bachelor of Computer Application',
              institution: 'K.M. College',
              grade: '7.6 CGPA',
            ),
          ],
        ),
      ),
    );
  }
}

class _EduItem extends StatelessWidget {
  final String degree;
  final String institution;
  final String grade;
  const _EduItem(
      {required this.degree,
      required this.institution,
      required this.grade});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(degree,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(institution, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(grade,
                    style: theme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.success, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CareerTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Career Milestones', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 32),
        ...[
          _TimelineItem(year: '2016', text: 'Started career in customer support', isFirst: true),
          _TimelineItem(year: '2017', text: 'Transitioned to NTT Data, earned QA promotion with 95% error reduction'),
          _TimelineItem(year: '2018', text: 'Landed first iOS developer role at MAdept Solutions'),
          _TimelineItem(year: '2020', text: 'Senior iOS Developer at Depex – delivered EduSams, 55% revenue growth'),
          _TimelineItem(year: '2020', text: 'Built government-grade iOS apps with AES-256 encryption at CSC'),
          _TimelineItem(year: '2021', text: 'Promoted to Associate Architect at Cognizant'),
          _TimelineItem(year: '2024', text: 'Led migration to Flutter with Clean Architecture, 50% build improvement'),
          _TimelineItem(year: '2025', text: 'Designing enterprise SDK ecosystem serving 150K+ daily users', isLast: true),
        ],
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String year;
  final String text;
  final bool isFirst;
  final bool isLast;

  const _TimelineItem({
    required this.year,
    required this.text,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedSection(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Year
            SizedBox(
              width: 60,
              child: Text(
                year,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 16),
            // Timeline line + dot
            Column(
              children: [
                Container(
                  width: 2,
                  height: 12,
                  color: isFirst ? Colors.transparent : AppTheme.primary.withOpacity(0.3),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : AppTheme.primary.withOpacity(0.3),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(text, style: theme.textTheme.bodyLarge),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
