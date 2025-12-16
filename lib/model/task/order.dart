class Order {
  final String id;
  final String createdUserId;
  final String orderTitle;
  final String? orderDescription;
  final DateTime orderedDate;
  final DateTime? dueDate;
  final DateTime? doneAt;
  final String? doneByUser;
  final String status;
  final String section;
  final String item;
  final String? customerPhoneNumber;
  final String? customerName;
  final String type;
  final String branchId;

  Order({
    required this.id,
    required this.createdUserId,
    required this.orderTitle,
    this.orderDescription,
    required this.orderedDate,
    this.dueDate,
    this.doneAt,
    this.doneByUser,
    required this.status,
    required this.section,
    required this.item,
    this.customerPhoneNumber,
    this.customerName,
    required this.type,
    required this.branchId,
  });

  /// -------------------------
  /// Factory constructor
  /// -------------------------
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      createdUserId: json['created_user_id'] as String,
      orderTitle: json['order_title'] ?? '',
      orderDescription: json['order_description'],
      orderedDate: DateTime.parse(json['ordered_date']),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : null,
      doneAt: json['done_at'] != null ? DateTime.parse(json['done_at']) : null,
      doneByUser: json['done_by'],
      status: json['status'] ?? 'open',
      section: json['section'] ?? '',
      item: json['item'] ?? '',
      customerPhoneNumber: json['customer_phone_number'],
      customerName: json['customer_name'],
      type: json['type'] ?? '',
      branchId: json['branch_id'] as String,
    );
  }

  /// -------------------------
  /// Convert to JSON (for inserts/updates)
  /// -------------------------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_user_id': createdUserId,
      'order_title': orderTitle,
      'order_description': orderDescription,
      'ordered_date': orderedDate.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'done_at': doneAt?.toIso8601String(),
      'done_by': doneByUser,
      'status': status,
      'section': section,
      'item': item,
      'customer_phone_number': customerPhoneNumber,
      'customer_name': customerName,
      'type': type,
      'branch_id': branchId,
    };
  }

  /// -------------------------
  /// CopyWith (useful for editing)
  /// -------------------------
  Order copyWith({
    String? id,
    String? createdUserId,
    String? orderTitle,
    String? orderDescription,
    DateTime? orderedDate,
    DateTime? dueDate,
    DateTime? doneAt,
    String? doneByUser,
    String? status,
    String? section,
    String? item,
    String? customerPhoneNumber,
    String? customerName,
    String? type,
    String? branchId,
  }) {
    return Order(
      id: id ?? this.id,
      createdUserId: createdUserId ?? this.createdUserId,
      orderTitle: orderTitle ?? this.orderTitle,
      orderDescription: orderDescription ?? this.orderDescription,
      orderedDate: orderedDate ?? this.orderedDate,
      dueDate: dueDate ?? this.dueDate,
      doneAt: doneAt ?? this.doneAt,
      doneByUser: doneByUser ?? this.doneByUser,
      status: status ?? this.status,
      section: section ?? this.section,
      item: item ?? this.item,
      customerPhoneNumber: customerPhoneNumber ?? this.customerPhoneNumber,
      customerName: customerName ?? this.customerName,
      type: type ?? this.type,
      branchId: branchId ?? this.branchId,
    );
  }
}
