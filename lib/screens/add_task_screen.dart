import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  File? selectedImage;
  bool loading = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> saveTask() async {
  if (titleController.text.isEmpty ||
      descriptionController.text.isEmpty ||
      subjectController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Completa todos los campos')),
    );
    return;
  }

  setState(() {
    loading = true;
  });

  try {
    await context.read<TaskProvider>().addTask(
          title: titleController.text,
          description: descriptionController.text,
          subject: subjectController.text,
          imagePath: selectedImage?.path ?? '',
        );

    if (!mounted) return;

    Navigator.pop(context);
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );

    setState(() {
      loading = false;
    });
  }
}

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva tarea'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 20),
          GestureDetector(
            onTap: pickImage,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFE0ECFF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF2563EB),
                  width: 1.5,
                ),
              ),
              child: selectedImage == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_rounded,
                          size: 50,
                          color: Color(0xFF2563EB),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Agregar imagen local',
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(
                        selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
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
    );
  }
}