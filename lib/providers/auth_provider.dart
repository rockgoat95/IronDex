import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = Supabase.instance.client.auth.currentSession != null;
  bool get isLoggedIn => _isLoggedIn;

  Future<bool> _signInWithOAuth(OAuthProvider provider) async {
    try {
      final result = await Supabase.instance.client.auth.signInWithOAuth(
        provider,
        redirectTo: kIsWeb ? null : 'ai.smartfitness.irondex://login-callback/',
      );
      if (result) {
        _isLoggedIn = true;
        notifyListeners();
      }
      return result;
    } catch (e) {
      debugPrint('Error signing in with OAuth: $e');
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
      _isLoggedIn = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }
}
