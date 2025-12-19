import 'package:flutter/material.dart';
import '../../../viewmodels/manager_metrics_provider.dart';

/// KPI Card Component
class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28),
            const Spacer(),
            Text(title, style: const TextStyle(fontSize: 12)),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

/// KPI Grid Component
class KpiGrid extends StatelessWidget {
  final ManagerMetricsProvider metrics;

  const KpiGrid({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
      ),
      children: [
        KpiCard(
          title: 'Tasks Placed',
          value: metrics.totalTasksPlaced.toString(),
          icon: Icons.playlist_add,
        ),
        KpiCard(
          title: 'Tasks Done',
          value: metrics.totalTasksDone.toString(),
          icon: Icons.check_circle,
        ),
        KpiCard(
          title: 'Orders Placed',
          value: metrics.totalOrdersPlaced.toString(),
          icon: Icons.shopping_cart,
        ),
        KpiCard(
          title: 'Orders Done',
          value: metrics.totalOrdersDone.toString(),
          icon: Icons.done_all,
        ),
      ],
    );
  }
}

/// Info Card for Averages
class InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const InfoCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

/// Average Completion Times Row
class AverageCompletionRow extends StatelessWidget {
  final ManagerMetricsProvider metrics;

  const AverageCompletionRow({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InfoCard(
            title: 'Avg Task Completion',
            value: '${metrics.avgTaskCompletionMinutes.toStringAsFixed(1)} min',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InfoCard(
            title: 'Avg Order Completion',
            value:
                '${metrics.avgOrderCompletionMinutes.toStringAsFixed(1)} min',
          ),
        ),
      ],
    );
  }
}
