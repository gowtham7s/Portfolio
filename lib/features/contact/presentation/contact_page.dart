import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../data/repositories/portfolio_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/section_heading.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/animated_section.dart';
import '../../../core/widgets/gradient_button.dart';

class ContactPage extends ConsumerStatefulWidget {
  const ContactPage({super.key});

  @override
  ConsumerState<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends ConsumerState<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // In production, integrate with an email service / Firebase
      setState(() => _submitted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            title: 'Contact',
            subtitle: 'Get In Touch',
          ),
          const SizedBox(height: 48),
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: AnimatedSection(child: _ContactForm(
                        formKey: _formKey,
                        nameCtrl: _nameCtrl,
                        emailCtrl: _emailCtrl,
                        phoneCtrl: _phoneCtrl,
                        subjectCtrl: _subjectCtrl,
                        messageCtrl: _messageCtrl,
                        submitted: _submitted,
                        onSubmit: _submit,
                      )),
                    ),
                    const SizedBox(width: 48),
                    Expanded(
                      child: AnimatedSection(
                        delay: const Duration(milliseconds: 150),
                        child: profileAsync.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (p) => _ContactInfo(profile: p),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    profileAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (p) => _ContactInfo(profile: p),
                    ),
                    const SizedBox(height: 32),
                    _ContactForm(
                      formKey: _formKey,
                      nameCtrl: _nameCtrl,
                      emailCtrl: _emailCtrl,
                      phoneCtrl: _phoneCtrl,
                      subjectCtrl: _subjectCtrl,
                      messageCtrl: _messageCtrl,
                      submitted: _submitted,
                      onSubmit: _submit,
                    ),
                  ],
                ),
        ],
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(child: content),
    );
  }
}

class _ContactForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController subjectCtrl;
  final TextEditingController messageCtrl;
  final bool submitted;
  final VoidCallback onSubmit;

  const _ContactForm({
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.subjectCtrl,
    required this.messageCtrl,
    required this.submitted,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    if (submitted) {
      return GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppTheme.success, size: 64),
            const SizedBox(height: 16),
            Text(
              'Message Sent!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Thank you for reaching out. I'll get back to you within 24 hours.",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GlassCard(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send a Message',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 24),
            // Name + Email
            Row(
              children: [
                Expanded(
                  child: _FormField(
                    controller: nameCtrl,
                    label: 'Full Name',
                    icon: Icons.person_rounded,
                    validator: (v) =>
                        (v?.isEmpty ?? true) ? 'Name is required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _FormField(
                    controller: emailCtrl,
                    label: 'Email Address',
                    icon: Icons.email_rounded,
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Email is required';
                      if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$')
                          .hasMatch(v!)) return 'Invalid email';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Phone + Subject
            Row(
              children: [
                Expanded(
                  child: _FormField(
                    controller: phoneCtrl,
                    label: 'Phone (optional)',
                    icon: Icons.phone_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _FormField(
                    controller: subjectCtrl,
                    label: 'Subject',
                    icon: Icons.subject_rounded,
                    validator: (v) =>
                        (v?.isEmpty ?? true) ? 'Subject is required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Message
            TextFormField(
              controller: messageCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Message',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 80),
                  child: Icon(Icons.message_rounded),
                ),
              ),
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Message is required';
                if (v!.length < 20) return 'Please write at least 20 characters';
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                label: 'Send Message',
                icon: Icons.send_rounded,
                onPressed: onSubmit,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }
}

class _ContactInfo extends StatelessWidget {
  final dynamic profile;
  const _ContactInfo({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contact Info', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 20),
              _InfoRow(
                icon: Icons.email_rounded,
                label: 'Email',
                value: profile.email,
                url: 'mailto:${profile.email}',
              ),
              _InfoRow(
                icon: Icons.phone_rounded,
                label: 'Phone',
                value: profile.phone,
                url: 'tel:${profile.phone}',
              ),
              _InfoRow(
                icon: Icons.location_on_rounded,
                label: 'Location',
                value: profile.location,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Connect', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if ((profile.social['github'] ?? '').isNotEmpty)
                    _SocialBtn(
                      icon: FontAwesomeIcons.github,
                      label: 'GitHub',
                      url: profile.social['github'],
                    ),
                  if ((profile.social['linkedin'] ?? '').isNotEmpty)
                    _SocialBtn(
                      icon: FontAwesomeIcons.linkedin,
                      label: 'LinkedIn',
                      url: profile.social['linkedin'],
                    ),
                  if ((profile.social['twitter'] ?? '').isNotEmpty)
                    _SocialBtn(
                      icon: FontAwesomeIcons.twitter,
                      label: 'Twitter',
                      url: profile.social['twitter'],
                    ),
                  if ((profile.social['medium'] ?? '').isNotEmpty)
                    _SocialBtn(
                      icon: FontAwesomeIcons.medium,
                      label: 'Medium',
                      url: profile.social['medium'],
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? url;

  const _InfoRow(
      {required this.icon, required this.label, required this.value, this.url});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget text = Text(value, style: theme.textTheme.bodyLarge);
    if (url != null) {
      text = GestureDetector(
        onTap: () async {
          final uri = Uri.parse(url!);
          if (await canLaunchUrl(uri)) launchUrl(uri);
        },
        child: Text(
          value,
          style: theme.textTheme.bodyLarge
              ?.copyWith(color: AppTheme.primary),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodyMedium),
                text,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final dynamic icon;
  final String label;
  final String url;

  const _SocialBtn(
      {required this.icon, required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) launchUrl(uri);
      },
      icon: Icon(icon as IconData, size: 16),
      label: Text(label),
    );
  }
}
