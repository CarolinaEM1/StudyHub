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

  @override
  Widget build(BuildContext context) {
    final hasImage =
        task.imagePath.isNotEmpty && File(task.imagePath).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de tarea'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
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
              borderRadius: BorderRadius.circular(22),
              child: Image.file(
                File(task.imagePath),
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 24),
          Text(
            task.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Chip(
            avatar: const Icon(Icons.book, size: 18),
            label: Text(task.subject),
          ),
          const SizedBox(height: 20),
          const Text(
            'Descripción',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            task.description,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}