import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../data/repositories/portfolio_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/animated_section.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../about/presentation/about_page.dart';
import '../../skills/presentation/skills_page.dart';
import '../../experience/presentation/experience_page.dart';
import '../../projects/presentation/projects_page.dart';
import '../../certifications/presentation/certifications_page.dart';
import '../../blog/presentation/blog_list_page.dart';
import 'widgets/stats_row.dart';
import 'widgets/testimonials_section.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const _HeroSection(),
          const AboutPage(embedded: true),
          const SkillsPage(embedded: true),
          const ExperiencePage(embedded: true),
          const ProjectsPage(embedded: true),
          const CertificationsPage(embedded: true),
          const BlogListPage(embedded: true),
          const _TestimonialsSectionWrapper(),
          const _FooterSection(),
        ],
      ),
    );
  }
}

// ─── Hero Section ─────────────────────────────────────────────────────────────
class _HeroSection extends ConsumerWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final isDark = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;

    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      decoration: BoxDecoration(
        gradient: isDark ? AppTheme.heroGradientDark : null,
        color: isDark ? null : AppTheme.lightBg,
      ),
      child: Stack(
        children: [
          // Background mesh gradient blobs
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primary.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.secondary.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 96 : 24,
              vertical: 80,
            ),
            child: profileAsync.when(
              loading: () => const _HeroShimmer(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (profile) => isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _HeroContent(profile: profile),
                        ),
                        const SizedBox(width: 64),
                        Expanded(
                          flex: 2,
                          child: _HeroAvatar(photo: profile.photo),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _HeroAvatar(photo: profile.photo),
                        const SizedBox(height: 40),
                        _HeroContent(profile: profile),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroContent extends ConsumerWidget {
  final dynamic profile;
  const _HeroContent({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = ref.watch(themeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Available badge
        AnimatedSection(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.success.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Available for opportunities',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Name
        AnimatedSection(
          delay: const Duration(milliseconds: 100),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Hi, I\'m\n',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: isDark ? AppTheme.darkText : AppTheme.lightText,
                  ),
                ),
                TextSpan(
                  text: profile.name,
                  style: theme.textTheme.displayMedium?.copyWith(
                    foreground: Paint()
                      ..shader = AppTheme.primaryGradient.createShader(
                        const Rect.fromLTWH(0, 0, 400, 80),
                      ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Typewriter effect
        AnimatedSection(
          delay: const Duration(milliseconds: 200),
          child: Row(
            children: [
              Text(
                'A ',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: isDark
                      ? AppTheme.darkTextMuted
                      : AppTheme.lightTextMuted,
                ),
              ),
              AnimatedTextKit(
                repeatForever: true,
                animatedTexts: (profile.taglines as List<String>)
                    .map(
                      (t) => TypewriterAnimatedText(
                        t,
                        textStyle: theme.textTheme.headlineMedium?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                        speed: const Duration(milliseconds: 60),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Summary
        AnimatedSection(
          delay: const Duration(milliseconds: 300),
          child: Text(
            profile.summary,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
              height: 1.7,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 32),
        // CTA Buttons
        AnimatedSection(
          delay: const Duration(milliseconds: 400),
          child: Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              GradientButton(
                label: 'View My Work',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => context.go('/projects'),
              ),
              GradientButton(
                label: 'Download Resume',
                icon: Icons.download_rounded,
                outlined: true,
                onPressed: () async {
                  final uri = Uri.parse(profile.resume);
                  if (await canLaunchUrl(uri)) launchUrl(uri);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Social Icons
        AnimatedSection(
          delay: const Duration(milliseconds: 500),
          child: Row(
            children: [
              _SocialIcon(
                icon: FontAwesomeIcons.github,
                url: profile.social['github'] ?? '',
                tooltip: 'GitHub',
              ),
              _SocialIcon(
                icon: FontAwesomeIcons.linkedin,
                url: profile.social['linkedin'] ?? '',
                tooltip: 'LinkedIn',
              ),
              _SocialIcon(
                icon: FontAwesomeIcons.twitter,
                url: profile.social['twitter'] ?? '',
                tooltip: 'Twitter',
              ),
              _SocialIcon(
                icon: FontAwesomeIcons.medium,
                url: profile.social['medium'] ?? '',
                tooltip: 'Medium',
              ),
              _SocialIcon(
                icon: Icons.email_rounded,
                url: 'mailto:${profile.email}',
                tooltip: 'Email',
                isMaterial: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        // Stats Row
        AnimatedSection(
          delay: const Duration(milliseconds: 600),
          child: StatsRow(stats: profile.stats),
        ),
      ],
    );
  }
}

class _SocialIcon extends StatefulWidget {
  final dynamic icon;
  final String url;
  final String tooltip;
  final bool isMaterial;

  const _SocialIcon({
    required this.icon,
    required this.url,
    required this.tooltip,
    this.isMaterial = false,
  });

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Tooltip(
        message: widget.tooltip,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () async {
              final uri = Uri.parse(widget.url);
              if (await canLaunchUrl(uri)) launchUrl(uri);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _hovering
                    ? AppTheme.primary.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _hovering
                      ? AppTheme.primary.withOpacity(0.4)
                      : AppTheme.darkBorder,
                ),
              ),
              child: Icon(
                widget.icon as IconData,
                size: 18,
                color: _hovering ? AppTheme.primary : AppTheme.darkTextMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroAvatar extends StatelessWidget {
  final String photo;
  const _HeroAvatar({required this.photo});

  @override
  Widget build(BuildContext context) {
    return AnimatedSection(
      delay: const Duration(milliseconds: 200),
      beginOffset: const Offset(40, 0),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow ring
            Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primary.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Avatar
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.4),
                    blurRadius: 48,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  photo,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: const BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            // Badge
            Positioned(
              bottom: 32,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.darkBorder),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.2),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppTheme.warning,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '8+ Years Expert',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.darkText,
                        fontWeight: FontWeight.w700,
                      ),
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

class _HeroShimmer extends StatelessWidget {
  const _HeroShimmer();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 120, height: 32, borderRadius: 20),
              SizedBox(height: 24),
              ShimmerBox(width: double.infinity, height: 80),
              SizedBox(height: 16),
              ShimmerBox(width: 300, height: 40),
              SizedBox(height: 20),
              ShimmerBox(width: double.infinity, height: 80),
            ],
          ),
        ),
        SizedBox(width: 64),
        ShimmerBox(width: 280, height: 280, borderRadius: 140),
      ],
    );
  }
}

class _TestimonialsSectionWrapper extends ConsumerWidget {
  const _TestimonialsSectionWrapper();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testimonialsAsync = ref.watch(testimonialsProvider);
    return testimonialsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (testimonials) => TestimonialsSection(testimonials: testimonials),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────
class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.darkBorder, width: 1)),
      ),
      child: Column(
        children: [
          // Logo
          ShaderMask(
            shaderCallback: (b) => AppTheme.primaryGradient.createShader(b),
            child: Text(
              'Gowtham Selvaraj',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mobile Lead Developer · iOS Swift · Flutter',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _FooterLink(label: 'Privacy Policy', url: '/privacy'),
              _FooterLink(label: 'Terms', url: '/terms'),
              _FooterLink(label: 'Sitemap', url: '/sitemap'),
              _FooterLink(label: 'Admin', url: '/admin/login'),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '© $year Gowtham Selvaraj. Built with Flutter Web.',
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final String url;
  const _FooterLink({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(url),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppTheme.primary,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
