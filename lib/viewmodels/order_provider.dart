import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/task/order.dart';

class OrderProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  // Track order ids currently being toggled so we can suppress intermediate
  // stream updates until the server confirms the change.
  final Set<String> _inFlightToggles = {};

  // Cache of last emitted orders by id to allow returning the previous
  // state for orders that are in-flight.
  final Map<String, Order> _lastEmittedById = {};

  /// Watch orders in real-time for a specific branch and date
  Stream<List<Order>> watchTodayOrders({
    required String branchId,
    required String section,
    required String userId,
    required String orderDate,
    String status = 'both',
    List<String>? types,
    String scope = 'all', // 'all' | 'yours'
  }) {
    // Build the stream query
    var streamBuilder = _supabase.from('orders').stream(primaryKey: ['id']);

    final mapped = streamBuilder.map((data) {
      List<Order> orders = data.map((json) => Order.fromJson(json)).toList();

      // Filter by branch
      orders = orders.where((o) => o.branchId == branchId).toList();

      // Filter by date
      orders = orders
          .where(
            (o) =>
                o.orderedDate.toIso8601String().split('T').first == orderDate,
          )
          .toList();

      // Scope handling: if user requested 'yours', filter to orders
      // created by the user or in the user's section. Otherwise, if
      // section is provided (non-empty) filter by that section.
      if (scope == 'yours') {
        final safeSection = (section.isNotEmpty) ? section : '_NO_SECTION_';
        orders = orders
            .where((o) => o.createdUserId == userId || o.section == safeSection)
            .toList();
      } else {
        if (section.isNotEmpty) {
          orders = orders.where((o) => o.section == section).toList();
        }
      }

      // Filter by status
      if (status != 'both') {
        orders = orders.where((o) => o.status == status).toList();
      }

      // Filter by types if provided
      if (types != null && types.isNotEmpty) {
        orders = orders.where((o) => types.contains(o.type)).toList();
      }

      // Sort by status (open first), then by ordered date
      orders.sort((a, b) {
        if (a.status != b.status) {
          return a.status == 'open' ? -1 : 1;
        }
        return b.orderedDate.compareTo(a.orderedDate);
      });

      // If some orders are currently being toggled, substitute their
      // last-emitted value so the UI doesn't show the intermediate state
      // until the toggle completes successfully.
      final effective = orders.map((o) {
        if (_inFlightToggles.contains(o.id) &&
            _lastEmittedById.containsKey(o.id)) {
          return _lastEmittedById[o.id]!;
        }
        return o;
      }).toList();

      // Update cache for next emission
      for (final o in effective) {
        _lastEmittedById[o.id] = o;
      }

      return effective;
    });

    // Prevent emitting identical consecutive lists (Supabase can sometimes
    // emit duplicate events). Use `distinct` with a lightweight comparator
    // that checks ids and status/doneAt to avoid unnecessary UI rebuilds.
    return mapped.distinct((prev, next) => _ordersListEquals(prev, next));
  }

  bool _ordersListEquals(List<Order> a, List<Order> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      final x = a[i];
      final y = b[i];
      if (x.id != y.id) return false;
      if (x.status != y.status) return false;
      final xa = x.doneAt?.toIso8601String() ?? '';
      final ya = y.doneAt?.toIso8601String() ?? '';
      if (xa != ya) return false;
    }
    return true;
  }

  /// Toggle order status between 'open' and 'completed'
  Future<void> toggleOrderStatus(String orderId) async {
    try {
      // mark as in-flight before issuing update so stream mapping can hold
      // the previous state for this order until we receive confirmation
      _inFlightToggles.add(orderId);
      // ensure listeners that inspect provider state know about this change
      notifyListeners();
      // Fetch current order
      final response = await _supabase
          .from('orders')
          .select()
          .eq('id', orderId)
          .single();
      final currentStatus = (response['status'] as String?) ?? 'open';
      final now = DateTime.now().toUtc();
      final bool markingComplete = currentStatus != 'completed';
      final newStatus = markingComplete ? 'completed' : 'open';

      // Prepare update payload: set done_at to now when completing, or null when reopening
      final currentUserId =
          _supabase.auth.currentUser?.id ??
          Supabase.instance.client.auth.currentUser?.id;

      final updatePayload = <String, dynamic>{'status': newStatus};
      if (markingComplete) {
        updatePayload['done_at'] = now.toIso8601String();
        // record who completed the order (store UUID)
        updatePayload['done_by'] = currentUserId;
      } else {
        updatePayload['done_at'] = null;
        updatePayload['done_by'] = null;
      }

      // Update status and done_at atomically
      await _supabase.from('orders').update(updatePayload).eq('id', orderId);

      // update succeeded; remove in-flight marker so stream updates are accepted
      _inFlightToggles.remove(orderId);
      notifyListeners();
    } catch (e) {
      print('Error toggling order status: $e');
      // remove in-flight marker on error so UI can resume normal updates
      _inFlightToggles.remove(orderId);
      notifyListeners();
      rethrow;
    }
  }

  bool isToggling(String orderId) => _inFlightToggles.contains(orderId);

  /// Create a new order
  Future<Order> createOrder(Order order) async {
    try {
      final response = await _supabase
          .from('orders')
          .insert(order.toJson())
          .select()
          .single();
      // Do not call notifyListeners here; rely on Supabase stream updates.
      return Order.fromJson(response);
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  /// Update an existing order
  Future<void> updateOrder(Order order) async {
    try {
      await _supabase.from('orders').update(order.toJson()).eq('id', order.id);
      // rely on Supabase stream to notify UI
    } catch (e) {
      print('Error updating order: $e');
      rethrow;
    }
  }

  /// Delete an order
  Future<void> deleteOrder(String orderId) async {
    try {
      await _supabase.from('orders').delete().eq('id', orderId);
      // rely on Supabase realtime stream to update UI
    } catch (e) {
      print('Error deleting order: $e');
      rethrow;
    }
  }
}
