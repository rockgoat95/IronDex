import 'package:flutter/material.dart';
import 'package:irondex/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoggedIn = authProvider.isLoggedIn;
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Login Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(
                  isLoggedIn ? Icons.verified_user : Icons.person_off,
                  color: isLoggedIn
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[500],
                ),
                title: Text(isLoggedIn ? 'Logged In' : 'Logged Out'),
                subtitle: isLoggedIn && user != null
                    ? Text(user.email ?? user.id)
                    : const Text('No session information'),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Log Out'),
                onPressed: isLoggedIn
                    ? () async {
                        await authProvider.signOut();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('You have been logged out.'),
                          ),
                        );
                      }
                    : null,
              ),
            ),
            if (!isLoggedIn) ...[
              const SizedBox(height: 12),
              const Text(
                'You are not logged in. Navigate to the authentication screen for debugging.',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
