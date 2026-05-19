import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_providers.dart';
import 'add_task_screen.dart';
import 'dart:io';
import 'task_detail_screen.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.read<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis tareas'),
      ),
      body: StreamBuilder(
        stream: taskProvider.getTasks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final tasks = snapshot.data!;

          if (tasks.isEmpty) {
            return const Center(
              child: Text('No hay tareas'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (task.imagePath.isNotEmpty && File(task.imagePath).existsSync())
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
                            builder: (_) => TaskDetailScreen(task: task),
                          ),
                        );
                      },
                      contentPadding: const EdgeInsets.all(16),
                      leading: const CircleAvatar(
                        child: Icon(Icons.task_alt),
                      ),
                      title: Text(task.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(task.subject),
                          const SizedBox(height: 6),
                          Text(task.description),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          taskProvider.deleteTask(task.id);
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
}