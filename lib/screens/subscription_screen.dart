import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'payment_screen.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  Future<void> cancelPlan(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar suscripción'),
        content: const Text(
          '¿Seguro que deseas cancelar tu plan? Volverás al plan Básico.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'plan': 'Básico',
      'subscriptionDate': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Suscripción cancelada. Ahora tienes el plan Básico.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
        'description': 'Incluye estadísticas, próximas tareas y notificaciones',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suscripciones'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          String currentPlan = 'Básico';

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            currentPlan = data['plan'] ?? 'Básico';
          }

          return ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              final planName = plan['name']!;
              final isCurrentPlan = currentPlan == planName;

              return Card(
                margin: const EdgeInsets.only(bottom: 18),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isCurrentPlan)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Plan actual',
                            style: TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      if (isCurrentPlan) const SizedBox(height: 12),

                      Text(
                        planName,
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
                            if (isCurrentPlan &&
                                (planName == 'Premium' ||
                                    planName == 'Pro')) {
                              cancelPlan(context);
                              return;
                            }

                            if (isCurrentPlan && planName == 'Básico') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Actualmente ya tienes el plan Básico.',
                                  ),
                                ),
                              );
                              return;
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentScreen(
                                  planName: planName,
                                  price: plan['price']!,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            isCurrentPlan &&
                                    (planName == 'Premium' ||
                                        planName == 'Pro')
                                ? 'Cancelar plan'
                                : isCurrentPlan && planName == 'Básico'
                                    ? 'Plan actual'
                                    : 'Elegir plan',
                          ),
                        ),
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