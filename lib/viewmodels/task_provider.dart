import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/task/tasks.dart';

class TaskProvider extends ChangeNotifier {
  final dynamic supabase;

  TaskProvider({dynamic supabaseClient})
    : supabase = supabaseClient ?? Supabase.instance.client;

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ---------------------------------------------------------
  // Load today's tasks for a team member (My Tasks + Section)
  // ---------------------------------------------------------
  Future<void> loadTodayTasks({
    required String branchId,
    required String section,
    required String userId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final today = DateTime.now().toIso8601String().split('T').first;

      // Safe section fallback to prevent malformed 'or' expression when section is empty
      final safeSection = (section.isNotEmpty) ? section : '_NO_SECTION_';

      final response = await supabase
          .from('tasks')
          .select()
          .eq('branch_id', branchId)
          .eq('task_date', today)
          .or('assigned_to.eq.$userId,assigned_section.eq.$safeSection')
          .order('priority', ascending: true)
          .order('created_at', ascending: false);

      // Defensive handling: Supabase client may return different types in tests/errors.
      if (response == null) {
        _tasks = [];
      } else if (response is List) {
        _tasks = response
            .map<Task>(
              (json) => Task.fromJson(Map<String, dynamic>.from(json as Map)),
            )
            .toList();
      } else {
        // Unexpected response type: surface for debugging
        _error = 'Unexpected response type: ${response.runtimeType}';
        debugPrint('loadTodayTasks unexpected response: $response');
        _tasks = [];
      }
    } catch (e) {
      _error = "Failed to load tasks: $e";
    }

    _isLoading = false;
    print("Loaded ${_tasks.length} tasks for $userId in $section at $branchId");
    notifyListeners();
  }

  // ---------------------------------------------------------
  // Mark task as done
  // ---------------------------------------------------------
  /// Toggle task done/open for generic use. Keeps backward compatibility.
  Future<void> toggleTaskDone(String taskId) async {
    try {
      // Determine current status (prefer local copy, fallback to DB)
      String? currentStatus;
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        currentStatus = _tasks[index].status;
      } else {
        final resp = await supabase
            .from('tasks')
            .select('status')
            .eq('id', taskId)
            .maybeSingle();
        if (resp is Map && resp.containsKey('status')) {
          currentStatus = resp['status'] as String?;
        }
      }

      // Toggle: if currently 'done' -> set to 'open', otherwise set to 'done'
      final newStatus = (currentStatus == 'done') ? 'open' : 'done';

      // Determine current user id from the Supabase client
      final currentUserId =
          supabase?.auth.currentUser?.id ??
          Supabase.instance.client.auth.currentUser?.id;

      // If marking as done, set done_by_user to the current user's id.
      // If reverting to open, clear done_by_user (send explicit null).
      final updatePayload = {
        'status': newStatus,
        'done_by_user': newStatus == 'done' ? currentUserId : null,
      };

      await supabase.from('tasks').update(updatePayload).eq('id', taskId);

      // Update local list if present
      final newDoneBy = (newStatus == 'done') ? currentUserId as String? : null;
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(
          status: newStatus,
          doneByUser: newDoneBy,
        );
        notifyListeners();
      } else {
        // If not in local list, keep state untouched but still notify in case UI wants refresh
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error toggling task status: $e");
    }
  }

  // ---------------------------------------------------------
  // Team member API: mark task as done (must set done_by_user to current user)
  // ---------------------------------------------------------
  Future<bool> markTaskAsDone(String taskId, String currentUserId) async {
    try {
      final payload = {'status': 'done', 'done_by_user': currentUserId};

      await supabase.from('tasks').update(payload).eq('id', taskId);

      // Update local list if present
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(
          status: 'done',
          doneByUser: currentUserId,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error markTaskAsDone: $e');
      return false;
    }
  }

  // ---------------------------------------------------------
  // Team member API: reopen task (clear done_by_user)
  // ---------------------------------------------------------
  Future<bool> reopenTask(String taskId) async {
    try {
      final payload = {'status': 'open', 'done_by_user': null};

      await supabase.from('tasks').update(payload).eq('id', taskId);

      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(
          status: 'open',
          doneByUser: null,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('Error reopenTask: $e');
      return false;
    }
  }

  // ---------------------------------------------------------
  // Add note to task
  // ---------------------------------------------------------
  /// Insert a note for [taskId]. Returns `true` on success.
  Future<bool> addNote({
    required String taskId,
    required String userId,
    required String content,
  }) async {
    try {
      final res = await supabase
          .from('task_notes')
          .insert({'task_id': taskId, 'author_id': userId, 'note': content})
          .select()
          .single();

      // success if res is a map with an id
      if (res is Map && res['id'] != null) return true;
      return false;
    } catch (e) {
      debugPrint("Error adding note: $e");
      return false;
    }
  }

  /// Fetch notes for a given task, newest first.
  Future<List<Map<String, dynamic>>> fetchNotes(String taskId) async {
    try {
      final resp = await supabase
          .from('task_notes')
          .select()
          .eq('task_id', taskId)
          .order('created_at', ascending: false);
      final list = resp as List<dynamic>? ?? [];
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      debugPrint('Error fetching notes: $e');
      return [];
    }
  }

  // ---------------------------------------------------------
  // Watch today's tasks (realtime stream)
  // ---------------------------------------------------------
  Stream<List<Task>> watchTodayTasks({
    required String branchId,
    required String section,
    required String userId,
    String? taskDate,
    String status = 'both', // 'both' | 'open' | 'done'
    List<String>? priorities,
  }) {
    final dateFilter =
        taskDate ?? DateTime.now().toIso8601String().split('T').first;
    final safeSection = (section.isNotEmpty) ? section : '_NO_SECTION_';

    final stream = supabase.from('tasks').stream(primaryKey: ['id']);

    return stream.map<List<Task>>((rows) {
      final list = rows as List<dynamic>;
      final filtered = list
          .map((e) => Map<String, dynamic>.from(e as Map))
          .where((row) {
            final matchesBranch = row['branch_id'] == branchId;
            final matchesDate = row['task_date'] == dateFilter;
            final matchesUser =
                row['assigned_to'] == userId ||
                row['assigned_section'] == safeSection;

            if (!matchesBranch || !matchesDate || !matchesUser) return false;

            // status filter
            if (status != 'both') {
              final s = (row['status'] ?? 'open').toString();
              if (s != status) return false;
            }

            // priorities filter
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
        if (pa != pb) return pa.compareTo(pb);
        return (b.taskDate).compareTo(a.taskDate);
      });

      return filtered;
    });
  }

  // ---------------------------------------------------------
  // Clear tasks when logging out
  // ---------------------------------------------------------
  void clearTasks() {
    _tasks = [];
    notifyListeners();
  }
}
