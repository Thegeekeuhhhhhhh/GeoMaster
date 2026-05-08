import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _client = Supabase.instance.client;

  static User? get currentUser => _client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;

  static Stream<AuthState> get authStateStream =>
      _client.auth.onAuthStateChange;

  static Future<void> signUpWithEmail(String email, String password) async {
    final res = await _client.auth.signUp(email: email, password: password);
    if (res.user == null) {
      throw Exception('Sign up failed check email.');
    }
  }

  static Future<void> signInWithEmail(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.geomaster://login-callback',
    );
  }

  static Future<void> signInWithApple() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'io.supabase.geomaster://login-callback',
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
