import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/shell/app_shell.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/about/presentation/about_page.dart';
import '../../features/skills/presentation/skills_page.dart';
import '../../features/experience/presentation/experience_page.dart';
import '../../features/projects/presentation/projects_page.dart';
import '../../features/resume/presentation/resume_page.dart';
import '../../features/certifications/presentation/certifications_page.dart';
import '../../features/blog/presentation/blog_list_page.dart';
import '../../features/blog/presentation/blog_detail_page.dart';
import '../../features/contact/presentation/contact_page.dart';
import '../../features/admin/presentation/pages/admin_login_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const HomePage()),
          GoRoute(path: '/about', builder: (_, __) => const AboutPage()),
          GoRoute(path: '/skills', builder: (_, __) => const SkillsPage()),
          GoRoute(
              path: '/experience', builder: (_, __) => const ExperiencePage()),
          GoRoute(path: '/projects', builder: (_, __) => const ProjectsPage()),
          GoRoute(path: '/resume', builder: (_, __) => const ResumePage()),
          GoRoute(
              path: '/certifications',
              builder: (_, __) => const CertificationsPage()),
          GoRoute(path: '/blog', builder: (_, __) => const BlogListPage()),
          GoRoute(
            path: '/blog/:slug',
            builder: (_, state) =>
                BlogDetailPage(slug: state.pathParameters['slug'] ?? ''),
          ),
          GoRoute(path: '/contact', builder: (_, __) => const ContactPage()),
        ],
      ),
      // Admin routes (outside shell – no nav bar)
      GoRoute(path: '/admin/login', builder: (_, __) => const AdminLoginPage()),
      GoRoute(
        path: '/admin',
        redirect: (context, state) {
          if (!authState.isAuthenticated) return '/admin/login';
          return null;
        },
        builder: (_, __) => const AdminDashboardPage(),
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (_, __) => const AdminDashboardPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
