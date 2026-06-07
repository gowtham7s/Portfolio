import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/glass_card.dart';

class AdminLoginPage extends ConsumerStatefulWidget {
  const AdminLoginPage({super.key});

  @override
  ConsumerState<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends ConsumerState<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final success = await ref.read(authProvider.notifier).login(
          _usernameCtrl.text.trim(),
          _passwordCtrl.text,
        );

    if (!mounted) return;
    setState(() => _loading = false);

    if (success) {
      context.go('/admin');
    } else {
      setState(() => _errorMessage = 'Invalid username or password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                ShaderMask(
                  shaderCallback: (b) =>
                      AppTheme.primaryGradient.createShader(b),
                  child: Text(
                    'GS.',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Admin Portal',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 40),
                GlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          'Sign In',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 24),
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppTheme.error.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_rounded,
                                    color: AppTheme.error, size: 16),
                                const SizedBox(width: 8),
                                Text(_errorMessage!,
                                    style: const TextStyle(
                                        color: AppTheme.error)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _usernameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person_rounded),
                          ),
                          validator: (v) => (v?.isEmpty ?? true)
                              ? 'Username is required'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon:
                                const Icon(Icons.lock_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) => (v?.isEmpty ?? true)
                              ? 'Password is required'
                              : null,
                          onFieldSubmitted: (_) => _login(),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: _loading
                              ? const Center(
                                  child: CircularProgressIndicator())
                              : GradientButton(
                                  label: 'Sign In',
                                  icon: Icons.login_rounded,
                                  onPressed: _login,
                                  width: double.infinity,
                                ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.go('/'),
                          child: const Text('← Back to Portfolio'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
