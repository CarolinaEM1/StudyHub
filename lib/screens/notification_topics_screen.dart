import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationTopicsScreen extends StatefulWidget {
  const NotificationTopicsScreen({super.key});

  @override
  State<NotificationTopicsScreen> createState() =>
      _NotificationTopicsScreenState();
}

class _NotificationTopicsScreenState
    extends State<NotificationTopicsScreen> {
  final Map<String, bool> topics = {
    'Recordatorios de tareas': false,
    'Exámenes': false,
    'Consejos de estudio': false,
  };

  Future<void> toggleTopic(String topic, bool value) async {
    final topicKey = topic
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('á', 'a');

    if (value) {
      await FirebaseMessaging.instance.subscribeToTopic(topicKey);
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topicKey);
    }

    setState(() {
      topics[topic] = value;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Suscrito a $topic'
              : 'Cancelaste suscripción de $topic',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
      ),
      body: ListView(
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
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 42,
                ),
                SizedBox(height: 14),
                Text(
                  'Administra tus notificaciones',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Recibe avisos importantes relacionados con tus actividades académicas.',
                  style: TextStyle(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          ...topics.entries.map(
            (entry) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Card(
                child: SwitchListTile(
                  value: entry.value,
                  onChanged: (value) {
                    toggleTopic(entry.key, value);
                  },
                  secondary: CircleAvatar(
                    backgroundColor: const Color(0xFFDBEAFE),
                    child: Icon(
                      _getIcon(entry.key),
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  title: Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    _getSubtitle(entry.key),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String topic) {
    switch (topic) {
      case 'Recordatorios de tareas':
        return Icons.task_alt_rounded;
      case 'Exámenes':
        return Icons.school_rounded;
      case 'Consejos de estudio':
        return Icons.menu_book_rounded;
      default:
        return Icons.notifications;
    }
  }

  String _getSubtitle(String topic) {
    switch (topic) {
      case 'Recordatorios de tareas':
        return 'Recibe avisos sobre tareas pendientes.';
      case 'Exámenes':
        return 'Mantente informado sobre próximos exámenes.';
      case 'Consejos de estudio':
        return 'Obtén tips y recomendaciones académicas.';
      default:
        return '';
    }
  }
}