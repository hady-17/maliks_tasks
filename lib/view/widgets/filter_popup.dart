import 'package:flutter/material.dart';

/// A simple dialog wrapper that ensures a Material context for popup content.
class FilterPopup extends StatelessWidget {
  final Widget child;
  final VoidCallback? onApply;
  final VoidCallback? onCancel;

  const FilterPopup({
    super.key,
    required this.child,
    this.onApply,
    this.onCancel,
  });

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
                  const Text(
                    'Filter Tasks',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Constrain the filter content and make it scrollable so all controls
              // (status, priority, section, member) are reachable on small screens.
              ConstrainedBox(
                constraints: BoxConstraints(
                  // limit height to ~60% of viewport or 420px whichever is smaller
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: SingleChildScrollView(child: child),
              ),
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
  // Optional: sections and members to allow filtering by section or specific member
  final List<String>? availableSections;
  final List<Map<String, String>>? availableMembers; // {id, name}
  final String? initialSection;
  final String? initialMemberId;

  const TaskFilter({
    super.key,
    this.initialStatus = 'both',
    this.initialPriorities = const {'normal'},
    this.onChanged,
    this.availableSections,
    this.availableMembers,
    this.initialSection,
    this.initialMemberId,
  });

  @override
  State<TaskFilter> createState() => _TaskFilterState();
}

class _TaskFilterState extends State<TaskFilter> {
  late String _status;
  late Set<String> _priorities;
  String? _section;
  String? _memberId;

  static const List<String> _prioritiesAll = ['low', 'normal', 'high'];

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _priorities = Set<String>.from(widget.initialPriorities);
    _section = widget.initialSection;
    _memberId = widget.initialMemberId;
    _notify();
  }

  void _notify() {
    widget.onChanged?.call({
      'status': _status,
      'priorities': _priorities.toList(),
      'section': _section,
      'member': _memberId,
    });
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
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black87,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        if (widget.availableSections != null &&
            widget.availableSections!.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Section',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    [
                          ChoiceChip(
                            label: const Text('Any'),
                            selected: _section == null,
                            onSelected: (_) => setState(() {
                              _section = null;
                              _notify();
                            }),
                          ),
                        ]
                        .followedBy(
                          widget.availableSections!.map((s) {
                            final selected = _section == s;
                            return ChoiceChip(
                              label: Text(s),
                              selected: selected,
                              onSelected: (_) => setState(() {
                                _section = selected ? null : s;
                                _notify();
                              }),
                              selectedColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                            );
                          }),
                        )
                        .toList(),
              ),
            ],
          ),

        if (widget.availableMembers != null &&
            widget.availableMembers!.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Member',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue txt) {
                  final q = txt.text.toLowerCase();
                  return widget.availableMembers!
                      .map((m) => m['name'] ?? '')
                      .where((n) => n.toLowerCase().contains(q))
                      .toList();
                },
                onSelected: (selection) {
                  final entry = widget.availableMembers!.firstWhere(
                    (m) => (m['name'] ?? '') == selection,
                    orElse: () => <String, String>{},
                  );
                  final id = entry['id'];
                  setState(() {
                    _memberId = id;
                    _notify();
                  });
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                      // If we have an initial selected member id, seed the controller text
                      if ((_memberId != null ||
                              widget.initialMemberId != null) &&
                          controller.text.isEmpty) {
                        final seedId = _memberId ?? widget.initialMemberId;
                        final seedName = widget.availableMembers!.firstWhere(
                          (m) => m['id'] == seedId,
                          orElse: () => <String, String>{},
                        )['name'];
                        if (seedName != null && seedName.isNotEmpty)
                          controller.text = seedName;
                      }

                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: 'Search member',
                          border: OutlineInputBorder(),
                          suffixIcon: _memberId != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _memberId = null;
                                      controller.clear();
                                      _notify();
                                    });
                                  },
                                )
                              : null,
                        ),
                        onSubmitted: (_) => onFieldSubmitted(),
                      );
                    },
              ),
            ],
          ),
      ],
    );
  }
}
