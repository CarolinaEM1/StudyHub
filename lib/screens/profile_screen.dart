import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/auth_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> logout(BuildContext context) async {
    await context.read<AppAuthProvider>().logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> changeAvatar(BuildContext context) async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return;

    if (!context.mounted) return;

    await context.read<AppAuthProvider>().updateLocalAvatar(image.path);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avatar actualizado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppAuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          String plan = 'Sin plan';
          String localAvatar = '';

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            plan = data['plan'] ?? 'Sin plan';
            localAvatar = data['localAvatar'] ?? '';
          }

          final hasLocalAvatar =
              localAvatar.isNotEmpty && File(localAvatar).existsSync();

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: hasLocalAvatar
                          ? FileImage(File(localAvatar))
                          : user.photoURL != null
                              ? NetworkImage(user.photoURL!) as ImageProvider
                              : null,
                      child: !hasLocalAvatar && user.photoURL == null
                          ? const Icon(Icons.person, size: 55)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFF2563EB),
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                          onPressed: () => changeAvatar(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  user.displayName ?? 'Usuario',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.email ?? 'Sin correo',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 25),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.workspace_premium_rounded,
                      color: Color(0xFF2563EB),
                    ),
                    title: const Text('Plan actual'),
                    subtitle: Text(plan),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => logout(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}