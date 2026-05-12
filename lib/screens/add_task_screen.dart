import 'package:flutter/material.dart';

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar tarea'),
      ),
      body: const Center(
        child: Text('Formulario para agregar tarea'),
      ),
    );
  }
}