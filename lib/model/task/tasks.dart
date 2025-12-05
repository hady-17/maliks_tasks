class Task {
  final String id;
  final String title;
  final String? description;
  final String priority;
  final String status;
  final String shift;
  final String? assignedSection;
  final String? assignedTo;
  final String taskDate;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    required this.shift,
    this.assignedSection,
    this.assignedTo,
    required this.taskDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      priority: json['priority'],
      status: json['status'],
      shift: json['shift'],
      assignedSection: json['assigned_section'],
      assignedTo: json['assigned_to'],
      taskDate: json['task_date'],
    );
  }

  // FIXED: copyWith implementation
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? priority,
    String? status,
    String? shift,
    String? assignedSection,
    String? assignedTo,
    String? taskDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      shift: shift ?? this.shift,
      assignedSection: assignedSection ?? this.assignedSection,
      assignedTo: assignedTo ?? this.assignedTo,
      taskDate: taskDate ?? this.taskDate,
    );
  }
}
