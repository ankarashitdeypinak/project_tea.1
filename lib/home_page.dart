import 'login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("TeaPlus Home"),
        backgroundColor: const Color(0xFF2D5A27),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // লগআউট করার পর লগইন পেজে পাঠিয়ে দিবে
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage())
              );
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.eco, size: 80, color: Color(0xFF2D5A27)),
            const SizedBox(height: 20),
            Text(
              "Welcome to TeaPlus!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Logged in as: ${user?.email ?? 'Guest'}"),
          ],
        ),
      ),
    );
  }
}