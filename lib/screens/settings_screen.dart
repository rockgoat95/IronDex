import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoggedIn = authProvider.isLoggedIn;
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('로그인 상태', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(
                  isLoggedIn ? Icons.verified_user : Icons.person_off,
                  color: isLoggedIn
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[500],
                ),
                title: Text(isLoggedIn ? '로그인됨' : '로그아웃됨'),
                subtitle: isLoggedIn && user != null
                    ? Text(user.email ?? user.id)
                    : const Text('세션 정보 없음'),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('로그아웃'),
                onPressed: isLoggedIn
                    ? () async {
                        await authProvider.signOut();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('로그아웃 되었습니다.')),
                        );
                      }
                    : null,
              ),
            ),
            if (!isLoggedIn) ...[
              const SizedBox(height: 12),
              const Text('현재 로그인이 되어 있지 않습니다. 디버깅을 위해 인증 화면으로 이동하세요.'),
            ],
          ],
        ),
      ),
    );
  }
}
