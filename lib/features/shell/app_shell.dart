import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/widgets/scroll_progress_indicator.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Column(
          children: [
            ScrollProgressIndicatorWidget(controller: _scrollController),
            Expanded(child: _NavBar(isMobile: isMobile)),
          ],
        ),
      ),
      drawer: isMobile ? _MobileDrawer() : null,
      body: widget.child,
      floatingActionButton: _BackToTopButton(controller: _scrollController),
    );
  }
}

// ─── Navigation Bar ──────────────────────────────────────────────────────────
class _NavBar extends ConsumerWidget {
  final bool isMobile;
  const _NavBar({required this.isMobile});

  static const _navItems = [
    ('Home', '/'),
    ('About', '/about'),
    ('Skills', '/skills'),
    ('Experience', '/experience'),
    ('Projects', '/projects'),
    ('Blog', '/blog'),
    ('Contact', '/contact'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    return Container(
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.darkSurface : AppTheme.lightSurface)
            .withOpacity(0.85),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            // Logo
            InkWell(
              onTap: () => context.go('/'),
              child: ShaderMask(
                shaderCallback: (b) => AppTheme.primaryGradient.createShader(b),
                child: Text(
                  'GS.',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const Spacer(),
            if (isMobile)
              Builder(
                builder: (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: Icon(
                    Icons.menu_rounded,
                    color: isDark ? AppTheme.darkText : AppTheme.lightText,
                  ),
                ),
              )
            else ...[
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _navItems.map(
                    (item) => _NavItem(label: item.$1, route: item.$2),
                  ).toList(),
                ),
              ),
              const SizedBox(width: 8),
              _ThemeToggle(),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavItem extends ConsumerWidget {
  final String label;
  final String route;
  const _NavItem({required this.label, required this.route});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final currentRoute = GoRouterState.of(context).uri.toString();
    final isActive =
        currentRoute == route ||
        (route != '/' && currentRoute.startsWith(route));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: () => context.go(route),
        style: TextButton.styleFrom(
          foregroundColor: isActive
              ? AppTheme.primary
              : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive
                ? AppTheme.primary
                : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
          ),
        ),
      ),
    );
  }
}

class _ThemeToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    return IconButton(
      tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey(isDark),
          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
        ),
      ),
    );
  }
}

class _MobileDrawer extends ConsumerWidget {
  static const _navItems = [
    ('Home', '/'),
    ('About', '/about'),
    ('Skills', '/skills'),
    ('Experience', '/experience'),
    ('Projects', '/projects'),
    ('Blog', '/blog'),
    ('Contact', '/contact'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    return Drawer(
      backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: ShaderMask(
                shaderCallback: (b) => AppTheme.primaryGradient.createShader(b),
                child: Text(
                  'GS.',
                  style: Theme.of(
                    context,
                  ).textTheme.displaySmall?.copyWith(color: Colors.white),
                ),
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: _navItems
                    .map(
                      (item) => ListTile(
                        title: Text(item.$1),
                        onTap: () {
                          Navigator.pop(context);
                          context.go(item.$2);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            ListTile(
              leading: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              ),
              title: Text(isDark ? 'Light Mode' : 'Dark Mode'),
              onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackToTopButton extends StatefulWidget {
  final ScrollController controller;
  const _BackToTopButton({required this.controller});

  @override
  State<_BackToTopButton> createState() => _BackToTopButtonState();
}

class _BackToTopButtonState extends State<_BackToTopButton> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
  }

  void _onScroll() {
    final show = widget.controller.hasClients && widget.controller.offset > 400;
    if (show != _visible) setState(() => _visible = show);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: AnimatedScale(
        scale: _visible ? 1 : 0.6,
        duration: const Duration(milliseconds: 300),
        child: FloatingActionButton.small(
          tooltip: 'Back to top',
          backgroundColor: AppTheme.primary,
          onPressed: () => widget.controller.animateTo(
            0,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          ),
          child: const Icon(
            Icons.keyboard_arrow_up_rounded,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
