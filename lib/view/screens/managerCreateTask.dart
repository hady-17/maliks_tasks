import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/manager_create_task_vm.dart';
import '../widgets/appBar.dart';
import '../widgets/navBar.dart';
import '../../const.dart';

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
    return ChangeNotifierProvider<ManagerCreateTaskVM>(
      create: (_) {
        final vm = ManagerCreateTaskVM();
        vm.initFromProfile(p);
        return vm;
      },
      child: _ManagerCreateTaskContent(profile: p),
    );
  }
}

class _ManagerCreateTaskContent extends StatelessWidget {
  final Map<String, dynamic>? profile;
  const _ManagerCreateTaskContent({required this.profile});

  String _formatDate(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final p = profile;
    final section = p?['section'] as String?;
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: ModernAppBar(
        title: 'Create Task',
        subtitle: 'Manager Panel',
        showBackButton: true,
        backgroundColor: kMainColor,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 130, 45, 59),
              Color.fromARGB(255, 252, 43, 39),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Consumer<ManagerCreateTaskVM>(
                  builder: (context, vm, _) {
                    return Stack(
                      children: [
                        // Main card
                        AnimatedPadding(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.only(top: vm.isLoading ? 8 : 24),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 12,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.78,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Header
                                      Row(
                                        children: [
                                          Container(
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFFEE9CA7),
                                                  Color(0xFFFFDDE1),
                                                ],
                                              ),
                                            ),
                                            padding: const EdgeInsets.all(10),
                                            child: const Icon(
                                              Icons.task_alt_rounded,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: const [
                                              Text(
                                                'New Task',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              SizedBox(height: 2),
                                              Text(
                                                'Assign and schedule tasks quickly',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 18),

                                      // Title
                                      TextField(
                                        controller: vm.titleController,
                                        decoration: InputDecoration(
                                          labelText: 'Task title',
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Description
                                      TextField(
                                        controller: vm.descController,
                                        maxLines: 3,
                                        decoration: InputDecoration(
                                          labelText: 'Description',
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 14),

                                      // Row: Date + Shift
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () async {
                                                final d = await showDatePicker(
                                                  context: context,
                                                  initialDate: vm.taskDate,
                                                  firstDate: DateTime.now()
                                                      .subtract(
                                                        const Duration(
                                                          days: 365,
                                                        ),
                                                      ),
                                                  lastDate: DateTime.now().add(
                                                    const Duration(days: 365),
                                                  ),
                                                );
                                                if (d != null) {
                                                  vm.setTaskDate(d);
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.calendar_today_outlined,
                                              ),
                                              label: Text(
                                                _formatDate(vm.taskDate),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.grey.shade50,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          SizedBox(
                                            width: 140,
                                            child:
                                                DropdownButtonFormField<String>(
                                                  decoration: InputDecoration(
                                                    labelText: 'Shift',
                                                    filled: true,
                                                    fillColor:
                                                        Colors.grey.shade50,
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      borderSide:
                                                          BorderSide.none,
                                                    ),
                                                  ),
                                                  initialValue:
                                                      (vm
                                                              .taskShift
                                                              .isNotEmpty &&
                                                          shiftlist.contains(
                                                            vm.taskShift,
                                                          ))
                                                      ? vm.taskShift
                                                      : shiftlist.first,
                                                  items: shiftlist
                                                      .map(
                                                        (s) => DropdownMenuItem(
                                                          value: s,
                                                          child: Text(
                                                            s[0].toUpperCase() +
                                                                s.substring(1),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                                  onChanged: (v) =>
                                                      vm.setTaskShift(v),
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Priority chips
                                      Text(
                                        'Priority',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children: priorityList.map((p) {
                                          final selected = vm.priority == p;
                                          return ChoiceChip(
                                            label: Text(
                                              p[0].toUpperCase() +
                                                  p.substring(1),
                                            ),
                                            selected: selected,
                                            onSelected: (_) =>
                                                vm.setPriority(p),
                                            selectedColor: p == 'high'
                                                ? Colors.redAccent
                                                : Colors.greenAccent.shade400,
                                            backgroundColor:
                                                Colors.grey.shade200,
                                            labelStyle: TextStyle(
                                              color: selected
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 12),

                                      // Sections
                                      Text(
                                        'Assign Section',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children: sectionsList.map((s) {
                                          final sel =
                                              vm.assignedSection == s ||
                                              (vm.assignedSection == null &&
                                                  section == s);
                                          return FilterChip(
                                            label: Text(
                                              s[0].toUpperCase() +
                                                  s.substring(1),
                                            ),
                                            selected: sel,
                                            onSelected: (_) {
                                              vm.setAssignedSection(
                                                sel ? null : s,
                                              );
                                              vm.setAssignedTo(null);
                                            },
                                            selectedColor: Colors.blue.shade200,
                                          );
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 12),

                                      // Assign user dropdown
                                      DropdownButtonFormField<String?>(
                                        decoration: InputDecoration(
                                          labelText: 'Assign to (optional)',
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        initialValue: vm.assignedTo,
                                        items:
                                            [
                                                  const DropdownMenuItem<
                                                    String?
                                                  >(
                                                    value: null,
                                                    child: Text('Unassigned'),
                                                  ),
                                                ]
                                                .followedBy(
                                                  vm.members.map(
                                                    (
                                                      m,
                                                    ) => DropdownMenuItem<String?>(
                                                      value: m['id'],
                                                      child: Text(
                                                        '${m['name']} (${m['section']})',
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                        onChanged: (v) => vm.setAssignedTo(v),
                                      ),

                                      const SizedBox(height: 18),
                                      // Actions
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: vm.isLoading
                                                  ? null
                                                  : () async {
                                                      final ok = await vm
                                                          .createTask();
                                                      if (!context.mounted) {
                                                        return;
                                                      }
                                                      if (ok) {
                                                        ScaffoldMessenger.maybeOf(
                                                          context,
                                                        )?.showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              'Task created',
                                                            ),
                                                          ),
                                                        );
                                                        Navigator.pop(context);
                                                      } else {
                                                        ScaffoldMessenger.maybeOf(
                                                          context,
                                                        )?.showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              vm.error ??
                                                                  'Failed to create task',
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                backgroundColor:
                                                    Colors.red.shade700,
                                              ),
                                              child: AnimatedSwitcher(
                                                duration: const Duration(
                                                  milliseconds: 250,
                                                ),
                                                child: vm.isLoading
                                                    ? const SizedBox(
                                                        key: ValueKey(
                                                          'loading',
                                                        ),
                                                        height: 18,
                                                        width: 18,
                                                        child:
                                                            CircularProgressIndicator(
                                                              color:
                                                                  Colors.white,
                                                              strokeWidth: 2,
                                                            ),
                                                      )
                                                    : const Text(
                                                        'Create Task',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                        key: ValueKey('label'),
                                                      ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          OutlinedButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 14,
                                                    horizontal: 20,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              backgroundColor: Colors.white,
                                            ),
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: Colors.black87,
                                              ),
                                            ),
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

                        // Floating subtle loader overlay
                        if (vm.isLoading)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: ModernNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/orders',
              (route) => false,
              arguments: p,
            );
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
        backgroundColor: kMainColor,
      ),
    );
  }
}
