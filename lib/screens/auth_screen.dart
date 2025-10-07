import 'package:IronDex/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

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
                onPressed: () =>
                    context.read<AuthProvider>().signInWithGoogle(),
                child: const Text('Google로 로그인'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.read<AuthProvider>().signInWithKakao(),
                child: const Text('Kakao로 로그인'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.read<AuthProvider>().signInWithNaver(),
                child: const Text('Naver로 로그인'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
