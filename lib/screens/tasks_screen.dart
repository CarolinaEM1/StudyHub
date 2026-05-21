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
                hintText: 'Buscar tarea...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
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
                    onTap: () {
                      setState(() {
                        selectedFilter = 'Todas';
                      });
                    },
                  ),
                  _FilterChipItem(
                    label: 'Alta',
                    selected: selectedFilter == 'Alta',
                    onTap: () {
                      setState(() {
                        selectedFilter = 'Alta';
                      });
                    },
                  ),
                  _FilterChipItem(
                    label: 'Media',
                    selected: selectedFilter == 'Media',
                    onTap: () {
                      setState(() {
                        selectedFilter = 'Media';
                      });
                    },
                  ),
                  _FilterChipItem(
                    label: 'Baja',
                    selected: selectedFilter == 'Baja',
                    onTap: () {
                      setState(() {
                        selectedFilter = 'Baja';
                      });
                    },
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
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var tasks = snapshot.data!;

                if (selectedFilter != 'Todas') {
                  tasks = tasks
                      .where((task) => task.priority == selectedFilter)
                      .toList();
                }

                if (searchText.isNotEmpty) {
                  tasks = tasks.where((task) {
                    return task.title
                            .toLowerCase()
                            .contains(searchText) ||
                        task.subject
                            .toLowerCase()
                            .contains(searchText);
                  }).toList();
                }

                if (tasks.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron tareas'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];

                    final hasImage = task.imagePath.isNotEmpty &&
                        File(task.imagePath).existsSync();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasImage)
                            Image.file(
                              File(task.imagePath),
                              height: 170,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TaskDetailScreen(task: task),
                                ),
                              );
                            },
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: _priorityColor(
                                task.priority,
                              ).withOpacity(0.15),
                              child: Icon(
                                Icons.task_alt,
                                color: _priorityColor(task.priority),
                              ),
                            ),
                            title: Text(
                              task.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(task.subject),
                                const SizedBox(height: 6),
                                Text(task.description),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.flag_rounded,
                                      size: 16,
                                      color:
                                          _priorityColor(task.priority),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Prioridad: ${task.priority}',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month_rounded,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Entrega: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Eliminar tarea'),
                                    content: const Text('¿Seguro que deseas eliminar esta tarea?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  taskProvider.deleteTask(task.id);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
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

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'Alta':
        return Colors.red;
      case 'Media':
        return Colors.orange;
      case 'Baja':
        return Colors.green;
      default:
        return Colors.blue;
    }
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