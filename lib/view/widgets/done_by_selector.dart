import 'package:flutter/material.dart';

/// A small dropdown selector for managers to attribute a completed task to a user.
///
/// Usage:
/// - Provide `members` as a list of maps with keys `id` and `name` (as provided
///   by `ManagerCreateTaskVM.fetchMembers`).
/// - Provide `managerId` (the current manager's user id) so the widget can show
///   "Manager (you)" as an option.
/// - `onChanged` will be called with the selected user's id, or `null` when the
///   "Leave unchanged" option is selected.
class DoneBySelector extends StatefulWidget {
  final List<Map<String, String>> members;
  final String managerId;
  final String? initialSelectedId;
  final ValueChanged<String?> onChanged;

  const DoneBySelector({
    Key? key,
    required this.members,
    required this.managerId,
    this.initialSelectedId,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<DoneBySelector> createState() => _DoneBySelectorState();
}

class _DoneBySelectorState extends State<DoneBySelector> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialSelectedId;
  }

  List<DropdownMenuItem<String?>> _buildItems() {
    final List<DropdownMenuItem<String?>> items = [];

    // Leave unchanged option (represented by null)
    items.add(
      const DropdownMenuItem<String?>(
        value: null,
        child: Text('Leave unchanged'),
      ),
    );

    // Manager (you)
    items.add(
      DropdownMenuItem<String?>(
        value: widget.managerId,
        child: Text('Manager (you)'),
      ),
    );

    // Member entries (avoid duplicating the manager id)
    for (final m in widget.members) {
      final id = m['id'];
      final name = m['name'] ?? '(no name)';
      if (id == null) continue;
      if (id == widget.managerId) continue; // already added
      items.add(DropdownMenuItem<String?>(value: id, child: Text(name)));
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      value: _selectedId,
      items: _buildItems(),
      decoration: const InputDecoration(
        labelText: 'Mark done by',
        helperText:
            'Choose who completed this task (Leave unchanged to keep current)',
      ),
      onChanged: (v) {
        setState(() => _selectedId = v);
        widget.onChanged(v);
      },
    );
  }
}
