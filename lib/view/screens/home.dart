import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maliks_tasks/view/widgets/appBar.dart';
import 'package:maliks_tasks/view/widgets/navBar.dart';
import 'package:maliks_tasks/view/widgets/taskCard.dart';
import '../../model/task/tasks.dart';
import '../../viewmodels/task_provider.dart';
import 'package:calendar_timeline/calendar_timeline.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic>? profile;
  const HomePage({super.key, this.profile});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  Map<String, dynamic>? _resolveProfile(BuildContext context) {
    if (widget.profile != null) return widget.profile;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) return args;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final p = _resolveProfile(context);

    if (p == null) {
      return const Scaffold(body: Center(child: Text('No profile provided')));
    }

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    // Compute bottom inset and nav bar height so we can pad the list
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final navBarHeight = 70.0 + bottomInset;

    return Scaffold(
      extendBody: true,
      appBar: ModernAppBar(
        title: 'Tasks',
        subtitle: 'All your tasks at a glance',
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Tasks',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CalendarTimeline(
              initialDate: DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now().add(const Duration(days: 30)),
              onDateSelected: (date) {
                print('Selected date: $date');
              },
              leftMargin: 20,
              monthColor: Colors.black,
              dayColor: Colors.black,
              activeDayColor: Colors.white,
              activeBackgroundDayColor: Color(0xFF8C7E7E),
            ),
            const SizedBox(height: 16),
            // Expanded ensures the StreamBuilder and its ListView get a bounded height
            Expanded(
              child: StreamBuilder<List<Task>>(
                stream: taskProvider.watchTodayTasks(
                  branchId: p['branch_id'],
                  section: p['section'] ?? '',
                  userId: p['id'],
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
