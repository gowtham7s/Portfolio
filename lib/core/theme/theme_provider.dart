import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the current theme mode (dark / light).
final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(true) {
    _loadTheme();
  }

  static const _key = 'is_dark_mode';

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? true; // default dark
  }

  Future<void> toggleTheme() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, state);
  }

  bool get isDark => state;
}
