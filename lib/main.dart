import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: PortfolioApp(),
    ),
  );
}

class PortfolioApp extends ConsumerWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Gowtham Selvaraj – Mobile Lead Developer',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: const [
          Breakpoint(start: 0, end: 450, name: MOBILE),
          Breakpoint(start: 451, end: 800, name: TABLET),
          Breakpoint(start: 801, end: 1920, name: DESKTOP),
          Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
    );
  }
}
