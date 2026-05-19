import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentScreen extends StatefulWidget {
  final String planName;
  final String price;

  const PaymentScreen({
    super.key,
    required this.planName,
    required this.price,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final cardController = TextEditingController();
  final nameController = TextEditingController();
  final dateController = TextEditingController();
  final cvvController = TextEditingController();

  bool loading = false;

  Future<void> confirmPayment() async {
    if (cardController.text.isEmpty ||
        nameController.text.isEmpty ||
        dateController.text.isEmpty ||
        cvvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los datos de pago')),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'name': user.displayName,
      'email': user.email,
      'photoURL': user.photoURL,
      'plan': widget.planName,
      'subscriptionDate': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Suscripción ${widget.planName} activada')),
    );

    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    cardController.dispose();
    nameController.dispose();
    dateController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago simulado'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    widget.planName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.price,
                    style: const TextStyle(
                      fontSize: 30,
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre del titular',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: cardController,
            keyboardType: TextInputType.number,
            maxLength: 16,
            decoration: const InputDecoration(
              labelText: 'Número de tarjeta',
              prefixIcon: Icon(Icons.credit_card),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'MM/AA',
                    prefixIcon: Icon(Icons.date_range),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: cvvController,
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: loading ? null : confirmPayment,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Confirmar pago'),
            ),
          ),
        ],
      ),
    );
  }
}