import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    // Expecting a Map<String, dynamic> with user profile fields
    final Map<String, dynamic>? profile = args is Map<String, dynamic>
        ? args
        : null;

    final String displayName =
        profile?['full_name'] ?? profile?['name'] ?? 'User';
    final String branch =
        profile?['branch'] ?? profile?['branch_id']?.toString() ?? '-';
    final String position = profile?['position'] ?? profile?['section'] ?? '-';
    final String userId = profile?['id'] ?? '-';

    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $displayName',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text('ID: $userId'),
            const SizedBox(height: 8),
            Text('Branch: $branch'),
            const SizedBox(height: 8),
            Text('Position: $position'),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'This is the home screen. Replace with your app content.',
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                // log out and clear remembered flags
                final navigator = Navigator.of(context);
                await Supabase.instance.client.auth.signOut();
                try {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('remember_me');
                  await prefs.remove('remember_user_id');
                } catch (_) {}
                navigator.pushReplacementNamed('/');
              },
              child: const Text("Log out"),
            ),
          ],
        ),
      ),
    );
  }
}
