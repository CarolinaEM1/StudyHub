import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_providers.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String selectedFilter = 'Todas';
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.read<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis tareas'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar tarea o materia...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchText.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            searchText = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChipItem(
                    label: 'Todas',
                    selected: selectedFilter == 'Todas',
                    onTap: () => setState(() => selectedFilter = 'Todas'),
                  ),
                  _FilterChipItem(
                    label: 'Alta',
                    selected: selectedFilter == 'Alta',
                    onTap: () => setState(() => selectedFilter = 'Alta'),
                  ),
                  _FilterChipItem(
                    label: 'Media',
                    selected: selectedFilter == 'Media',
                    onTap: () => setState(() => selectedFilter = 'Media'),
                  ),
                  _FilterChipItem(
                    label: 'Baja',
                    selected: selectedFilter == 'Baja',
                    onTap: () => setState(() => selectedFilter = 'Baja'),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder(
              stream: taskProvider.getTasks(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var tasks = snapshot.data!;

                if (selectedFilter != 'Todas') {
                  tasks = tasks
                      .where((task) => task.priority == selectedFilter)
                      .toList();
                }

                if (searchText.isNotEmpty) {
                  tasks = tasks.where((task) {
                    return task.title.toLowerCase().contains(searchText) ||
                        task.subject.toLowerCase().contains(searchText);
                  }).toList();
                }

                if (tasks.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron tareas'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];

                    return _TaskCard(
                      title: task.title,
                      description: task.description,
                      subject: task.subject,
                      priority: task.priority,
                      dueDate:
                          '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                      imagePath: task.imagePath,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskDetailScreen(task: task),
                          ),
                        );
                      },
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Eliminar tarea'),
                            content: const Text(
                              '¿Seguro que deseas eliminar esta tarea?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          taskProvider.deleteTask(task.id);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTaskScreen(),
            ),
          );
        },
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final String subject;
  final String priority;
  final String dueDate;
  final String imagePath;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.title,
    required this.description,
    required this.subject,
    required this.priority,
    required this.dueDate,
    required this.imagePath,
    required this.onTap,
    required this.onDelete,
  });

  Color get priorityColor {
    switch (priority) {
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

  IconData get priorityIcon {
    switch (priority) {
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
    final hasImage = imagePath.isNotEmpty && File(imagePath).existsSync();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(26),
                    ),
                    child: Image.file(
                      File(imagePath),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: _PriorityBadge(
                      label: priority,
                      color: priorityColor,
                      icon: priorityIcon,
                    ),
                  ),
                ],
              ),

            if (!hasImage)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _PriorityBadge(
                    label: priority,
                    color: priorityColor,
                    icon: priorityIcon,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.task_alt_rounded,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _InfoPill(
                        icon: Icons.book_rounded,
                        label: subject,
                      ),
                      _InfoPill(
                        icon: Icons.calendar_month_rounded,
                        label: dueDate,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _PriorityBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 5),
          Text(
            label,
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
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2563EB)),
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

class _FilterChipItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}