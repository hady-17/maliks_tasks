import 'package:flutter/material.dart';
import '../../../viewmodels/manager_metrics_provider.dart';

/// Performance Chart showing member metrics
class PerformanceChart extends StatelessWidget {
  final ManagerMetricsProvider metrics;
  final bool showTasks;

  const PerformanceChart({
    super.key,
    required this.metrics,
    required this.showTasks,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              showTasks ? 'Tasks Performance' : 'Orders Performance',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _PerformanceBarChart(
                members: metrics.memberMetrics,
                showTasks: showTasks,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceBarChart extends StatelessWidget {
  final List<MemberMetric> members;
  final bool showTasks;

  const _PerformanceBarChart({required this.members, required this.showTasks});

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final topMembers = _getTopMembers();

    return ListView.builder(
      itemCount: topMembers.length,
      itemBuilder: (context, index) => _buildMemberBar(topMembers[index]),
    );
  }

  List<MemberMetric> _getTopMembers() {
    final sorted = members.toList();
    sorted.sort((a, b) => _getTotalActivity(b).compareTo(_getTotalActivity(a)));
    return sorted.take(6).toList();
  }

  int _getTotalActivity(MemberMetric member) {
    return showTasks
        ? (member.tasksPlaced + member.tasksDone)
        : (member.ordersPlaced + member.ordersDone);
  }

  Widget _buildMemberBar(MemberMetric member) {
    final placed = showTasks ? member.tasksPlaced : member.ordersPlaced;
    final done = showTasks ? member.tasksDone : member.ordersDone;
    final percentage = _calculatePercentage(done, placed);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMemberInfo(member, done, placed),
          const SizedBox(height: 4),
          _buildProgressBar(percentage),
        ],
      ),
    );
  }

  Widget _buildMemberInfo(MemberMetric member, int done, int placed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            _truncateName(member.name),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          '$done/$placed',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double percentage) {
    return Stack(
      children: [
        Container(
          height: 24,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        FractionallySizedBox(
          widthFactor: percentage / 100,
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              color: showTasks ? Colors.blue : Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                '${percentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _calculatePercentage(int done, int placed) {
    final total = placed > 0 ? placed : 1;
    return (done / total * 100).clamp(0, 100);
  }

  String _truncateName(String name) {
    return name.length > 20 ? '${name.substring(0, 20)}...' : name;
  }
}
