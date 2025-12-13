import 'package:flutter/material.dart';

/// Filter UI for Orders. Similar to TaskFilter but with a scope selector
/// (All | Your Orders) and type selection (pickup, delivery, from_another_branch).
class OrderFilter extends StatefulWidget {
  final String initialStatus; // 'both' | 'open' | 'completed'
  final Set<String> initialTypes;
  final String initialScope; // 'all' | 'yours'
  final ValueChanged<Map<String, dynamic>>? onChanged;
  final List<String>? availableSections;
  final bool disableScope;

  const OrderFilter({
    super.key,
    this.initialStatus = 'both',
    this.initialTypes = const {'pickup', 'delivery', 'from_another_branch'},
    this.initialScope = 'all',
    this.onChanged,
    this.availableSections,
    this.disableScope = false,
  });

  @override
  State<OrderFilter> createState() => _OrderFilterState();
}

class _OrderFilterState extends State<OrderFilter> {
  late String _status;
  late Set<String> _types;
  late String _scope;
  String? _section;

  static const List<String> _allTypes = [
    'pickup',
    'delivery',
    'from_another_branch',
  ];

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _types = Set<String>.from(widget.initialTypes);
    _scope = widget.initialScope;
    _section = null;
    _notify();
  }

  void _notify() {
    widget.onChanged?.call({
      'status': _status,
      'types': _types.toList(),
      'scope': _scope,
      'section': _section,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.disableScope) ...[
          const Text('Scope', style: TextStyle(fontWeight: FontWeight.w600)),
          RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            title: const Text('All orders'),
            value: 'all',
            groupValue: _scope,
            onChanged: (v) => setState(() {
              _scope = v!;
              _notify();
            }),
          ),
          RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            title: const Text('Your orders'),
            value: 'yours',
            groupValue: _scope,
            onChanged: (v) => setState(() {
              _scope = v!;
              _notify();
            }),
          ),
        ],

        const SizedBox(height: 8),
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
          title: const Text('Completed'),
          value: 'completed',
          groupValue: _status,
          onChanged: (v) => setState(() {
            _status = v!;
            _notify();
          }),
        ),

        const SizedBox(height: 12),
        const Text('Types', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _allTypes.map((t) {
            final sel = _types.contains(t);
            return ChoiceChip(
              label: Text(
                t.replaceAll('_', ' ')[0].toUpperCase() +
                    t.replaceAll('_', ' ').substring(1),
              ),
              selected: sel,
              onSelected: (_) => setState(() {
                if (sel) {
                  _types.remove(t);
                  if (_types.isEmpty) _types.addAll(_allTypes);
                } else {
                  _types.add(t);
                }
                _notify();
              }),
            );
          }).toList(),
        ),

        if (widget.availableSections != null &&
            widget.availableSections!.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
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
                            final sel = _section == s;
                            return ChoiceChip(
                              label: Text(s),
                              selected: sel,
                              onSelected: (_) => setState(() {
                                _section = sel ? null : s;
                                _notify();
                              }),
                            );
                          }),
                        )
                        .toList(),
              ),
            ],
          ),
      ],
    );
  }
}
