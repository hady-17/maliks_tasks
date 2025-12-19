import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/task/tasks.dart';

class ManagerTaskProvider extends ChangeNotifier {
  final dynamic supabase;

  ManagerTaskProvider({dynamic supabaseClient})
    : supabase = supabaseClient ?? Supabase.instance.client;

  List<Task> _tasks = [];
  final bool _isLoading = false;
  String? _error;

  // Getters
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ---------------------------------------------------------
  // Watch all branch tasks (managers can see everything)
  // ---------------------------------------------------------
  Stream<List<Task>> watchAllTasks({
    String? branchId,
    String? taskDate,
    String status = 'both',
    List<String>? priorities,
    String? filterSection,
    String? filterMember,
  }) {
    final dateFilter =
        taskDate ?? DateTime.now().toIso8601String().split('T').first;

    final stream = supabase.from('tasks').stream(primaryKey: ['id']);

    return stream.map<List<Task>>((rows) {
      final list = rows as List<dynamic>;
      final filtered = list
          .map((e) => Map<String, dynamic>.from(e as Map))
          .where((row) {
            // Filter by branch if specified
            if (branchId != null && row['branch_id'] != branchId) return false;

            // Filter by date
            final matchesDate = row['task_date'] == dateFilter;
            if (!matchesDate) return false;

            // Section filter (if provided)
            if (filterSection != null && filterSection.trim().isNotEmpty) {
              if ((row['assigned_section'] ?? '') != filterSection)
                return false;
            }

            // Member filter (if provided)
            if (filterMember != null && filterMember.trim().isNotEmpty) {
              if ((row['assigned_to'] ?? '') != filterMember) return false;
            }

            // Status filter
            if (status != 'both') {
              final s = (row['status'] ?? 'open').toString();
              if (s != status) return false;
            }

            // Priorities filter
            if (priorities != null && priorities.isNotEmpty) {
              final p = (row['priority'] ?? 'normal').toString();
              if (!priorities.contains(p)) return false;
            }

            return true;
          })
          .map((row) => Task.fromJson(row))
          .toList();

      // Sort by priority then created_at
      filtered.sort((a, b) {
        final order = {'low': 0, 'normal': 1, 'high': 2};
        final pa = order[a.priority.toLowerCase()] ?? 1;
        final pb = order[b.priority.toLowerCase()] ?? 1;
        if (pa != pb) return pb.compareTo(pa); // High priority first
        return (b.taskDate).compareTo(a.taskDate);
      });

      return filtered;
    });
  }

  // ---------------------------------------------------------
  // Update task
  // ---------------------------------------------------------
  Future<bool> updateTask(String taskId, Map<String, dynamic> updates) async {
    try {
      // Prepare payload: convert DateTime to string if present
      final payload = <String, dynamic>{};
      updates.forEach((k, v) {
        if (v is DateTime) {
          payload[k] = v.toIso8601String().substring(0, 10);
        } else {
          payload[k] = v;
        }
      });

      // Normalize enum fields
      if (payload.containsKey('priority')) {
        payload['priority'] = (payload['priority'] as String).toLowerCase();
      }
      if (payload.containsKey('shift')) {
        payload['shift'] = (payload['shift'] as String).toLowerCase();
      }
      if (payload.containsKey('status')) {
        payload['status'] = (payload['status'] as String).toLowerCase();
      }

      await supabase.from('tasks').update(payload).eq('id', taskId);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating task: $e');
      _error = 'Failed to update task: $e';
      notifyListeners();
      return false;
    }
  }

  // ---------------------------------------------------------
  // Delete task
  // ---------------------------------------------------------
  Future<bool> deleteTask(String taskId) async {
    try {
      await supabase.from('tasks').delete().eq('id', taskId);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting task: $e');
      _error = 'Failed to delete task: $e';
      notifyListeners();
      return false;
    }
  }

  // ---------------------------------------------------------
  // Toggle task status (done/open)
  // ---------------------------------------------------------
  Future<void> toggleTaskDone(String taskId) async {
    try {
      // Fetch current status
      final resp = await supabase
          .from('tasks')
          .select('status')
          .eq('id', taskId)
          .maybeSingle();

      if (resp == null) return;

      final currentStatus = resp['status'] as String?;
      final newStatus = (currentStatus == 'done') ? 'open' : 'done';

      final currentUserId =
          supabase?.auth.currentUser?.id ??
          Supabase.instance.client.auth.currentUser?.id;

      final updatePayload = {
        'status': newStatus,
        'done_by_user': newStatus == 'done' ? currentUserId : null,
        'done_at': newStatus == 'done'
            ? DateTime.now().toUtc().toIso8601String()
            : null,
      };

      await supabase.from('tasks').update(updatePayload).eq('id', taskId);

      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling task status: $e');
    }
  }

  // ---------------------------------------------------------
  // Clear error
  // ---------------------------------------------------------
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ---------------------------------------------------------
  // Clear tasks when logging out
  // ---------------------------------------------------------
  void clearTasks() {
    _tasks = [];
    notifyListeners();
  }
}
