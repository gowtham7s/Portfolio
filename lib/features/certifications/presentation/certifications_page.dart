import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/repositories/portfolio_repository.dart';
import '../../../domain/entities/certification_entity.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/section_heading.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/animated_section.dart';
import '../../../core/widgets/shimmer_box.dart';

class CertificationsPage extends ConsumerWidget {
  final bool embedded;
  const CertificationsPage({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certAsync = ref.watch(certificationsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    final content = Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 96 : 24,
        vertical: 80,
      ),
      child: certAsync.when(
        loading: () => const SectionShimmer(),
        error: (e, _) => Text('Error: $e'),
        data: (certs) => Column(
          children: [
            const SectionHeading(
              title: 'Certifications',
              subtitle: 'Continuous Learning',
            ),
            const SizedBox(height: 48),
            LayoutBuilder(
              builder: (context, constraints) {
                final cols = constraints.maxWidth > 700 ? 2 : 1;
                return Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: certs
                      .asMap()
                      .entries
                      .map(
                        (e) => AnimatedSection(
                          delay: Duration(milliseconds: e.key * 80),
                          child: SizedBox(
                            width: cols == 2
                                ? (constraints.maxWidth - 24) / 2
                                : constraints.maxWidth,
                            child: _CertCard(cert: e.value),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );

    return embedded ? content : Scaffold(body: SingleChildScrollView(child: content));
  }
}

class _CertCard extends StatefulWidget {
  final CertificationEntity cert;
  const _CertCard({required this.cert});

  @override
  State<_CertCard> createState() => _CertCardState();
}

class _CertCardState extends State<_CertCard> {
  bool _hovering = false;

  Color get _color {
    try {
      return Color(
          int.parse(widget.cert.color.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cert = widget.cert;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..translate(0.0, _hovering ? -4.0 : 0.0),
        child: GlassCard(
          borderColor: _hovering ? _color.withOpacity(0.4) : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon/badge
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _color.withOpacity(0.3)),
                ),
                child: Icon(Icons.verified_rounded, color: _color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cert.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.business_rounded,
                            size: 14, color: _color),
                        const SizedBox(width: 4),
                        Text(
                          cert.issuer,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 13, color: AppTheme.darkTextMuted),
                        const SizedBox(width: 4),
                        Text(cert.date,
                            style: theme.textTheme.bodyMedium),
                      ],
                    ),
                    if (cert.credentialUrl.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          final uri = Uri.parse(cert.credentialUrl);
                          if (await canLaunchUrl(uri)) launchUrl(uri);
                        },
                        child: Text(
                          'View Credential →',
                          style: TextStyle(
                            fontSize: 13,
                            color: _color,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
