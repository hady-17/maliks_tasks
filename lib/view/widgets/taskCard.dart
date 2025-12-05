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
    // Modern card design with gradient and compact chrome
    final bgGradient = LinearGradient(
      colors: [
        (cardColor ?? const Color(0xFF8C7E7E)).withOpacity(0.95),
        (cardColor ?? const Color(0xFF8C7E7E)).withOpacity(0.85),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    String initials() {
      final name = task.title;
      final parts = name.split(' ');
      if (parts.isEmpty) return '';
      if (parts.length >= 2) {
        return (parts[0][0] + parts[1][0]).toUpperCase();
      }
      return parts[0].substring(0, 1).toUpperCase();
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: bgGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar / initials
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white24,
                child: Text(
                  initials(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _priorityChip(task.priority),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      task.description ?? '',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 10),

                    // Use Wrap so chips wrap to next line on narrow screens
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _metaChip(Icons.calendar_today_rounded, task.taskDate),
                        _metaChip(Icons.person_rounded, task.assignedTo ?? ''),
                        // status pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Colors.green.withOpacity(0.2)
                                : Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isCompleted ? 'Done' : 'Open',
                            style: TextStyle(
                              color: isCompleted ? Colors.green : Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions constrained to fixed width to avoid layout overflow
              SizedBox(
                width: 48,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Complete toggle
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isCompleted ? Icons.check : Icons.circle_outlined,
                          color: Colors.white,
                        ),
                        onPressed: onComplete,
                        splashRadius: 20,
                        padding: const EdgeInsets.all(8),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Edit button
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white70),
                      onPressed: onEdit,
                      splashRadius: 18,
                      padding: const EdgeInsets.all(6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // removed unused _priorityDot

  Widget _priorityChip(String priority) {
    final Map<String, Color> map = {
      'high': Colors.redAccent,
      'medium': Colors.amber,
      'low': Colors.greenAccent,
    };

    final color = map[priority.toLowerCase()] ?? Colors.blueAccent;

    final textColor = color.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority[0].toUpperCase() + priority.substring(1),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String text) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 140),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.white70),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
