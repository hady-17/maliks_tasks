import 'package:flutter/material.dart';
import '../widgets/appBar.dart';
import '../widgets/navBar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManagerCreateTaskScreen extends StatelessWidget {
  final Map<String, dynamic>? profile;
  const ManagerCreateTaskScreen({super.key, this.profile});

  Map<String, dynamic>? _resolveProfile(BuildContext context) {
    if (profile != null) return profile;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) return args;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final p = _resolveProfile(context);
    print('Profile in ManagerCreateTaskScreen: $p');
    return _ManagerCreateTaskContent(p: p);
  }
}

class _ManagerCreateTaskContent extends StatefulWidget {
  final Map<String, dynamic>? p;
  const _ManagerCreateTaskContent({required this.p, Key? key})
    : super(key: key);

  @override
  _ManagerCreateTaskContentState createState() =>
      _ManagerCreateTaskContentState();
}

class _ManagerCreateTaskContentState extends State<_ManagerCreateTaskContent> {
  final int currentIndex = 2; // Assuming index 1 is for create task
  List<Map<String, String>> users = [];
  bool _loading = true;
  // Form state fields (moved out of build so state persists across rebuilds)
  String taskTitle = '';
  String taskDescription = '';
  String assignedToUserId = '';
  DateTime assignedDate = DateTime.now();
  String priority = 'normal';
  String taskShift = '';
  String assignedSection = '';
  String createdBy = '';
  String branchID = '';

  @override
  void initState() {
    super.initState();
    // initialize createdBy and branchID from provided profile
    createdBy = widget.p?['id'] as String? ?? '';
    branchID = widget.p?['branch_id'] as String? ?? '';
    // initialize default shift
    final profileShift = widget.p?['shift'] as String?;
    final shiftlist = ['day', 'night', 'both'];
    taskShift = (profileShift != null && shiftlist.contains(profileShift))
        ? profileShift
        : shiftlist.first;

    _loadUsers();
  }

  // Return true on success, false on failure
  Future<bool> createTask({
    required String title,
    required String description,
    required String priority,
    required DateTime date,
    required String shift,
    String? assignedTo, // user UUID
    String? assignedSection,
    required String branchId,
    required String createdBy, // manager UUID
  }) async {
    try {
      final supabase = Supabase.instance.client;

      // Using .select() after insert returns the inserted rows if successful.
      final response = await supabase.from('tasks').insert({
        'title': title,
        'description': description,
        'priority': priority,
        'task_date': date.toIso8601String().split('T').first,
        'shift': shift,
        'assigned_to': assignedTo, // null if section task
        'assigned_section': assignedSection, // null if user task
        'branch_id': branchId,
        'created_by': createdBy,
      }).select();

      // If response contains inserted row(s), treat as success
      if (response is List && response.isNotEmpty) {
        return true;
      }

      // Fallback: if response is non-null, consider success
      if (response != null) return true;
    } catch (e) {
      print('Error creating task: $e');
      return false;
    }
  }

  void _loadUsers() async {
    final branchId = widget.p?['branch_id'] as String?;
    final fetched = await _fetchUsers(branchId);
    if (!mounted) return;
    setState(() {
      users = fetched;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final userId = p?['id'] as String?;
    final branchId = p?['branch_id'] as String?;
    final section = p?['section'] as String?;
    final shift = p?['shift'] as String?;
    final priorityList = ['low', 'normal', 'high'];
    final sectionsList = [
      'manager',
      'supervisor',
      'cashier',
      'stationary',
      'designer',
      'services',
    ];
    final shiftlist = ['day', 'night', 'both'];
    // use persistent state fields defined on State
    // ensure createdBy / branchID are set if missing
    createdBy = createdBy.isEmpty ? (userId ?? '') : createdBy;
    branchID = branchID.isEmpty ? (branchId ?? '') : branchID;

    // Implementation of the screen's UI goes here
    return Scaffold(
      appBar: ModernAppBar(
        title: 'Create Task',
        subtitle: 'Manager Panel',
        showBackButton: true,
        backgroundColor: Color(0xFF8C7E7E),
      ),
      body: Center(
        child: _loading
            ? CircularProgressIndicator()
            : Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        decoration: InputDecoration(labelText: 'Task Title'),
                        onChanged: (value) {
                          // Handle title input
                          taskTitle = value;
                        },
                      ),
                      SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Task Description',
                        ),
                        onChanged: (value) {
                          // Handle description input
                          taskDescription = value;
                        },
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Task Priority'),
                        value: priority,
                        items: priorityList
                            .map(
                              (p) => DropdownMenuItem<String>(
                                value: p,
                                child: Text(
                                  p[0].toUpperCase() + p.substring(1),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            priority = value ?? 'normal';
                          });
                          print('Selected priority: $value');
                        },
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Shift'),
                        // use the state-backed taskShift so it's always valid and persisted
                        value:
                            (taskShift.isNotEmpty &&
                                shiftlist.contains(taskShift))
                            ? taskShift
                            : shiftlist.first,
                        items: shiftlist
                            .map(
                              (s) => DropdownMenuItem<String>(
                                value: s,
                                child: Text(
                                  s[0].toUpperCase() + s.substring(1),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            taskShift = value ?? '';
                          });
                          print('Selected shift: $value');
                        },
                      ),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Assign Section',
                        ),
                        value:
                            (section != null && sectionsList.contains(section))
                            ? section
                            : sectionsList.first,
                        items: sectionsList
                            .map(
                              (s) => DropdownMenuItem<String>(
                                value: s,
                                child: Text(
                                  s[0].toUpperCase() + s.substring(1),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            assignedSection = value ?? '';
                            assignedToUserId =
                                ''; // clear specific user when a section is chosen
                          });
                          print('Selected section: $value');
                        },
                      ),
                      SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Assign User'),
                        items: users
                            .map(
                              (u) => DropdownMenuItem<String>(
                                value: u['id'],
                                child: Text(
                                  '${u['name'] ?? 'Unknown'} (${u['section'] ?? 'N/A'})',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          // Handle user selection
                          setState(() {
                            assignedToUserId = value ?? '';
                          });
                          print('Selected user ID: $value');
                        },
                      ),
                      // Additional form fields for task creation can be added here
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'),
                          ),
                          SizedBox(width: 14),
                          ElevatedButton(
                            onPressed: () async {
                              // call createTask and act based on result
                              final success = await createTask(
                                title: taskTitle.isNotEmpty ? taskTitle : '',
                                description: taskDescription.isNotEmpty
                                    ? taskDescription
                                    : '',
                                priority: priority.isNotEmpty
                                    ? priority
                                    : 'normal',
                                date: assignedDate,
                                shift: taskShift,
                                assignedTo: assignedToUserId.isNotEmpty
                                    ? assignedToUserId
                                    : null,
                                assignedSection: assignedSection.isNotEmpty
                                    ? assignedSection
                                    : null,
                                branchId: branchID,
                                createdBy: createdBy,
                              );

                              if (!mounted) return;
                              if (success) {
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to create task. Try again.',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text('Submit'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: ModernNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 1) {
          } else if (index == 2) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/manager_create_task',
              (route) => false,
              arguments: p,
            );
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
              '/manager_home',
              (route) => false,
              arguments: p,
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, String>>> _fetchUsers([String? branchId]) async {
    final branchIdLocal = branchId ?? widget.p?['branch_id'] as String?;
    if (branchIdLocal == null || branchIdLocal.isEmpty) return [];

    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('profiles')
        .select('id, full_name,section')
        .eq('branch_id', branchIdLocal);

    final data = response as List<dynamic>? ?? [];
    final users = data
        .map(
          (u) => {
            'id': u['id'] as String,
            'name': u['full_name'] as String,
            'section': u['section'] as String,
          },
        )
        .toList();

    return List<Map<String, String>>.from(users);
  }
}
