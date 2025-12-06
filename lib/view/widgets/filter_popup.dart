import 'package:flutter/material.dart';

/// A simple dialog wrapper that ensures a Material context for popup content.
class FilterPopup extends StatelessWidget {
  final Widget child;
  final VoidCallback? onApply;
  final VoidCallback? onCancel;

  const FilterPopup({Key? key, required this.child, this.onApply, this.onCancel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filter Tasks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(child: child),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      if (onCancel != null) onCancel!();
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (onApply != null) onApply!();
                      Navigator.pop(context);
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// TaskFilter widget: select status (both/open/done) and priorities.
class TaskFilter extends StatefulWidget {
  final String initialStatus; // 'both' | 'open' | 'done'
  final Set<String> initialPriorities;
  final ValueChanged<Map<String, dynamic>>? onChanged;

  const TaskFilter({
    Key? key,
    this.initialStatus = 'both',
    this.initialPriorities = const {'normal'},
    this.onChanged,
  }) : super(key: key);

  @override
  State<TaskFilter> createState() => _TaskFilterState();
}

class _TaskFilterState extends State<TaskFilter> {
  late String _status;
  late Set<String> _priorities;

  static const List<String> _prioritiesAll = ['low', 'normal', 'high'];

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _priorities = Set<String>.from(widget.initialPriorities);
    _notify();
  }

  void _notify() {
    widget.onChanged?.call({'status': _status, 'priorities': _priorities.toList()});
  }

  void _togglePriority(String p) {
    setState(() {
      if (_priorities.contains(p)) {
        _priorities.remove(p);
        if (_priorities.isEmpty) _priorities.add('normal');
      } else {
        _priorities.add(p);
      }
      _notify();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
        RadioListTile<String>(
          contentPadding: EdgeInsets.zero,
          title: const Text('Both'),
          value: 'both',
          groupValue: _status,
          onChanged: (v) => setState(() {
            _status = v!;
            _notify();
          }),
        ),
        RadioListTile<String>(
          contentPadding: EdgeInsets.zero,
          title: const Text('Open'),
          value: 'open',
          groupValue: _status,
          onChanged: (v) => setState(() {
            _status = v!;
            _notify();
          }),
        ),
        RadioListTile<String>(
          contentPadding: EdgeInsets.zero,
          title: const Text('Done'),
          value: 'done',
          groupValue: _status,
          onChanged: (v) => setState(() {
            _status = v!;
            _notify();
          }),
        ),
        const SizedBox(height: 12),
        const Text('Priority', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _prioritiesAll.map((p) {
            final selected = _priorities.contains(p);
            return ChoiceChip(
              label: Text(p[0].toUpperCase() + p.substring(1)),
              selected: selected,
              onSelected: (_) => _togglePriority(p),
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
            );
          }).toList(),
        ),
      ],
    );
  }
}

