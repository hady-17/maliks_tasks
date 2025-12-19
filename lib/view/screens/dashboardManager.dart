import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/manager_metrics_provider.dart';
import '../widgets/appBar.dart';
import '../widgets/navBar.dart';

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
      bottomNavigationBar: ModernNavBar(currentIndex: 0, onTap: (_) {}),
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
          _KpiGrid(metrics: metrics),
          const SizedBox(height: 24),
          _buildAverageRow(metrics),
          const SizedBox(height: 24),
          _PerformanceChart(metrics: metrics, showTasks: _showTasks),
          const SizedBox(height: 24),
          _PerformanceTable(metrics: metrics),
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
        childAspectRatio: 2.2,
      ),
      children: [
        _KpiCard(
          title: 'Tasks Placed',
          value: metrics.totalTasksPlaced.toString(),
          icon: Icons.playlist_add,
        ),
        _KpiCard(
          title: 'Tasks Done',
          value: metrics.totalTasksDone.toString(),
          icon: Icons.check_circle,
        ),
        _KpiCard(
          title: 'Orders Placed',
          value: metrics.totalOrdersPlaced.toString(),
          icon: Icons.shopping_cart,
        ),
        _KpiCard(
          title: 'Orders Done',
          value: metrics.totalOrdersDone.toString(),
          icon: Icons.done_all,
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 10),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Icon(icon, size: 22),
              ],
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
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

class _PerformanceChart extends StatelessWidget {
  final ManagerMetricsProvider metrics;
  final bool showTasks;
  const _PerformanceChart({required this.metrics, required this.showTasks});

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
    if (members.isEmpty) return const Center(child: Text('No data'));

    final sorted = members.toList();
    sorted.sort((a, b) {
      final aTotal = showTasks
          ? (a.tasksPlaced + a.tasksDone)
          : (b.ordersPlaced + b.ordersDone);
      final bTotal = showTasks
          ? (b.tasksPlaced + b.tasksDone)
          : (b.ordersPlaced + b.ordersDone);
      return bTotal.compareTo(aTotal);
    });
    final top = sorted.take(6).toList();

    return ListView.builder(
      itemCount: top.length,
      itemBuilder: (context, index) {
        final m = top[index];
        final placed = showTasks ? m.tasksPlaced : m.ordersPlaced;
        final done = showTasks ? m.tasksDone : m.ordersDone;
        final total = placed > 0 ? placed : 1;
        final donePercent = (done / total * 100).clamp(0, 100);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      m.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$done/$placed',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Stack(
                children: [
                  Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: donePercent / 100,
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: showTasks ? Colors.blue : Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          '${donePercent.toStringAsFixed(0)}%',
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
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ------------------------------------------------------
/// MEMBERS PERFORMANCE TABLE
/// ------------------------------------------------------

class _PerformanceTable extends StatefulWidget {
  final ManagerMetricsProvider metrics;
  const _PerformanceTable({required this.metrics});

  @override
  State<_PerformanceTable> createState() => _PerformanceTableState();
}

class _PerformanceTableState extends State<_PerformanceTable> {
  int _sortColumn = 0;
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detailed Performance',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            sortColumnIndex: _sortColumn,
            sortAscending: _sortAscending,
            columns: [
              DataColumn(
                label: const Text('Member'),
                onSort: (col, asc) => _sort(col, asc, (m) => m.name),
              ),
              DataColumn(
                label: const Text('Tasks'),
                numeric: true,
                onSort: (col, asc) => _sort(col, asc, (m) => m.tasksDone),
              ),
              DataColumn(
                label: const Text('Orders'),
                numeric: true,
                onSort: (col, asc) => _sort(col, asc, (m) => m.ordersDone),
              ),
              DataColumn(
                label: const Text('Avg Task (m)'),
                numeric: true,
                onSort: (col, asc) =>
                    _sort(col, asc, (m) => m.avgTaskCompletionMinutes),
              ),
              DataColumn(
                label: const Text('Avg Order (m)'),
                numeric: true,
                onSort: (col, asc) =>
                    _sort(col, asc, (m) => m.avgOrderCompletionMinutes),
              ),
            ],
            rows: widget.metrics.memberMetrics.map((m) {
              return DataRow(
                cells: [
                  DataCell(Text(m.name)),
                  DataCell(Text('${m.tasksDone}/${m.tasksPlaced}')),
                  DataCell(Text('${m.ordersDone}/${m.ordersPlaced}')),
                  DataCell(Text(m.avgTaskCompletionMinutes.toStringAsFixed(1))),
                  DataCell(
                    Text(m.avgOrderCompletionMinutes.toStringAsFixed(1)),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _sort<T>(
    int col,
    bool asc,
    Comparable<T> Function(MemberMetric) getField,
  ) {
    setState(() {
      _sortColumn = col;
      _sortAscending = asc;
      widget.metrics.memberMetrics.sort((a, b) {
        final aField = getField(a) as Comparable?;
        final bField = getField(b) as Comparable?;
        if (aField == null && bField == null) return 0;
        if (aField == null) return asc ? -1 : 1;
        if (bField == null) return asc ? 1 : -1;
        return asc ? aField.compareTo(bField) : bField.compareTo(aField);
      });
    });
  }
}
