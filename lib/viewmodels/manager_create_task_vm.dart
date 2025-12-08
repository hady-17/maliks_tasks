import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManagerCreateTaskVM extends ChangeNotifier {
  ManagerCreateTaskVM();

  // Controllers
  final titleController = TextEditingController();
  final descController = TextEditingController();

  // State
  DateTime taskDate = DateTime.now();
  String priority = 'normal';
  String taskShift = '';
  String? assignedSection;
  String? assignedTo;

  String createdBy = '';
  String branchId = '';

  bool isLoading = false;
  String? error;

  List<Map<String, String>> members = [];

  void initFromProfile(Map<String, dynamic>? p) {
    createdBy = p?['id'] as String? ?? '';
    branchId = p?['branch_id'] as String? ?? '';
    final profileShift = p?['shift'] as String?;
    final shiftlist = ['day', 'night', 'both'];
    taskShift = (profileShift != null && shiftlist.contains(profileShift))
        ? profileShift
        : shiftlist.first;
    fetchMembers(branchId: branchId);
  }

  Future<void> fetchMembers({String? branchId}) async {
    try {
      isLoading = true;
      notifyListeners();
      final client = Supabase.instance.client;
      if (branchId == null || branchId.isEmpty) {
        members = [];
        return;
      }
      final res = await client
          .from('profiles')
          .select('id, full_name, section')
          .eq('branch_id', branchId)
          .order('full_name');
      final data = res as List<dynamic>? ?? [];
      members = data
          .map(
            (u) => {
              'id': u['id'] as String,
              'name': u['full_name'] as String? ?? '(no name)',
              'section': u['section'] as String? ?? '',
            },
          )
          .toList();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Helper setters that notify listeners
  void setTaskShift(String? s) {
    taskShift = s ?? '';
    notifyListeners();
  }

  void setAssignedSection(String? s) {
    assignedSection = s;
    notifyListeners();
  }

  void setAssignedTo(String? s) {
    assignedTo = s;
    notifyListeners();
  }

  void setPriority(String p) {
    priority = p;
    notifyListeners();
  }

  void setTaskDate(DateTime d) {
    taskDate = d;
    notifyListeners();
  }

  Future<bool> createTask() async {
    try {
      isLoading = true;
      notifyListeners();
      final client = Supabase.instance.client;

      final payload = <String, dynamic>{
        'title': titleController.text.trim(),
        'description': descController.text.trim(),
        'task_date': taskDate.toIso8601String().split('T').first,
        'priority': priority.toLowerCase(),
        'shift': taskShift,
        'assigned_to': assignedTo,
        'assigned_section': assignedSection,
        'branch_id': branchId,
        'created_by': createdBy,
        'status': 'open',
      };

      // Remove null or empty strings to avoid DB constraint failures
      payload.removeWhere(
        (k, v) => v == null || (v is String && v.trim().isEmpty),
      );

      final res = await client.from('tasks').insert(payload).select();
      isLoading = false;
      notifyListeners();
      // `res` is expected to be a List of inserted rows; success if non-empty
      final inserted = (res as List<dynamic>?) ?? [];
      return inserted.isNotEmpty;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void disposeControllers() {
    titleController.dispose();
    descController.dispose();
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }
}
