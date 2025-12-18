import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maliks_tasks/view/widgets/appBar.dart';
import 'package:maliks_tasks/view/widgets/navBar.dart';
import 'package:maliks_tasks/view/widgets/taskCard.dart';
import '../../model/task/tasks.dart';
import '../../viewmodels/task_provider.dart';
import 'package:calendar_timeline/calendar_timeline.dart';
import '../../view/widgets/filter_popup.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic>? profile;
  const HomePage({super.key, this.profile});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final int _currentIndex = 0;
  Map<String, dynamic>? _filters;
  DateTime _selectedDate = DateTime.now();

  Map<String, dynamic>? _resolveProfile(BuildContext context) {
    if (widget.profile != null) return widget.profile;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) return args;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final p = _resolveProfile(context);
    print('Profile in HomePage: $p');

    if (p == null) {
      return const Scaffold(body: Center(child: Text('No profile provided')));
    }

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    // Compute bottom inset and nav bar height so we can pad the list
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final navBarHeight = 70.0 + bottomInset;
    final topInset = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: ModernAppBar(
        title: 'Tasks',
        subtitle: 'All your tasks at a glance',
        showBackButton: false,
        showDashboardButton: true,
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
                  'Today\'s Tasks',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Text(
                      'Filter ur tasks',
                      style: TextStyle(color: Colors.black),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: () {
                        // Open filter popup
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
            // Expanded ensures the StreamBuilder and its ListView get a bounded height
            Expanded(
              child: StreamBuilder<List<Task>>(
                stream: taskProvider.watchTodayTasks(
                  branchId: p['branch_id'],
                  section: p['section'] ?? '',
                  userId: p['id'],
                  taskDate: _selectedDate.toIso8601String().split('T').first,
                  status: _filters?['status'] ?? 'both',
                  priorities: _filters != null
                      ? List<String>.from(_filters!['priorities'] ?? ['normal'])
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
                    return const Center(child: Text('No tasks for today'));
                  }

                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + navBarHeight),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return TaskCard(
                        task: tasks[index],
                        onComplete: () {
                          taskProvider.toggleTaskDone(tasks[index].id);
                        },
                        onEdit: () {
                          // TODO: Implement edit task functionality
                          print('Edit task: ${tasks[index].id}');
                        },
                        onTap: () {
                          // TODO: Implement task details navigation
                          print('View task details: ${tasks[index].id}');
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
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/orders',
              (route) => false,
              arguments: p,
            );
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
        backgroundColor: const Color(0xFF8C7E7E),
        activeColor: Colors.white,
        inactiveColor: const Color(0xFFBDB8B8),
      ),
    );
  }
}
