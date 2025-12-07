import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/appBar.dart';
import '../widgets/navBar.dart';

/// Modern Profile page
class ProfilePage extends StatelessWidget {
  final int _cPage = 4;
  final Map<String, dynamic>? profile;
  const ProfilePage({super.key, this.profile});

  Map<String, dynamic>? _resolveProfile(BuildContext context) {
    if (profile != null) return profile;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) return args;
    if (args is Map) return Map<String, dynamic>.from(args);
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

  Future<String> _fetchBranchName(String branchId) async {
    if (branchId.isEmpty || branchId == '—') return branchId;
    try {
      final res = await Supabase.instance.client
          .from('branches')
          .select()
          .eq('id', branchId)
          .maybeSingle();

      if (res != null) {
        final map = Map<String, dynamic>.from(res);
        if (map.containsKey('name') && map['name'] != null) {
          return map['name'].toString();
        }
      }
    } catch (_) {}
    return branchId;
  }

  @override
  Widget build(BuildContext context) {
    final p = _resolveProfile(context);
    if (p == null)
      return const Scaffold(body: Center(child: Text('No profile provided')));

    final displayName = p['full_name'] ?? p['name'] ?? p['email'] ?? 'User';
    final email = p['email'] ?? '—';
    final branch = p['branch_id'] ?? '—';
    final section = p['section'] ?? '—';
    final role = p['role'] ?? '—';

    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final topInset = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: ModernAppBar(
        title: 'Profile',
        subtitle: 'View and edit your profile information',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, topInset + 85, 20, 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade900, Colors.red.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white24,
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(fontSize: 28, color: Colors.white),
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
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          email,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      // TODO: edit profile
                    },
                  ),
                ],
              ),
            ),

            // Info card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18.0,
                    horizontal: 12.0,
                  ),
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          // Email tile
                          _infoTile(
                            context,
                            'Email',
                            email,
                            Icons.email_rounded,
                          ),
                          // Branch: fetch human readable name via API
                          FutureBuilder<String>(
                            future: _fetchBranchName(branch),
                            builder: (context, snap) {
                              final b =
                                  (snap.connectionState ==
                                          ConnectionState.done &&
                                      snap.data != null)
                                  ? snap.data!
                                  : branch;
                              return _infoTile(
                                context,
                                'Branch',
                                b,
                                Icons.location_city_rounded,
                              );
                            },
                          ),
                          _infoTile(
                            context,
                            'Section',
                            section,
                            Icons.view_column_rounded,
                          ),
                          _infoTile(context, 'Role', role, Icons.badge_rounded),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // actions
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => _signOut(context),
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Sign Out',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () {
                              // TODO: navigate to profile edit screen
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Edit'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // spacing so actions are not obscured by bottom nav
            SizedBox(height: 70 + bottomInset + 8),
          ],
        ),
      ),
      bottomNavigationBar: ModernNavBar(
        currentIndex: _cPage,
        onTap: (index) {
          if (role == 'manager') {
            if (index == 1) {
            } else if (index == 2) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/manager_create_task',
                (route) => false,
                arguments: p,
              );
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
                '/manager_home',
                (route) => false,
                arguments: p,
              );
            }
            return;
          } else {
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
          }
          ;
        },
      ),
    );
  }

  Widget _infoTile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final screenW = MediaQuery.of(context).size.width;
    final tileW = (screenW * 0.8) > 600 ? 600.0 : (screenW * 0.8);

    return Container(
      width: tileW,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
