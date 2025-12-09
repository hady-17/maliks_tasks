import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../view/widgets/appBar.dart';
import '../../view/widgets/navBar.dart';

class CreateTask extends StatefulWidget {
  final Map<String, dynamic>? profile;
  const CreateTask({super.key, this.profile});

  Map<String, dynamic>? _resolveProfile(BuildContext context) {
    if (profile != null) return profile;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) return args;
    return null;
  }

  @override
  State<CreateTask> createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _assignController;
  String _priority = 'normal';
  final int _currentIndex = 2;
  DateTime _taskDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _assignController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _assignController.dispose();
    super.dispose();
  }

  void _onSubmit(Map<String, dynamic> baseTask) async {
    // Build task payload from controllers and baseTask defaults
    final Map<String, dynamic> task = Map<String, dynamic>.from(baseTask);
    task['title'] = _titleController.text.trim();
    task['description'] = _descController.text.trim();
    task['task_date'] = _taskDate;
    // Use the editable Assign To UUID from controller
    task['assigned_to'] = _assignController.text.trim();
    // Normalize priority
    if (task['priority'] is String) {
      task['priority'] = (_priority).toLowerCase();
    }

    await submitTask(task);
    // After submission, navigate back or show confirmation
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget._resolveProfile(context);
    final userId = p != null ? p['id'] as String? : null;
    final branchId = p != null ? p['branch_id'] as String? : null;
    final section = p != null ? p['section'] as String? : null;
    final shift = p != null ? p['shift'] as String? : null;

    final Map<String, dynamic> baseTask = {
      'priority': 'normal',
      'task_date': DateTime.now(),
      'shift': shift,
      'status': 'open',
      'assigned_to': userId,
      'assigned_section': section,
      'branch_id': branchId,
      'assignee': userId,
    };

    // set default assign-to UUID if controller is empty
    if ((userId ?? '').isNotEmpty && _assignController.text.isEmpty) {
      _assignController.text = userId!;
    }

    return Scaffold(
      extendBody: true,
      appBar: ModernAppBar(
        title: 'Create Task',
        subtitle: 'Create tasks quickly',
        showBackButton: true,
      ),
      body: p == null
          ? const Center(child: Text('No profile provided'))
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF6F8FA), Color(0xFFFDECEA)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Card(
                      elevation: 14,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'New Task',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Fill the details below to create a task',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 18),

                            _buildTextField('Title', _titleController, true),
                            const SizedBox(height: 12),

                            _buildTextField(
                              'Description',
                              _descController,
                              true,
                            ),
                            const SizedBox(height: 12),

                            // Date and Priority row
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      final d = await showDatePicker(
                                        context: context,
                                        initialDate: _taskDate,
                                        firstDate: DateTime.now().subtract(
                                          const Duration(days: 365),
                                        ),
                                        lastDate: DateTime.now().add(
                                          const Duration(days: 365),
                                        ),
                                      );
                                      if (d != null) {
                                        setState(() => _taskDate = d);
                                      }
                                    },
                                    child: AbsorbPointer(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Date',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(height: 6),
                                          // Styled read-only date field that scales text to fit
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.calendar_today_rounded,
                                                  size: 20,
                                                  color: Colors.black54,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      _taskDate
                                                          .toIso8601String()
                                                          .substring(0, 10),
                                                      style: const TextStyle(
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Priority',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: ['low', 'normal', 'high'].map((
                                          opt,
                                        ) {
                                          final active = _priority == opt;
                                          return Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                right: 6.0,
                                              ),
                                              child: ElevatedButton(
                                                onPressed: () => setState(
                                                  () => _priority = opt,
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: active
                                                      ? Colors.red.shade800
                                                      : Colors.grey.shade200,
                                                  foregroundColor: active
                                                      ? Colors.white
                                                      : Colors.black87,
                                                  elevation: active ? 4 : 0,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    opt[0].toUpperCase() +
                                                        opt.substring(1),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // optional assignee field (editable UUID)
                            _buildTextField(
                              'Assign To (UUID)',
                              _assignController,
                              false,
                            ),

                            const SizedBox(height: 22),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildSubmitButton(
                                    baseTask,
                                    onPressed: () => _onSubmit(baseTask),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: ModernNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
          } else if (index == 2) {
            Navigator.pushNamed(context, '/create_task', arguments: p);
          } else if (index == 3) {
            print('pressed on $index');
          } else if (index == 4) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/profile',
              (route) => false,
              arguments: p,
            );
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
              arguments: p,
            );
          }
        },
      ),
    );
  }
}

Widget _buildTextField(
  String label,
  TextEditingController controller,
  bool enabled,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: enabled ? Colors.red.shade900 : Colors.grey.shade600,
          fontWeight: FontWeight.w700,
          fontSize: 14.0,
          fontFamily: 'Roboto',
          letterSpacing: 0.25,
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: label,
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.red.shade600, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16.0,
          ),
        ),
        style: TextStyle(
          color: enabled ? Colors.black : Colors.grey.shade600,
          fontSize: 16,
        ),
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
      ),
    ],
  );
}

ElevatedButton _buildSubmitButton(
  Map<String, dynamic> task, {
  VoidCallback? onPressed,
}) {
  return ElevatedButton(
    onPressed:
        onPressed ??
        () {
          // Handle form submission
          submitTask(task);
        },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red.shade600,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    child: const Text(
      'Create Task',
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

Future<void> submitTask(Map<String, dynamic> task) async {
  // Implement task submission logic here using the Supabase client.
  // Do not call `.execute()` on the Postgrest builder — the client
  // methods are already async and return results or throw on error.
  final client = Supabase.instance.client;
  try {
    // Prepare payload: convert any DateTime values to string (YYYY-MM-DD)
    // Also, map/remove any keys that don't exist in the DB schema.
    final payload = <String, dynamic>{};
    task.forEach((k, v) {
      // Skip any client-only keys (e.g. 'assignee') for now
      if (k == 'assignee') return;
      if (v is DateTime) {
        payload[k] = v.toIso8601String().substring(0, 10);
      } else {
        payload[k] = v;
      }
    });

    // If caller provided an 'assignee' key (client-side name), map it to 'created_by'
    if (task.containsKey('assignee')) {
      final a = task['assignee'];
      if (a is String && a.isNotEmpty) payload['created_by'] = a;
    }

    // Insert the row. Use `.select()` if you need the inserted row returned.
    // Normalize enum-like fields to match DB constraints
    if (payload['priority'] is String) {
      payload['priority'] = (payload['priority'] as String).toLowerCase();
    }
    if (payload['shift'] is String) {
      payload['shift'] = (payload['shift'] as String).toLowerCase();
    }

    await client.from('tasks').insert(payload);
    // If no exception, assume success.
    debugPrint('Task created successfully');
  } catch (e) {
    // Log and surface the error appropriately in real UI code.
    debugPrint('Error creating task: $e');
  }
}
