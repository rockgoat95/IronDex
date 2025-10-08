import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  static const String _redirectUrl = 'ai.smartfitness.irondex://login-callback';

  AuthProvider() {
    _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange
        .listen((data) => _updateAuthState(data.session));
  }

  bool _isLoggedIn = Supabase.instance.client.auth.currentSession != null;
  bool get isLoggedIn => _isLoggedIn;

  User? get currentUser => Supabase.instance.client.auth.currentUser;

  StreamSubscription<AuthState>? _authStateSubscription;

  void _updateAuthState(Session? session) {
    final nextState = session != null;
    if (_isLoggedIn != nextState) {
      _isLoggedIn = nextState;
      notifyListeners();
    }
  }

  Future<bool> _signInWithOAuth(OAuthProvider provider) async {
    try {
      final result = await Supabase.instance.client.auth.signInWithOAuth(
        provider,
        redirectTo: kIsWeb ? null : _redirectUrl,
      );
      if (kIsWeb) {
        _updateAuthState(Supabase.instance.client.auth.currentSession);
      }
      return result == true;
    } catch (e, stackTrace) {
      debugPrint('Error signing in with OAuth: $e');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    return await _signInWithOAuth(OAuthProvider.google);
  }

  Future<bool> signInWithKakao() async {
    return await _signInWithOAuth(OAuthProvider.kakao);
  }

  Future<bool> signInWithNaver() async {
    // Supabase SDK doesn't have a built-in Naver provider enum, so we pass it as a string.
    return await _signInWithOAuth(
      OAuthProvider.values.firstWhere(
        (p) => p.name == 'naver',
        orElse: () => OAuthProvider.google,
      ),
    );
  }

  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      _updateAuthState(Supabase.instance.client.auth.currentSession);
    } catch (e, stackTrace) {
      debugPrint('Error signing out: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
