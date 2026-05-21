import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../providers/task_providers.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskModel task;

  const EditTaskScreen({
    super.key,
    required this.task,
  });

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController subjectController;
  late TextEditingController descriptionController;

  late String selectedPriority;
  late DateTime selectedDueDate;

  String imagePath = '';
  bool loading = false;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.task.title);
    subjectController = TextEditingController(text: widget.task.subject);
    descriptionController =
        TextEditingController(text: widget.task.description);

    selectedPriority = widget.task.priority;
    selectedDueDate = widget.task.dueDate;
    imagePath = widget.task.imagePath;
  }

  Future<void> pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        imagePath = image.path;
      });
    }
  }

  Future<void> pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        selectedDueDate = date;
      });
    }
  }

  Future<void> updateTask() async {
    if (titleController.text.isEmpty ||
        subjectController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    await context.read<TaskProvider>().updateTask(
          id: widget.task.id,
          title: titleController.text,
          subject: subjectController.text,
          description: descriptionController.text,
          imagePath: imagePath,
          priority: selectedPriority,
          dueDate: selectedDueDate,
        );

    if (!mounted) return;

    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    titleController.dispose();
    subjectController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath.isNotEmpty && File(imagePath).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar tarea'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GestureDetector(
            onTap: pickImage,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFE0ECFF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: hasImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.add_photo_alternate_rounded,
                        size: 55,
                        color: Color(0xFF2563EB),
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Título',
              prefixIcon: Icon(Icons.title_rounded),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: subjectController,
            decoration: const InputDecoration(
              labelText: 'Materia',
              prefixIcon: Icon(Icons.book_rounded),
            ),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: selectedPriority,
            decoration: const InputDecoration(
              labelText: 'Prioridad',
              prefixIcon: Icon(Icons.flag_rounded),
            ),
            items: const [
              DropdownMenuItem(value: 'Baja', child: Text('Baja')),
              DropdownMenuItem(value: 'Media', child: Text('Media')),
              DropdownMenuItem(value: 'Alta', child: Text('Alta')),
            ],
            onChanged: (value) {
              setState(() {
                selectedPriority = value!;
              });
            },
          ),

          const SizedBox(height: 16),

          InkWell(
            onTap: pickDueDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Fecha de entrega',
                prefixIcon: Icon(Icons.calendar_month_rounded),
              ),
              child: Text(
                '${selectedDueDate.day}/${selectedDueDate.month}/${selectedDueDate.year}',
              ),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              prefixIcon: Icon(Icons.description_rounded),
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: loading ? null : updateTask,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Guardar cambios'),
            ),
          ),
        ],
      ),
    );
  }
}