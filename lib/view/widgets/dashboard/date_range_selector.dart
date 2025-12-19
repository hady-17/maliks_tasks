import 'package:flutter/material.dart';

/// Date Range Selector Widget
class DateRangeSelector extends StatelessWidget {
  final DateTimeRange dateRange;
  final VoidCallback onPressed;

  const DateRangeSelector({
    super.key,
    required this.dateRange,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: Text(
          _formatDateRange(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: onPressed,
        ),
      ),
    );
  }

  String _formatDateRange() {
    final start = dateRange.start.toString().split(' ').first;
    final end = dateRange.end.toString().split(' ').first;
    return '$start → $end';
  }
}

/// Toggle Selector for Tasks/Orders
class MetricTypeSelector extends StatelessWidget {
  final bool showTasks;
  final ValueChanged<bool> onChanged;

  const MetricTypeSelector({
    super.key,
    required this.showTasks,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => onChanged(true),
            icon: const Icon(Icons.task_alt),
            label: const Text('Tasks'),
            style: _buttonStyle(context, showTasks),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => onChanged(false),
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Orders'),
            style: _buttonStyle(context, !showTasks),
          ),
        ),
      ],
    );
  }

  ButtonStyle _buttonStyle(BuildContext context, bool isSelected) {
    return ElevatedButton.styleFrom(
      backgroundColor: isSelected
          ? Theme.of(context).primaryColor
          : Colors.grey[300],
      foregroundColor: isSelected ? Colors.white : Colors.black,
    );
  }
}
