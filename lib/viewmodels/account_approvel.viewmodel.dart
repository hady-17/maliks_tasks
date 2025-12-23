import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountApprovelViewModel extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  StreamSubscription<List<Map<String, dynamic>>>? _sub;

  bool isLoading = false;
  List<Map<String, dynamic>> inactiveUsers = [];

  int get pendingCount => inactiveUsers.length;

  Future<void> loadForCurrentManager() async {
    isLoading = true;
    notifyListeners();
    try {
      final uid = _client.auth.currentUser?.id;
      if (uid == null) return;

      final prof = await _client
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();
      final branchId = prof == null ? null : prof['branch_id'] as String?;
      if (branchId == null) return;

      final res = await _client
          .from('profiles')
          .select()
          .eq('branch_id', branchId)
          .eq('active', false)
          .order('full_name');

      final list = res as List<dynamic>? ?? [];
      inactiveUsers = list
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      // start realtime subscription for live updates
      _subscribeToBranch(branchId);
    } catch (e) {
      inactiveUsers = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _subscribeToBranch(String branchId) {
    // cancel existing
    _sub?.cancel();

    final stream = _client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('branch_id', branchId)
        .order('full_name');

    _sub = stream.listen(
      (List<Map<String, dynamic>> data) {
        // filter inactive only
        inactiveUsers = data.where((e) => e['active'] == false).toList();
        notifyListeners();
      },
      onError: (_) {
        // ignore stream errors
      },
    );
  }

  Future<bool> approveUser(String userId) async {
    try {
      await _client.from('profiles').update({'active': true}).eq('id', userId);

      // local removal will happen via realtime stream; keep optimistic remove too
      inactiveUsers.removeWhere((u) => u['id'] == userId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
