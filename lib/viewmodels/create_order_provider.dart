import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateOrderProvider extends ChangeNotifier {
  CreateOrderProvider();

  // Controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final itemController = TextEditingController();
  final customerNameController = TextEditingController();
  final customerPhoneController = TextEditingController();

  // State
  DateTime orderedDate = DateTime.now();
  DateTime? dueDate;
  String status = 'open';
  String? section;
  String type = 'delivery';

  bool isLoading = false;
  String? error;

  List<String> availableSections = [];

  String createdBy = '';
  String branchId = '';
  // Edit mode
  bool isEditing = false;
  String? editingOrderId;

  void initFromProfile(Map<String, dynamic>? p) {
    createdBy = p?['id'] as String? ?? '';
    branchId = p?['branch_id'] as String? ?? '';
    section = p?['section'] as String?;
    if (branchId.isNotEmpty) fetchSections(branchId);
    notifyListeners();
  }

  Future<void> fetchSections(String branchId) async {
    try {
      final client = Supabase.instance.client;
      List<dynamic> rows = [];

      // Try matching by branch id
      final resById = await client
          .from('sections')
          .select('name')
          .eq('branch', branchId)
          .order('name');
      rows = resById as List<dynamic>? ?? [];

      // Fallback: try by branch name
      if (rows.isEmpty) {
        final branchResp = await client
            .from('branches')
            .select('name')
            .eq('id', branchId)
            .maybeSingle();
        final branchName = branchResp is Map<String, dynamic>
            ? (branchResp['name'] as String?)
            : null;
        if (branchName != null && branchName.isNotEmpty) {
          final resByName = await client
              .from('sections')
              .select('name')
              .eq('branch', branchName)
              .order('name');
          rows = resByName as List<dynamic>? ?? [];
        }
      }

      final secs = <String>[];
      for (final r in rows) {
        final name = (r['name'] ?? '') as String;
        final trimmed = name.trim();
        if (trimmed.isNotEmpty && !secs.contains(trimmed)) secs.add(trimmed);
      }

      // Legacy fallback: profiles.section
      if (secs.isEmpty) {
        final profs = await client
            .from('profiles')
            .select('section')
            .eq('branch_id', branchId)
            .order('section');
        final list = profs as List<dynamic>? ?? [];
        for (final s in list) {
          final sec = (s['section'] ?? '') as String;
          final trimmed = sec.trim();
          if (trimmed.isNotEmpty && !secs.contains(trimmed)) secs.add(trimmed);
        }
      }

      // Ensure uniqueness
      availableSections = secs.toSet().toList();
      if (section == null && availableSections.isNotEmpty)
        section = availableSections.first;
      notifyListeners();
    } catch (e) {
      // ignore errors
    }
  }

  void setOrderedDate(DateTime d) {
    orderedDate = d;
    notifyListeners();
  }

  void setDueDate(DateTime? d) {
    dueDate = d;
    notifyListeners();
  }

  void setSection(String? s) {
    section = s;
    notifyListeners();
  }

  void setType(String t) {
    type = t;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> createOrder() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final client = Supabase.instance.client;
      final payload = <String, dynamic>{
        'created_user_id': createdBy,
        'order_title': titleController.text.trim(),
        'order_description': descriptionController.text.trim(),
        'ordered_date': orderedDate.toIso8601String().split('T').first,
        'due_date': dueDate?.toIso8601String().split('T').first,
        'status': status,
        'section': section ?? '',
        'item': itemController.text.trim(),
        'customer_phone_number': customerPhoneController.text.trim(),
        'customer_name': customerNameController.text.trim(),
        'type': type,
        'branch_id': branchId,
      };

      payload.removeWhere(
        (k, v) => v == null || (v is String && v.trim().isEmpty),
      );

      try {
        // ignore: avoid_print
        print('CreateOrder payload: $payload');
      } catch (_) {}

      final res = await client.from('orders').insert(payload).select().single();

      try {
        // ignore: avoid_print
        print('CreateOrder response: $res');
      } catch (_) {}

      isLoading = false;
      notifyListeners();
      return res as Map<String, dynamic>?;
    } catch (e) {
      error = e.toString();
      try {
        // ignore: avoid_print
        print('CreateOrder error: $error');
      } catch (_) {}
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Initialize provider with an existing order for editing
  void initFromOrder(Map<String, dynamic> order) {
    isEditing = true;
    editingOrderId = order['id'] as String?;
    titleController.text = (order['order_title'] as String?) ?? '';
    descriptionController.text = (order['order_description'] as String?) ?? '';
    itemController.text = (order['item'] as String?) ?? '';
    customerNameController.text = (order['customer_name'] as String?) ?? '';
    customerPhoneController.text =
        (order['customer_phone_number'] as String?) ?? '';

    try {
      if (order['ordered_date'] != null) {
        orderedDate = DateTime.parse(order['ordered_date'].toString());
      }
    } catch (_) {}

    try {
      if (order['due_date'] != null) {
        dueDate = DateTime.parse(order['due_date'].toString());
      }
    } catch (_) {}

    section = (order['section'] as String?) ?? section;
    type = (order['type'] as String?) ?? type;
    // Ensure branch and creator are set
    createdBy = (order['created_user_id'] as String?) ?? createdBy;
    branchId = (order['branch_id'] as String?) ?? branchId;
    notifyListeners();
  }

  /// Update the editing order
  Future<Map<String, dynamic>?> updateOrder() async {
    if (!isEditing || editingOrderId == null) return null;
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final client = Supabase.instance.client;
      final payload = <String, dynamic>{
        'order_title': titleController.text.trim(),
        'order_description': descriptionController.text.trim(),
        'ordered_date': orderedDate.toIso8601String().split('T').first,
        'due_date': dueDate?.toIso8601String().split('T').first,
        'status': status,
        'section': section ?? '',
        'item': itemController.text.trim(),
        'customer_phone_number': customerPhoneController.text.trim(),
        'customer_name': customerNameController.text.trim(),
        'type': type,
        'branch_id': branchId,
      };

      payload.removeWhere(
        (k, v) => v == null || (v is String && v.trim().isEmpty),
      );

      try {
        // ignore: avoid_print
        print('UpdateOrder payload: $payload');
      } catch (_) {}

      final res = await client
          .from('orders')
          .update(payload)
          .eq('id', editingOrderId!)
          .select()
          .single();

      try {
        // ignore: avoid_print
        print('UpdateOrder response: $res');
      } catch (_) {}

      isLoading = false;
      notifyListeners();
      return res as Map<String, dynamic>?;
    } catch (e) {
      error = e.toString();
      try {
        // ignore: avoid_print
        print('UpdateOrder error: $error');
      } catch (_) {}
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Delete order being edited (or by id)
  Future<bool> deleteOrder([String? id]) async {
    final targetId = id ?? editingOrderId;
    if (targetId == null) return false;
    try {
      isLoading = true;
      notifyListeners();
      final client = Supabase.instance.client;
      await client.from('orders').delete().eq('id', targetId);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      try {
        // ignore: avoid_print
        print('DeleteOrder error: $e');
      } catch (_) {}
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void disposeControllers() {
    titleController.dispose();
    descriptionController.dispose();
    itemController.dispose();
    customerNameController.dispose();
    customerPhoneController.dispose();
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }
}
