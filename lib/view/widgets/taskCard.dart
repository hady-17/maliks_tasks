import 'package:flutter/material.dart';
import '../../model/task/tasks.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Color? cardColor;
  final VoidCallback? onComplete;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const TaskCard({
    super.key,
    required this.task,
    this.cardColor,
    this.onComplete,
    this.onEdit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == 'done';

    return Card(
      color: cardColor ?? Color(0xFF8C7E7E),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + priority color dot
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _priorityDot(task.priority),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                task.description ?? '',
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Date: ${task.taskDate}",
                    style: const TextStyle(color: Colors.white70),
                  ),

                  // Group the status and edit icons so they appear close together
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Complete / status icon as a compact IconButton
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: 18,
                        icon: Icon(
                          isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isCompleted ? Colors.white : Colors.white,
                          size: 25,
                        ),
                        onPressed:
                            onComplete, // forward to card tap handler if provided
                      ),

                      const SizedBox(width: 6),

                      // Edit icon with reduced padding to sit closer
                      IconButton(
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        splashRadius: 20,
                        icon: const Icon(Icons.edit, size: 25),
                        color: Colors.white,
                        onPressed: () {
                          // TODO: Implement edit task functionality
                          if (onEdit != null) {
                            onEdit!();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Priority colored dot
  Widget _priorityDot(String priority) {
    Color color;

    switch (priority.toLowerCase()) {
      case 'high':
        color = Colors.red;
        break;
      case 'low':
        color = Colors.orange;
        break;
      default:
        color = Colors.blue;
    }

    return CircleAvatar(radius: 6, backgroundColor: color);
  }
}
