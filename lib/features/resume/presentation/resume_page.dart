import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/repositories/portfolio_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/section_heading.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/animated_section.dart';
import '../../../core/widgets/gradient_button.dart';

class ResumePage extends ConsumerWidget {
  final bool embedded;
  const ResumePage({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    final content = Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 96 : 24,
        vertical: 80,
      ),
      child: Column(
        children: [
          const SectionHeading(
            title: 'Resume',
            subtitle: 'Download My CV',
          ),
          const SizedBox(height: 48),
          profileAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
            data: (profile) => AnimatedSection(
              child: GlassCard(
                child: Column(
                  children: [
                    // Preview icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.description_rounded,
                          color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Gowtham Selvaraj',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mobile Lead Developer – iOS Swift & Flutter',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 32),
                    // Download button
                    GradientButton(
                      label: 'Download Resume (PDF)',
                      icon: Icons.download_rounded,
                      onPressed: () async {
                        final uri = Uri.parse(profile.resume);
                        if (await canLaunchUrl(uri)) {
                          launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Last updated: 2025',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return embedded ? content : Scaffold(body: SingleChildScrollView(child: content));
  }
}
