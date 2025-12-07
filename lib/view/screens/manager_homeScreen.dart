import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maliks_tasks/view/widgets/appBar.dart';
import 'package:maliks_tasks/view/widgets/navBar.dart';
import 'package:maliks_tasks/view/widgets/taskCard.dart';
import '../../model/task/tasks.dart';
import '../../viewmodels/managerProvider.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import '../../view/widgets/filter_popup.dart';

class ManagerHomescreen extends StatefulWidget {
  final Map<String, dynamic>? profile;
  const ManagerHomescreen({super.key, this.profile});

  @override
  _ManagerHomescreenState createState() => _ManagerHomescreenState();
}

class _ManagerHomescreenState extends State<ManagerHomescreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _filters;
  DateTime _selectedDate = DateTime.now();

  Map<String, dynamic>? _resolveProfile(BuildContext context) {
    if (widget.profile != null) return widget.profile;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) return args;
    return null;
  }

  void _showEditDialog(BuildContext context, Task task) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description);
    String selectedStatus = task.status;
    String selectedPriority = task.priority;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['open', 'done']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => selectedStatus = v!,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedPriority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: ['low', 'normal', 'high']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => selectedPriority = v!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updates = {
                'title': titleController.text.trim(),
                'description': descController.text.trim(),
                'status': selectedStatus,
                'priority': selectedPriority,
              };
              final provider = Provider.of<ManagerTaskProvider>(
                ctx,
                listen: false,
              );
              final messenger = ScaffoldMessenger.maybeOf(ctx);
              final success = await provider.updateTask(task.id, updates);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                messenger?.showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Task updated!' : 'Update failed'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final provider = Provider.of<ManagerTaskProvider>(
                ctx,
                listen: false,
              );
              final messenger = ScaffoldMessenger.maybeOf(ctx);
              final success = await provider.deleteTask(task.id);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                messenger?.showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Task deleted!' : 'Delete failed'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _resolveProfile(context);

    if (p == null) {
      return const Scaffold(body: Center(child: Text('No profile provided')));
    }

    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final navBarHeight = 70.0 + bottomInset;
    final topInset = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: ModernAppBar(
        title: 'Manager Dashboard',
        subtitle: 'Manage all branch tasks',
        showBackButton: false,
        showSearchButton: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEDEDED), Color.fromARGB(255, 216, 42, 42)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.fromLTRB(16, topInset + 85, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Branch Tasks',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Text(
                      'Filter tasks',
                      style: TextStyle(color: Colors.black),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: () {
                        Map<String, dynamic>? pending;
                        showDialog(
                          context: context,
                          builder: (ctx) => FilterPopup(
                            child: TaskFilter(
                              initialStatus: _filters?['status'] ?? 'both',
                              initialPriorities: _filters != null
                                  ? Set<String>.from(
                                      _filters!['priorities'] ?? ['normal'],
                                    )
                                  : const {'normal'},
                              onChanged: (sel) => pending = sel,
                            ),
                            onApply: () {
                              setState(() {
                                _filters = pending ?? _filters;
                              });
                            },
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.filter_list_alt,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            CalendarTimeline(
              initialDate: _selectedDate,
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now().add(const Duration(days: 30)),
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
              leftMargin: 20,
              monthColor: Colors.black,
              dayColor: Colors.black,
              activeDayColor: Colors.white,
              activeBackgroundDayColor: Color(0xFF8C7E7E),
              dotColor: Colors.red,
              showYears: false,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Task>>(
                stream: Provider.of<ManagerTaskProvider>(context, listen: false)
                    .watchAllTasks(
                      branchId:
                          p['branch_id'], // Can be null to see all branches
                      taskDate: _selectedDate
                          .toIso8601String()
                          .split('T')
                          .first,
                      status: _filters?['status'] ?? 'both',
                      priorities: _filters != null
                          ? List<String>.from(
                              _filters!['priorities'] ?? ['normal'],
                            )
                          : null,
                    ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final tasks = snapshot.data ?? [];

                  if (tasks.isEmpty) {
                    return const Center(
                      child: Text(
                        'No tasks found for this date',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + navBarHeight),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return TaskCard(
                        task: tasks[index],
                        onComplete: () {
                          Provider.of<ManagerTaskProvider>(
                            context,
                            listen: false,
                          ).toggleTaskDone(tasks[index].id);
                        },
                        onEdit: () {
                          _showEditDialog(context, tasks[index]);
                        },
                        onTap: () {
                          _showDeleteDialog(context, tasks[index]);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ModernNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
          } else if (index == 2) {
            Navigator.pushNamed(context, '/manager_create_task', arguments: p);
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
        backgroundColor: const Color(0xFF8C7E7E),
        activeColor: Colors.white,
        inactiveColor: const Color(0xFFBDB8B8),
      ),
    );
  }
}
