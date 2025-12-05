import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/appBar.dart';
import '../widgets/navBar.dart';

/// Simple profile page that accepts a `profile` Map either via the
/// constructor or via route arguments. Useful after login/sign-in to
/// show user information.
class ProfilePage extends StatelessWidget {
  final _cPage = 4;
  final Map<String, dynamic>? profile;
  const ProfilePage({super.key, this.profile});

  Map<String, dynamic>? _resolveProfile(BuildContext context) {
    if (profile != null) return profile;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) return args;
    return null;
  }

  Future<void> _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('remember_me');
      await prefs.remove('remember_user_id');
    } catch (_) {}
    if (context.mounted) Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final p = _resolveProfile(context);
    print('profile: $p');

    if (p == null) {
      return const Scaffold(body: Center(child: Text('No profile provided')));
    }

    final displayName = p['full_name'] ?? p['name'] ?? p['email'] ?? 'User';
    final email = p['email'] ?? '—';
    final id = p['id'] ?? '—';
    final branch = p['branch_id'] ?? '—';
    final section = p['section'] ?? '—';
    final role = p['role'] ?? '—';

    return Scaffold(
      appBar: ModernAppBar(
        title: 'Profile',
        subtitle: 'View and edit your profile information',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.grey.shade200,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 24, color: Colors.black87),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _infoRow('ID', id),
            const SizedBox(height: 8),
            _infoRow('Branch', branch),
            const SizedBox(height: 8),
            _infoRow('Section', section),
            const SizedBox(height: 8),
            _infoRow('Role', role),

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                    ),
                    onPressed: () => _signOut(context),
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: navigate to profile edit screen if present
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: ModernNavBar(
          currentIndex: _cPage,
          onTap: (index) {
            if (index == 1) {
            } else if (index == 2) {
              Navigator.pushNamed(context, '/create_task', arguments: p);
            } else if (index == 3) {
              print('pressed on $index');
            } else if (index == 4) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/profile',
                (route) => false,
                arguments: p,
              );
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
                arguments: p,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}
