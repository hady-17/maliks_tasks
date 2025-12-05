import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:maliks_tasks/viewmodels/task_provider.dart';

// Simple fake query builder that supports chaining and is awaitable.
class FakeQueryBuilder implements Future<List<Map<String, dynamic>>> {
  final List<Map<String, dynamic>> result;

  FakeQueryBuilder(this.result);

  FakeQueryBuilder select([_]) => this;
  FakeQueryBuilder eq(String a, String b) => this;
  FakeQueryBuilder or(String _) => this;
  FakeQueryBuilder order(String _, {bool ascending = true}) => this;

  @override
  Future<T> then<T>(
    FutureOr<T> Function(List<Map<String, dynamic>>) onValue, {
    Function? onError,
  }) {
    try {
      final res = onValue(result);
      return Future.value(res as T);
    } catch (e) {
      if (onError != null) return Future.error(e) as Future<T>;
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> catchError(
    Function onError, {
    bool Function(Object)? test,
  }) {
    return Future.value(result);
  }

  // Minimal stubs for Future interface
  @override
  Stream<List<Map<String, dynamic>>> asStream() => Stream.value(result);

  @override
  Future<List<Map<String, dynamic>>> timeout(
    Duration timeLimit, {
    FutureOr<List<Map<String, dynamic>>> Function()? onTimeout,
  }) => Future.value(result);

  @override
  Future<List<Map<String, dynamic>>> whenComplete(
    FutureOr Function() action,
  ) async {
    final r = result;
    await action();
    return r;
  }
}

class FakeClient {
  final List<Map<String, dynamic>> result;
  FakeClient(this.result);

  FakeQueryBuilder from(String table) => FakeQueryBuilder(result);
}

void main() {
  test('loadTodayTasks populates tasks list and clears loading flag', () async {
    final sample = [
      {
        'id': 't1',
        'title': 'Task One',
        'description': 'First',
        'priority': 'normal',
        'status': 'open',
        'shift': 'morning',
        'assigned_section': 'A',
        'assigned_to': 'user-1',
        'task_date': DateTime.now().toIso8601String().split('T').first,
      },
    ];

    final fake = FakeClient(sample);
    final provider = TaskProvider(supabaseClient: fake);

    expect(provider.isLoading, isFalse);
    expect(provider.tasks, isEmpty);

    await provider.loadTodayTasks(
      branchId: 'b1',
      section: 'A',
      userId: 'user-1',
    );

    expect(provider.isLoading, isFalse);
    expect(provider.error, isNull);
    expect(provider.tasks.length, 1);
    expect(provider.tasks.first.id, 't1');
    expect(provider.tasks.first.title, 'Task One');
  });
}
