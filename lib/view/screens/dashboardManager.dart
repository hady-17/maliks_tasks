import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/manager_metrics_provider.dart';
import '../../view/widgets/dashboard/kpi_cards.dart';
import '../../view/widgets/dashboard/performance_chart.dart';
import '../../view/widgets/dashboard/performance_table.dart';
import '../widgets/appBar.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 6)),
    end: DateTime.now(),
  );
  bool _showTasks = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMetrics());
  }

  Future<void> _loadMetrics() async {
    final provider = context.read<ManagerMetricsProvider>();
    final profile =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    await provider.loadMetrics(
      branchId: profile['branch_id'],
      from: _dateRange.start,
      to: _dateRange.end,
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
      _loadMetrics();
    }
  }

  @override
  Widget build(BuildContext context) {
    final metrics = context.watch<ManagerMetricsProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: ModernAppBar(
        isManager: true,
        title: 'Manager Dashboard',
        subtitle: 'Team Performance Analytics',
        showDashboardButton: false,
        showBackButton: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withValues(alpha: 0.08),
              colorScheme.secondary.withValues(alpha: 0.06),
              colorScheme.surface,
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _loadMetrics,
          child: metrics.isLoading
              ? const Center(child: CircularProgressIndicator())
              : metrics.error != null
              ? _buildError(metrics.error!)
              : metrics.memberMetrics.isEmpty
              ? _buildEmpty()
              : _buildContent(metrics),
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadMetrics,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No metrics available',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ManagerMetricsProvider metrics) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateRangeSelector(),
          const SizedBox(height: 16),
          _buildMetricTypeSelector(),
          const SizedBox(height: 24),
          KpiGrid(metrics: metrics),
          const SizedBox(height: 24),
          _buildAverageRow(metrics),
          const SizedBox(height: 24),
          PerformanceChart(metrics: metrics, showTasks: _showTasks),
          const SizedBox(height: 24),
          PerformanceTable(metrics: metrics),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today, size: 20),
        title: Text(
          '${_dateRange.start.toString().split(' ').first} → ${_dateRange.end.toString().split(' ').first}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, size: 20),
          onPressed: _pickDateRange,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ),
    );
  }

  Widget _buildMetricTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => setState(() => _showTasks = true),
            icon: const Icon(Icons.task_alt),
            label: const Text('Tasks'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _showTasks
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300],
              foregroundColor: _showTasks ? Colors.white : Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => setState(() => _showTasks = false),
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Orders'),
            style: ElevatedButton.styleFrom(
              backgroundColor: !_showTasks
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300],
              foregroundColor: !_showTasks ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAverageRow(ManagerMetricsProvider metrics) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            'Avg Task Completion',
            '${metrics.avgTaskCompletionMinutes.toStringAsFixed(1)} min',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            'Avg Order Completion',
            '${metrics.avgOrderCompletionMinutes.toStringAsFixed(1)} min',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final ManagerMetricsProvider metrics;
  const _KpiGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
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
