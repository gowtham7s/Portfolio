import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthState {
  final bool isAuthenticated;
  final String? username;

  const AuthState({this.isAuthenticated = false, this.username});

  AuthState copyWith({bool? isAuthenticated, String? username}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      username: username ?? this.username,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _checkSession();
  }

  static const _sessionKey = 'admin_session';
  // SHA-256 of 'admin123'
  static const _passwordHash =
      '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9';

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final session = prefs.getString(_sessionKey);
    if (session != null) {
      state = AuthState(isAuthenticated: true, username: 'admin');
    }
  }

  Future<bool> login(String username, String password) async {
    if (username != 'admin') return false;
    final hash = sha256.convert(utf8.encode(password)).toString();
    if (hash != _passwordHash) return false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, 'authenticated');
    state = AuthState(isAuthenticated: true, username: username);
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    state = const AuthState();
  }
}
