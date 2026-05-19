import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/task_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addTask({
  required String title,
  required String description,
  required String subject,
  String imagePath = '',
}) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw Exception('Usuario no autenticado');
  }

  final userDoc = await _firestore.collection('users').doc(user.uid).get();
  final plan = userDoc.data()?['plan'] ?? 'Básico';

  final tasksSnapshot = await _firestore
      .collection('tasks')
      .where('userId', isEqualTo: user.uid)
      .get();

  if (plan == 'Básico' && tasksSnapshot.docs.length >= 10) {
    throw Exception(
      'Tu plan Básico solo permite crear hasta 10 tareas. Actualiza a Premium para tareas ilimitadas.',
    );
  }

  await _firestore.collection('tasks').add({
    'userId': user.uid,
    'title': title,
    'description': description,
    'subject': subject,
    'imagePath': imagePath,
    'createdAt': DateTime.now().toIso8601String(),
  });
}

  Stream<List<TaskModel>> getTasks() {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return Stream.value([]);
  }

  return _firestore
      .collection('tasks')
      .where('userId', isEqualTo: user.uid)
      .snapshots()
      .map(
        (snapshot) {
          final tasks = snapshot.docs
              .map(
                (doc) => TaskModel.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList();

          tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return tasks;
        },
      );
}

  Future<void> deleteTask(String id) async {
    await _firestore.collection('tasks').doc(id).delete();
  }
}