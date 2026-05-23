import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final subjectController = TextEditingController();

  Future<void> addSubject() async {
  final user = FirebaseAuth.instance.currentUser;

  if (subjectController.text.isEmpty || user == null) return;

  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  final plan = userDoc.data()?['plan'] ?? 'Básico';

  final subjectsSnapshot = await FirebaseFirestore.instance
      .collection('subjects')
      .where('userId', isEqualTo: user.uid)
      .get();

  if (plan == 'Básico' && subjectsSnapshot.docs.length >= 3) {
    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tu plan Básico solo permite crear hasta 3 materias. Actualiza a Premium o Pro para materias ilimitadas.',
        ),
      ),
    );

    return;
  }

  await FirebaseFirestore.instance.collection('subjects').add({
    'userId': user.uid,
    'name': subjectController.text,
    'createdAt': DateTime.now().toIso8601String(),
  });

  subjectController.clear();

  if (!mounted) return;
  Navigator.pop(context);
}

  void showAddSubjectDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nueva materia'),
        content: TextField(
          controller: subjectController,
          decoration: const InputDecoration(
            labelText: 'Nombre de la materia',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: addSubject,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteSubject(String id) async {
    await FirebaseFirestore.instance.collection('subjects').doc(id).delete();
  }

  @override
  void dispose() {
    subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis materias'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('subjects')
            .where('userId', isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final subjects = snapshot.data!.docs;

          if (subjects.isEmpty) {
            return const Center(
              child: Text('Aún no tienes materias registradas'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              final data = subject.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.book_rounded),
                  ),
                  title: Text(data['name'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteSubject(subject.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddSubjectDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}