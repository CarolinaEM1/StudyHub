import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'profile_screen.dart';
import 'tasks_screen.dart';
import 'subscription_screen.dart';
import 'notification_topics_screen.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'subjects_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppAuthProvider>().user;

    final items = [
      _DashboardItem(
        icon: Icons.task_alt_rounded,
        title: 'Mis tareas',
        subtitle: 'Consulta y administra tus tareas',
        screen: const TasksScreen(),
      ),
      _DashboardItem(
        icon: Icons.workspace_premium_rounded,
        title: 'Suscripciones',
        subtitle: 'Elige un plan académico',
        screen: const SubscriptionScreen(),
      ),
      _DashboardItem(
        icon: Icons.notifications_active_rounded,
        title: 'Notificaciones',
        subtitle: 'Suscríbete a temas de interés',
        screen: const NotificationTopicsScreen(),
      ),
      _DashboardItem(
        icon: Icons.person_rounded,
        title: 'Mi perfil',
        subtitle: 'Consulta tus datos y plan actual',
        screen: const ProfileScreen(),
      ),
      _DashboardItem(
        icon: Icons.book_rounded,
        title: 'Materias',
        subtitle: 'Registra tus materias escolares',
        screen: const SubjectsScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyHub'),
        actions: [
  StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .snapshots(),
    builder: (context, snapshot) {
      String localAvatar = '';

      if (snapshot.hasData && snapshot.data!.exists) {
        final data = snapshot.data!.data() as Map<String, dynamic>;
        localAvatar = data['localAvatar'] ?? '';
      }

      final hasLocalAvatar =
          localAvatar.isNotEmpty && File(localAvatar).existsSync();

      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: CircleAvatar(
          backgroundImage: hasLocalAvatar
              ? FileImage(File(localAvatar))
              : user.photoURL != null
                  ? NetworkImage(user.photoURL!) as ImageProvider
                  : null,
          child: !hasLocalAvatar && user.photoURL == null
              ? const Icon(Icons.person)
              : null,
        ),
      );
    },
  ),
],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 700;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: [
                    Text(
                      'Hola, ${user?.displayName ?? 'Estudiante'}',
                      style: TextStyle(
                        fontSize: isDesktop ? 34 : 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Organiza tus actividades escolares desde aquí.',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 2 : 1,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        childAspectRatio: isDesktop ? 3.2 : 3.6,
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];

                        return _DashboardCard(
                          icon: item.icon,
                          title: item.title,
                          subtitle: item.subtitle,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => item.screen,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DashboardItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget screen;

  _DashboardItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.screen,
  });
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFDBEAFE),
                child: Icon(
                  icon,
                  color: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}