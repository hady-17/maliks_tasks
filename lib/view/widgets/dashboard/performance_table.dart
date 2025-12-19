import 'package:flutter/material.dart';
import '../../../viewmodels/manager_metrics_provider.dart';

/// Detailed Performance Table with sorting
class PerformanceTable extends StatefulWidget {
  final ManagerMetricsProvider metrics;

  const PerformanceTable({super.key, required this.metrics});

  @override
  State<PerformanceTable> createState() => _PerformanceTableState();
}

class _PerformanceTableState extends State<PerformanceTable> {
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
          child: _buildDataTable(),
        ),
      ],
    );
  }

  DataTable _buildDataTable() {
    return DataTable(
      sortColumnIndex: _sortColumn,
      sortAscending: _sortAscending,
      columns: _buildColumns(),
      rows: _buildRows(),
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      DataColumn(
        label: const Text('Member'),
        onSort: (col, asc) => _sortBy(col, asc, (m) => m.name),
      ),
      DataColumn(
        label: const Text('Tasks'),
        numeric: true,
        onSort: (col, asc) => _sortBy(col, asc, (m) => m.tasksDone),
      ),
      DataColumn(
        label: const Text('Orders'),
        numeric: true,
        onSort: (col, asc) => _sortBy(col, asc, (m) => m.ordersDone),
      ),
      DataColumn(
        label: const Text('Avg Task (m)'),
        numeric: true,
        onSort: (col, asc) =>
            _sortBy(col, asc, (m) => m.avgTaskCompletionMinutes),
      ),
      DataColumn(
        label: const Text('Avg Order (m)'),
        numeric: true,
        onSort: (col, asc) =>
            _sortBy(col, asc, (m) => m.avgOrderCompletionMinutes),
      ),
    ];
  }

  List<DataRow> _buildRows() {
    return widget.metrics.memberMetrics.map((member) {
      return DataRow(
        cells: [
          DataCell(Text(member.name)),
          DataCell(Text('${member.tasksDone}/${member.tasksPlaced}')),
          DataCell(Text('${member.ordersDone}/${member.ordersPlaced}')),
          DataCell(Text(member.avgTaskCompletionMinutes.toStringAsFixed(1))),
          DataCell(Text(member.avgOrderCompletionMinutes.toStringAsFixed(1))),
        ],
      );
    }).toList();
  }

  void _sortBy<T>(
    int columnIndex,
    bool ascending,
    Comparable<T> Function(MemberMetric) getField,
  ) {
    setState(() {
      _sortColumn = columnIndex;
      _sortAscending = ascending;
      widget.metrics.memberMetrics.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
    });
  }
}
