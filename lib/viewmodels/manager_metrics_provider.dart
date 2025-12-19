import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _supabase = Supabase.instance.client;

/// ----------------------------
/// Models
/// ----------------------------

class MemberMetric {
  final String userId;
  final String name;

  int tasksPlaced = 0;
  int tasksDone = 0;
  int ordersPlaced = 0;
  int ordersDone = 0;

  int _taskCompletionSeconds = 0;
  int _taskCompletionCount = 0;

  int _orderCompletionSeconds = 0;
  int _orderCompletionCount = 0;

  MemberMetric({required this.userId, required this.name});

  double get avgTaskCompletionMinutes => _taskCompletionCount == 0
      ? 0
      : (_taskCompletionSeconds / _taskCompletionCount) / 60;

  double get avgOrderCompletionMinutes => _orderCompletionCount == 0
      ? 0
      : (_orderCompletionSeconds / _orderCompletionCount) / 60;

  void addTaskCompletion(Duration duration) {
    _taskCompletionSeconds += duration.inSeconds;
    _taskCompletionCount++;
  }

  void addOrderCompletion(Duration duration) {
    _orderCompletionSeconds += duration.inSeconds;
    _orderCompletionCount++;
  }
}

/// ----------------------------
/// Provider
/// ----------------------------

class ManagerMetricsProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  int totalTasksPlaced = 0;
  int totalTasksDone = 0;
  int totalOrdersPlaced = 0;
  int totalOrdersDone = 0;

  double avgTaskCompletionMinutes = 0;
  double avgOrderCompletionMinutes = 0;

  final Map<String, MemberMetric> _memberMetrics = {};

  List<MemberMetric> get memberMetrics =>
      _memberMetrics.values.toList(growable: false);

  /// ----------------------------
  /// Public API
  /// ----------------------------

  Future<void> loadMetrics({
    required String branchId,
    DateTime? from,
    DateTime? to,
  }) async {
    isLoading = true;
    error = null;
    _reset();
    notifyListeners();

    try {
      final members = await _fetchMembers(branchId);
      for (final m in members) {
        _memberMetrics[m['id']] = MemberMetric(
          userId: m['id'],
          name: m['full_name'] ?? 'Unknown',
        );
      }

      await Future.wait([
        _processTasks(branchId, from, to),
        _processOrders(branchId, from, to),
      ]);

      _calculateGlobalAverages();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ----------------------------
  /// Internal Logic
  /// ----------------------------

  void _reset() {
    totalTasksPlaced = 0;
    totalTasksDone = 0;
    totalOrdersPlaced = 0;
    totalOrdersDone = 0;
    avgTaskCompletionMinutes = 0;
    avgOrderCompletionMinutes = 0;
    _memberMetrics.clear();
  }

  Future<List<Map<String, dynamic>>> _fetchMembers(String branchId) async {
    final res = await _supabase
        .from('profiles')
        .select('id, full_name')
        .eq('branch_id', branchId);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> _processTasks(
    String branchId,
    DateTime? from,
    DateTime? to,
  ) async {
    var query = _supabase
        .from('tasks')
        .select('created_by, done_by_user, created_at, done_at')
        .eq('branch_id', branchId);

    if (from != null) query = query.gte('created_at', from.toIso8601String());
    if (to != null) query = query.lte('created_at', to.toIso8601String());

    final tasks = await query;

    for (final t in tasks) {
      final createdBy = t['created_by'];
      final doneBy = t['done_by_user'];

      if (_memberMetrics.containsKey(createdBy)) {
        _memberMetrics[createdBy]!.tasksPlaced++;
        totalTasksPlaced++;
      }

      if (doneBy != null && _memberMetrics.containsKey(doneBy)) {
        _memberMetrics[doneBy]!.tasksDone++;
        totalTasksDone++;

        final createdAt = DateTime.tryParse(t['created_at'] ?? '');
        final doneAt = DateTime.tryParse(t['done_at'] ?? '');

        if (createdAt != null && doneAt != null && doneAt.isAfter(createdAt)) {
          _memberMetrics[doneBy]!.addTaskCompletion(
            doneAt.difference(createdAt),
          );
        }
      }
    }
  }

  Future<void> _processOrders(
    String branchId,
    DateTime? from,
    DateTime? to,
  ) async {
    var query = _supabase
        .from('orders')
        .select('created_user_id, done_by, created_at, done_at')
        .eq('branch_id', branchId);

    if (from != null) query = query.gte('created_at', from.toIso8601String());
    if (to != null) query = query.lte('created_at', to.toIso8601String());

    final orders = await query;

    for (final o in orders) {
      final createdBy = o['created_user_id'];
      final doneBy = o['done_by'];

      if (_memberMetrics.containsKey(createdBy)) {
        _memberMetrics[createdBy]!.ordersPlaced++;
        totalOrdersPlaced++;
      }

      if (doneBy != null && _memberMetrics.containsKey(doneBy)) {
        _memberMetrics[doneBy]!.ordersDone++;
        totalOrdersDone++;

        final createdAt = DateTime.tryParse(o['created_at'] ?? '');
        final doneAt = DateTime.tryParse(o['done_at'] ?? '');

        if (createdAt != null && doneAt != null && doneAt.isAfter(createdAt)) {
          _memberMetrics[doneBy]!.addOrderCompletion(
            doneAt.difference(createdAt),
          );
        }
      }
    }
  }

  void _calculateGlobalAverages() {
    int taskSeconds = 0;
    int taskCount = 0;
    int orderSeconds = 0;
    int orderCount = 0;

    for (final m in _memberMetrics.values) {
      taskSeconds += m._taskCompletionSeconds;
      taskCount += m._taskCompletionCount;
      orderSeconds += m._orderCompletionSeconds;
      orderCount += m._orderCompletionCount;
    }

    avgTaskCompletionMinutes = taskCount == 0
        ? 0
        : (taskSeconds / taskCount) / 60;
    avgOrderCompletionMinutes = orderCount == 0
        ? 0
        : (orderSeconds / orderCount) / 60;
  }
}
