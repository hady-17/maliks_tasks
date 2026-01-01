import 'package:flutter/material.dart';
import '../../viewmodels/admin_ViewModel.dart';
import '../../model/profileModel.dart';

class Adminscreen extends StatefulWidget {
  const Adminscreen({super.key});

  @override
  State<Adminscreen> createState() => _AdminscreenState();
}

class _AdminscreenState extends State<Adminscreen> {
  final ProfilesRepository _repo = ProfilesRepository();
  String? _activatingId;

  Future<void> _activateProfile(String id) async {
    setState(() => _activatingId = id);
    try {
      await _repo.activateUser(id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile activated')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Activation failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _activatingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inactive Profiles')),
      body: StreamBuilder<List<Profile>>(
        stream: _repo.streamInactiveProfiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final profiles = snapshot.data ?? [];

          if (profiles.isEmpty) {
            return const Center(child: Text('No inactive users'));
          }

          return ListView.separated(
            itemCount: profiles.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final profile = profiles[index];
              final activating = _activatingId == profile.id;

              return ListTile(
                title: Text(profile.fullName ?? 'No name'),
                subtitle: Text('${profile.role} • ${profile.section}'),
                trailing: activating
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        tooltip: 'Activate profile',
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        onPressed: () => _activateProfile(profile.id),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
