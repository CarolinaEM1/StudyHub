import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationTopicsScreen extends StatelessWidget {
  const NotificationTopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topics = [
      {
        'name': 'Recordatorios',
        'topic': 'recordatorios',
        'icon': Icons.notifications_active,
      },
      {
        'name': 'Exámenes',
        'topic': 'examenes',
        'icon': Icons.assignment,
      },
      {
        'name': 'Consejos de estudio',
        'topic': 'consejos_estudio',
        'icon': Icons.lightbulb,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Temas de notificación'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final item = topics[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: Icon(
                item['icon'] as IconData,
                color: const Color(0xFF2563EB),
              ),
              title: Text(item['name'] as String),
              subtitle: Text('Tema: ${item['topic']}'),
              trailing: ElevatedButton(
                onPressed: () async {
                  await NotificationService.subscribeToTopic(
                    item['topic'] as String,
                  );

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Suscripción activada: ${item['name']}',
                      ),
                    ),
                  );
                },
                child: const Text('Suscribirme'),
              ),
            ),
          );
        },
      ),
    );
  }
}