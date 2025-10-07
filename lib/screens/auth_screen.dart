import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> _signInWithOAuth(
    OAuthProvider provider, {
    String? scopes,
  }) async {
    try {
      await _supabase.auth.signInWithOAuth(
        provider,
        // The redirectTo URL must be configured in your Supabase dashboard.
        // It is required for mobile platforms for the authentication flow to bring
        // the user back to the app.
        redirectTo: kIsWeb
            ? null
            : 'io.supabase.flutterquickstart://login-callback/',
        scopes: scopes,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('로그인 중 오류가 발생했습니다: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IronDex 로그인')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () => _signInWithOAuth(OAuthProvider.google),
                child: const Text('Google로 로그인'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _signInWithOAuth(OAuthProvider.kakao),
                child: const Text('Kakao로 로그인'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _signInWithOAuth('naver' as OAuthProvider),
                child: const Text('Naver로 로그인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
