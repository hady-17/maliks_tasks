import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../const.dart';
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
  String _priority = 'normal';
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onSubmit(Map<String, dynamic> baseTask) async {
    // Build task payload from controllers and baseTask defaults
    final Map<String, dynamic> task = Map<String, dynamic>.from(baseTask);
    task['title'] = _titleController.text.trim();
    task['description'] = _descController.text.trim();
    // Normalize priority
    if (task['priority'] is String)
      task['priority'] = (_priority).toLowerCase();

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

    return Scaffold(
      appBar: ModernAppBar(
        title: 'Create Task',
        subtitle: 'your tasks with one click',
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: p == null
            ? const Center(child: Text('No profile provided'))
            : Card(
                color: Colors.red.shade200,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField('Title', _titleController, true),
                      const SizedBox(height: 16),
                      _buildTextField('Description', _descController, true),
                      const SizedBox(height: 16),

                      const SizedBox(height: 16),
                      _buildDropdownField(
                        'Priority',
                        ['low', 'normal', 'high'],
                        _priority,
                        true,
                        onChanged: (val) {
                          if (val != null) setState(() => _priority = val);
                        },
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: _buildSubmitButton(
                          baseTask,
                          onPressed: () => _onSubmit(baseTask),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: SafeArea(
        child: ModernNavBar(
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

Widget _buildDropdownField(
  String label,
  List<String> options,
  String? selectedValue,
  bool enabled, {
  ValueChanged<String?>? onChanged,
}) {
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
      DropdownButtonFormField<String>(
        initialValue: selectedValue,
        items: options
            .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
            .toList(),
        onChanged: enabled ? onChanged : null,
        decoration: InputDecoration(
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
