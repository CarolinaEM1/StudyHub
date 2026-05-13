import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_providers.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final subjectController = TextEditingController();

  bool loading = false;

  Future<void> saveTask() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        subjectController.text.isEmpty) {
      return;
    }

    setState(() {
      loading = true;
    });

    await context.read<TaskProvider>().addTask(
          title: titleController.text,
          description: descriptionController.text,
          subject: subjectController.text,
        );

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva tarea'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Materia',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Descripción',
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: loading ? null : saveTask,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Guardar tarea'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}