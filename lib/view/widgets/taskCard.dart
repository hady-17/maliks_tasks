import 'package:flutter/material.dart';
import '../../model/task/tasks.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/task_provider.dart';
import '../../const.dart';

// Simple in-memory cache for profile id -> display name to avoid repeated DB calls.
final Map<String, String> _profileNameCache = {};

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
      color: cardColor ?? kMainColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Main content
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
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _priorityChip(task.priority),
                      ],
                    ),
                    if ((task.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        task.description ?? '',
                        style: const TextStyle(color: Colors.white70),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _profileChip(Icons.person, task.assignedTo),
                        const SizedBox(width: 10),
                        if (task.doneByUser != null &&
                            task.doneByUser!.isNotEmpty)
                          _profileChip(Icons.check_circle, task.doneByUser),
                        const Spacer(),
                        _statusChip(isCompleted),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              const SizedBox(width: 16),
              SizedBox(
                width: 48,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isCompleted
                              ? Icons.check
                              : Icons.radio_button_unchecked,
                          color: Colors.white,
                        ),
                        onPressed: onComplete,
                        splashRadius: 20,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Notes button with badge
                    _notesButton(context),

                    const SizedBox(height: 10),

                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white70),
                      onPressed: onEdit,
                      splashRadius: 18,
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
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

  Widget _notesButton(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Provider.of<TaskProvider>(
        context,
        listen: false,
      ).fetchNotes(task.id),
      builder: (ctx, snap) {
        final hasNotes = snap.hasData && (snap.data?.isNotEmpty ?? false);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.note_add, color: Colors.white70),
              onPressed: () => _openNotesDialog(context),
              splashRadius: 18,
              padding: const EdgeInsets.all(6),
            ),
            if (hasNotes)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _openNotesDialog(BuildContext context) async {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Not authenticated')));
      }
      return;
    }

    final provider = Provider.of<TaskProvider>(context, listen: false);
    List<Map<String, dynamic>> notes = await provider.fetchNotes(task.id);

    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: StatefulBuilder(
              builder: (dCtx, setState) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: kMainColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        topRight: Radius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Notes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.of(dCtx).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: SizedBox(
                      height: 320,
                      child: notes.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.note_outlined,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'No notes yet',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: notes.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (ctx2, i) {
                                final n = notes[i];
                                final text = (n['note'] ?? '') as String;
                                final authorId =
                                    n['author_id']?.toString() ?? '';
                                final created = n['created_at'];
                                DateTime? createdAt;
                                try {
                                  if (created != null)
                                    createdAt = DateTime.parse(
                                      created.toString(),
                                    ).toLocal();
                                } catch (_) {}
                                return Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(text),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            FutureBuilder<String>(
                                              future: _fetchProfileName(
                                                authorId,
                                              ),
                                              builder: (sCtx, sSnap) {
                                                final name =
                                                    (sSnap.hasData &&
                                                        (sSnap
                                                                .data
                                                                ?.isNotEmpty ??
                                                            false))
                                                    ? sSnap.data!
                                                    : (authorId.isNotEmpty
                                                          ? authorId.substring(
                                                              0,
                                                              8,
                                                            )
                                                          : 'Unknown');
                                                return Text(
                                                  name,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                );
                                              },
                                            ),
                                            Text(
                                              createdAt != null
                                                  ? '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}'
                                                  : (created ?? ''),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black38,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            maxLines: 3,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              hintText: 'Write a note...',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                          ),
                          onPressed: () async {
                            final content = controller.text.trim();
                            if (content.isEmpty) return;
                            final ok = await provider.addNote(
                              taskId: task.id,
                              userId: currentUserId,
                              content: content,
                            );
                            if (ok) {
                              setState(() {
                                notes.insert(0, {
                                  'note': content,
                                  'author_id': currentUserId,
                                  'created_at': DateTime.now()
                                      .toIso8601String(),
                                });
                                controller.clear();
                              });
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to add note'),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Icon(Icons.send, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

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

  Widget _statusChip(bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.withOpacity(0.2) : Colors.white24,
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

  Widget _profileChip(IconData icon, String? userId) {
    if (userId == null || userId.trim().isEmpty)
      return _metaChip(icon, 'Unassigned');
    final currentId = Supabase.instance.client.auth.currentUser?.id;
    if (currentId != null && currentId == userId) return _metaChip(icon, 'You');

    return FutureBuilder<String>(
      future: _fetchProfileName(userId),
      builder: (context, snap) {
        String text;
        if (snap.connectionState == ConnectionState.waiting) {
          text = '...';
        } else if (snap.hasData && (snap.data?.trim().isNotEmpty ?? false)) {
          text = snap.data!;
        } else {
          final short = (userId.length >= 8) ? userId.substring(0, 8) : userId;
          text = 'By $short';
        }
        return _metaChip(icon, text);
      },
    );
  }

  Future<String> _fetchProfileName(String userId) async {
    if (_profileNameCache.containsKey(userId))
      return _profileNameCache[userId]!;
    try {
      final client = Supabase.instance.client;
      final resp = await client
          .from('profiles')
          .select('full_name')
          .eq('id', userId)
          .maybeSingle();
      if (resp != null && resp['full_name'] != null) {
        final name = resp['full_name'] as String;
        _profileNameCache[userId] = name;
        return name;
      }
    } catch (_) {}
    return '';
  }
}
