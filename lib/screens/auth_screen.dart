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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              InkWell(
                onTap: () => _handleSignIn(
                  () => context.read<AuthProvider>().signInWithGoogle(),
                ),
                child: Image.asset(
                  'assets/auth/google_login_icon.png',
                  height: 52,
                ),
              ),
              InkWell(
                onTap: () => _handleSignIn(
                  () => context.read<AuthProvider>().signInWithKakao(),
                ),
                child: Image.asset(
                  'assets/auth/kakao_login_icon.png',
                  height: 52,
                ),
              ),
              InkWell(
                onTap: () => _handleSignIn(
                  () => context.read<AuthProvider>().signInWithNaver(),
                ),
                child: Image.asset(
                  'assets/auth/naver_login_icon.png',
                  height: 52,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
