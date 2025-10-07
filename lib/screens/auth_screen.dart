import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  Future<void> _handleSignIn(Future<bool> Function() action) async {
    final success = await action();
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 중 오류가 발생했습니다. 다시 시도해주세요.')),
      );
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
                onPressed: () => _handleSignIn(
                  () => context.read<AuthProvider>().signInWithGoogle(),
                ),
                child: const Text('Google로 로그인'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _handleSignIn(
                  () => context.read<AuthProvider>().signInWithKakao(),
                ),
                child: const Text('Kakao로 로그인'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _handleSignIn(
                  () => context.read<AuthProvider>().signInWithNaver(),
                ),
                child: const Text('Naver로 로그인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
