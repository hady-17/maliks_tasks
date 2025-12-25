import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'manager_metrics_provider.dart';

class MemberDashboardViewModel extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  bool isLoading = false;
  String? error;

  MemberMetric? memberMetric;
  List<Map<String, dynamic>> recentTasks = [];

  Future<void> initWithProfile(Map<String, dynamic> profile) async {
    await loadFor(profile);
  }

  Future<void> loadFor(Map<String, dynamic> profile) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final userId = profile['id'] as String?;
      final branchId = profile['branch_id'] as String?;

      // initialize a basic MemberMetric
      memberMetric = MemberMetric(
        userId: userId ?? '',
        name: profile['full_name'] ?? 'You',
      );

      if (branchId != null) {
        // fetch branch tasks and orders relevant to this member
        await _loadTaskSummaries(userId, branchId);
        await _loadOrderSummaries(userId, branchId);
      }

      await _loadRecentTasks(userId, branchId: branchId);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadTaskSummaries(String? userId, String branchId) async {
    // tasks placed and tasks done where user is creator or done_by
    final q = await _client
        .from('tasks')
        .select('created_by, done_by_user, created_at, done_at')
        .eq('branch_id', branchId);

    final list = q as List<dynamic>? ?? [];
    for (final t in list) {
      final createdBy = t['created_by'];
      final doneBy = t['done_by_user'];

      if (createdBy == userId) {
        memberMetric?.tasksPlaced++;
      }

      if (doneBy == userId) {
        memberMetric?.tasksDone++;
        final createdAt = DateTime.tryParse(t['created_at']?.toString() ?? '');
        final doneAt = DateTime.tryParse(t['done_at']?.toString() ?? '');
        if (createdAt != null && doneAt != null && doneAt.isAfter(createdAt)) {
          memberMetric?.addTaskCompletion(doneAt.difference(createdAt));
        }
      }
    }
  }

  Future<void> _loadOrderSummaries(String? userId, String branchId) async {
    final q = await _client
        .from('orders')
        .select('created_user_id, done_by, created_at, done_at')
        .eq('branch_id', branchId);

    final list = q as List<dynamic>? ?? [];
    for (final o in list) {
      final createdBy = o['created_user_id'];
      final doneBy = o['done_by'];

      if (createdBy == userId) memberMetric?.ordersPlaced++;
      if (doneBy == userId) {
        memberMetric?.ordersDone++;
        final createdAt = DateTime.tryParse(o['created_at']?.toString() ?? '');
        final doneAt = DateTime.tryParse(o['done_at']?.toString() ?? '');
        if (createdAt != null && doneAt != null && doneAt.isAfter(createdAt)) {
          memberMetric?.addOrderCompletion(doneAt.difference(createdAt));
        }
      }
    }
  }

  Future<void> _loadRecentTasks(String? userId, {String? branchId}) async {
    recentTasks = [];
    if (userId == null) return;

    final client = _client;
    final combined = <Map<String, dynamic>>[];

    try {
      final r1 = branchId != null
          ? await client
                .from('tasks')
                .select('id, title, status, task_date, priority')
                .eq('branch_id', branchId)
                .eq('assigned_to', userId)
                .order('task_date', ascending: false)
          : await client
                .from('tasks')
                .select('id, title, status, task_date, priority')
                .eq('assigned_to', userId)
                .order('task_date', ascending: false);
      final l1 = r1 as List<dynamic>? ?? [];
      combined.addAll(l1.map((e) => Map<String, dynamic>.from(e as Map)));
    } catch (_) {}

    try {
      final r2 = branchId != null
          ? await client
                .from('tasks')
                .select('id, title, status, task_date, priority')
                .eq('branch_id', branchId)
                .eq('created_by', userId)
                .order('task_date', ascending: false)
          : await client
                .from('tasks')
                .select('id, title, status, task_date, priority')
                .eq('created_by', userId)
                .order('task_date', ascending: false);
      final l2 = r2 as List<dynamic>? ?? [];
      combined.addAll(l2.map((e) => Map<String, dynamic>.from(e as Map)));
    } catch (_) {}

    // dedupe and sort
    final mapById = <String, Map<String, dynamic>>{};
    for (final t in combined) {
      final id = t['id']?.toString() ?? UniqueKey().toString();
      mapById[id] = t;
    }
    final deduped = mapById.values.toList();
    deduped.sort(
      (a, b) => (b['task_date'] ?? '').toString().compareTo(
        (a['task_date'] ?? '').toString(),
      ),
    );
    recentTasks = deduped;
  }
}
