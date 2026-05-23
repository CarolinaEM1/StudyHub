import 'dart:io';
import 'package:flutter/material.dart';

import '../models/task_model.dart';
import 'edit_task_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskModel task;

  const TaskDetailScreen({
    super.key,
    required this.task,
  });

  Color get priorityColor {
    switch (task.priority) {
      case 'Alta':
        return Colors.red;
      case 'Media':
        return Colors.orange;
      case 'Baja':
        return Colors.green;
      default:
        return const Color(0xFF2563EB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        task.imagePath.isNotEmpty && File(task.imagePath).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de tarea'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditTaskScreen(task: task),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (hasImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.file(
                File(task.imagePath),
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PriorityBadge(
                  label: task.priority,
                  color: priorityColor,
                ),

                const SizedBox(height: 16),

                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _InfoPill(
                      icon: Icons.book_rounded,
                      label: task.subject,
                    ),
                    _InfoPill(
                      icon: Icons.calendar_month_rounded,
                      label:
                          '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  'Descripción',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  task.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _PriorityBadge({
    required this.label,
    required this.color,
  });

  IconData get icon {
    switch (label) {
      case 'Alta':
        return Icons.priority_high_rounded;
      case 'Media':
        return Icons.flag_rounded;
      case 'Baja':
        return Icons.check_circle_rounded;
      default:
        return Icons.flag_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const SizedBox(width: 6),
          Text(
            'Prioridad $label',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: const Color(0xFF2563EB)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}