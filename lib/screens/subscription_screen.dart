import 'package:flutter/material.dart';
import 'payment_screen.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plans = [
      {
        'name': 'Básico',
        'price': '\$0 MXN',
        'description': 'Hasta 10 tareas y 3 materias',
      },
      {
        'name': 'Premium',
        'price': '\$99 MXN',
        'description': 'Tareas y materias ilimitadas',
      },
      {
        'name': 'Pro',
        'price': '\$149 MXN',
        'description': 'Estadísticas y recordatorios avanzados',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suscripciones'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 18),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan['name']!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(plan['description']!),
                  const SizedBox(height: 14),
                  Text(
                    plan['price']!,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentScreen(
                              planName: plan['name']!,
                              price: plan['price']!,
                            ),
                          ),
                        );
                      },
                      child: const Text('Elegir plan'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}