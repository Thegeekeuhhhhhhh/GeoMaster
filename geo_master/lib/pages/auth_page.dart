import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthPage extends StatefulWidget {
  final bool isModal;

  const AuthPage({super.key, this.isModal = false});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitEmailPassword() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_isLogin) {
        await AuthService.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await AuthService.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _submitOAuth(Future<void> Function() method) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await method();
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text(
            _isLogin ? 'Welcome back' : 'Create account',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _isLogin
                ? 'Sign in to save your scores.'
                : 'Sign up to track your progress.',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),

          // Email field
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 14),

          // Password field
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.lock_outline),
            ),
            onSubmitted: (_) => _submitEmailPassword(),
          ),
          const SizedBox(height: 6),

          // Error message
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _error!,
                style: TextStyle(color: colorScheme.error, fontSize: 13),
              ),
            ),

          const SizedBox(height: 20),

          // Submit button
          ElevatedButton(
            onPressed: _loading ? null : _submitEmailPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _loading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: colorScheme.onPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _isLogin ? 'Sign In' : 'Sign Up',
                    style: const TextStyle(fontSize: 16),
                  ),
          ),

          const SizedBox(height: 20),

          // Divider
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),

          const SizedBox(height: 20),

          // Google button
          OutlinedButton.icon(
            onPressed: _loading
                ? null
                : () => _submitOAuth(AuthService.signInWithGoogle),
            icon: const Text(
              'G',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(
                  0xFF4285F4,
                ), // Google brand intentionally hardcoded
              ),
            ),
            label: const Text('Continue with Google'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.onSurface,
              side: BorderSide(color: colorScheme.outlineVariant),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Apple button only on iOS/macOS
          if (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _loading
                  ? null
                  : () => _submitOAuth(AuthService.signInWithApple),
              icon: Icon(Icons.apple, color: colorScheme.onSurface),
              label: const Text('Continue with Apple'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.onSurface,
                side: BorderSide(color: colorScheme.outlineVariant),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Toggle login / signup
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isLogin ? "Don't have an account? " : 'Already have one? ',
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
              ),
              GestureDetector(
                onTap: () => setState(() {
                  _isLogin = !_isLogin;
                  _error = null;
                }),
                child: Text(
                  _isLogin ? 'Sign Up' : 'Sign In',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Skip option when shown as modal
          if (widget.isModal) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Continue as guest',
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
              ),
            ),
          ],
        ],
      ),
    );

    if (widget.isModal) {
      return content;
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(child: content),
    );
  }
}
