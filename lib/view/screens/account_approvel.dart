import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/appBar.dart';
import '../../viewmodels/account_approvel.viewmodel.dart';

class AccountApprovel extends StatelessWidget {
  const AccountApprovel({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AccountApprovelViewModel()..loadForCurrentManager(),
      child: const _AccountApprovelContent(),
    );
  }
}

class _AccountApprovelContent extends StatelessWidget {
  const _AccountApprovelContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AccountApprovelViewModel>();

    return Scaffold(
      appBar: const ModernAppBar(
        title: 'Account Approval Pending',
        isManager: true,
      ),
      body: SafeArea(
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : vm.inactiveUsers.isEmpty
            ? const Center(child: Text('No pending approvals'))
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: vm.inactiveUsers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final u = vm.inactiveUsers[i];
                  final name = u['full_name'] as String? ?? '(no name)';
                  final email = u['email'] as String? ?? '';
                  return Card(
                    child: ListTile(
                      title: Text(name),
                      subtitle: email.isNotEmpty ? Text(email) : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          final ok = await vm.approveUser(u['id'] as String);
                          final messenger = ScaffoldMessenger.of(context);
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                ok ? 'Approved $name' : 'Approve failed',
                              ),
                              backgroundColor: ok ? Colors.green : Colors.red,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
