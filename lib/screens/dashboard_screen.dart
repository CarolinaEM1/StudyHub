import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'notification_topics_screen.dart';
import 'profile_screen.dart';
import 'subjects_screen.dart';
import 'subscription_screen.dart';
import 'tasks_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppAuthProvider>().user;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      drawer: _AppDrawer(user: user),
      appBar: AppBar(
        title: const Text('StudyHub'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .snapshots(),
        builder: (context, userSnapshot) {
          String plan = 'Básico';

          if (userSnapshot.hasData && userSnapshot.data!.exists) {
            final data = userSnapshot.data!.data() as Map<String, dynamic>;
            plan = data['plan'] ?? 'Básico';
          }

          final isPro = plan == 'Pro';

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 700;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF2563EB),
                              Color(0xFF60A5FA),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 18,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: isDesktop ? 42 : 34,
                              backgroundImage: user?.photoURL != null
                                  ? NetworkImage(user!.photoURL!)
                                  : null,
                              child: user?.photoURL == null
                                  ? const Icon(Icons.person, size: 34)
                                  : null,
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hola, ${user?.displayName ?? 'Estudiante'} 👋',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isDesktop ? 28 : 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Plan actual: $plan',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Inicio',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDBEAFE),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.school_rounded,
                                  color: Color(0xFF2563EB),
                                  size: 36,
                                ),
                              ),
                              const SizedBox(width: 18),
                              const Expanded(
                                child: Text(
                                  'Organiza tus tareas, materias y recordatorios académicos desde un solo lugar.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (isPro)
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('tasks')
                              .where('userId', isEqualTo: currentUser.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            final totalTasks =
                                snapshot.hasData ? snapshot.data!.docs.length : 0;

                            int pendingSoon = 0;

                            if (snapshot.hasData) {
                              final now = DateTime.now();

                              for (final doc in snapshot.data!.docs) {
                                final data = doc.data() as Map<String, dynamic>;
                                final dueDate = DateTime.tryParse(
                                  data['dueDate'] ?? '',
                                );

                                if (dueDate != null &&
                                    dueDate.isAfter(now) &&
                                    dueDate.difference(now).inDays <= 7) {
                                  pendingSoon++;
                                }
                              }
                            }

                            return Row(
                              children: [
                                Expanded(
                                  child: _SummaryCard(
                                    title: 'Tareas',
                                    value: '$totalTasks',
                                    icon: Icons.task_alt_rounded,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _SummaryCard(
                                    title: 'Próximas',
                                    value: '$pendingSoon',
                                    icon: Icons.calendar_month_rounded,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                      if (!isPro)
                        Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFDBEAFE),
                              child: Icon(
                                Icons.workspace_premium_rounded,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            title: const Text(
                              'Mejora tu experiencia',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text(
                              'Actualiza a Pro para desbloquear estadísticas y notificaciones.',
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios_rounded),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SubscriptionScreen(),
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 24),

                      const Text(
                        'Accesos rápidos',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: isDesktop ? 4 : 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        children: [
                          _QuickAccessCard(
                            title: 'Tareas',
                            icon: Icons.task_alt_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TasksScreen(),
                                ),
                              );
                            },
                          ),
                          _QuickAccessCard(
                            title: 'Materias',
                            icon: Icons.book_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SubjectsScreen(),
                                ),
                              );
                            },
                          ),
                          _QuickAccessCard(
                            title: 'Planes',
                            icon: Icons.workspace_premium_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SubscriptionScreen(),
                                ),
                              );
                            },
                          ),
                          _QuickAccessCard(
                            title: 'Perfil',
                            icon: Icons.person_rounded,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfileScreen(),
                                ),
                              );
                            },
                          ),
                          if (isPro)
                            _QuickAccessCard(
                              title: 'Notificaciones',
                              icon: Icons.notifications_active_rounded,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const NotificationTopicsScreen(),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final User? user;

  const _AppDrawer({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          String plan = 'Básico';
          String localAvatar = '';

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            plan = data['plan'] ?? 'Básico';
            localAvatar = data['localAvatar'] ?? '';
          }

          final isPro = plan == 'Pro';
          final hasLocalAvatar =
              localAvatar.isNotEmpty && File(localAvatar).existsSync();

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF2563EB),
                      Color(0xFF60A5FA),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundImage: hasLocalAvatar
                          ? FileImage(File(localAvatar))
                          : user?.photoURL != null
                              ? NetworkImage(user!.photoURL!) as ImageProvider
                              : null,
                      child: !hasLocalAvatar && user?.photoURL == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.displayName ?? 'Estudiante',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      plan,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              _DrawerItem(
                icon: Icons.home_rounded,
                title: 'Inicio',
                onTap: () => Navigator.pop(context),
              ),
              _DrawerItem(
                icon: Icons.task_alt_rounded,
                title: 'Mis tareas',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TasksScreen(),
                    ),
                  );
                },
              ),
              _DrawerItem(
                icon: Icons.book_rounded,
                title: 'Materias',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SubjectsScreen(),
                    ),
                  );
                },
              ),
              _DrawerItem(
                icon: Icons.workspace_premium_rounded,
                title: 'Suscripciones',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SubscriptionScreen(),
                    ),
                  );
                },
              ),
              if (isPro)
                _DrawerItem(
                  icon: Icons.notifications_active_rounded,
                  title: 'Notificaciones',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationTopicsScreen(),
                      ),
                    );
                  },
                ),
              _DrawerItem(
                icon: Icons.person_rounded,
                title: 'Mi perfil',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2563EB)),
      title: Text(title),
      onTap: onTap,
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF2563EB),
                  size: 34,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF2563EB),
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}