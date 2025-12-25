import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view/widgets/appBar.dart';
import '../../viewmodels/member_dashboard_viewmodel.dart';
import '../../viewmodels/manager_metrics_provider.dart';

class memeberDashBoardscreen extends StatefulWidget {
  const memeberDashBoardscreen({super.key});

  @override
  State<memeberDashBoardscreen> createState() => _memeberDashBoardscreenState();
}

class _memeberDashBoardscreenState extends State<memeberDashBoardscreen> {
  Map<String, dynamic>? _resolveProfile(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) return args;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final profile = _resolveProfile(context);

    return ChangeNotifierProvider(
      create: (_) {
        final vm = MemberDashboardViewModel();
        if (profile != null) vm.initWithProfile(profile);
        return vm;
      },
      child: Consumer<MemberDashboardViewModel>(
        builder: (context, vm, _) {
          final m =
              vm.memberMetric ??
              MemberMetric(
                userId: profile?['id'] ?? '',
                name: profile?['full_name'] ?? 'You',
              );

          return Scaffold(
            appBar: ModernAppBar(
              isManager: false,
              title: 'Member Dashboard',
              subtitle: profile?['full_name'] ?? 'Your activity',
            ),
            body: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async => vm.loadFor(profile ?? {}),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildKpiRow(m),
                          const SizedBox(height: 16),
                          _buildAverages(m),
                          const SizedBox(height: 24),
                          const Text(
                            'Recent Tasks',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          vm.recentTasks.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Text('No tasks found'),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: vm.recentTasks.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (ctx, i) {
                                    final t = vm.recentTasks[i];
                                    return ListTile(
                                      title: Text(t['title'] ?? '(no title)'),
                                      subtitle: Text(
                                        '${t['priority'] ?? ''} • ${t['task_date'] ?? ''}',
                                      ),
                                      trailing: Text(t['status'] ?? ''),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildKpiRow(MemberMetric m) {
    return Row(
      children: [
        Expanded(child: _infoCard('Tasks Placed', m.tasksPlaced.toString())),
        const SizedBox(width: 12),
        Expanded(child: _infoCard('Tasks Done', m.tasksDone.toString())),
      ],
    );
  }

  Widget _buildAverages(MemberMetric m) {
    return Row(
      children: [
        Expanded(
          child: _infoCard(
            'Avg Task (m)',
            m.avgTaskCompletionMinutes.toStringAsFixed(1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _infoCard('Orders Done', m.ordersDone.toString())),
      ],
    );
  }

  Widget _infoCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
