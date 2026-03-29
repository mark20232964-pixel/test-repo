// lib/screens/user/app_payments.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppPaymentsScreen extends StatefulWidget {
  const AppPaymentsScreen({super.key});

  @override
  State<AppPaymentsScreen> createState() => _AppPaymentsScreenState();
}

class _AppPaymentsScreenState extends State<AppPaymentsScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Payments"),
        ),
        body: const Center(
          child: Text("Please log in"),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payments History"),
        backgroundColor: const Color(0xFF1B1B4B),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("payments")
            .where("userId", isEqualTo: user!.uid)
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No payments data available"));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    "No completed payments yet",
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  const Text(
                    "Your payment history will appear here",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text("Payments loaded successfully"));
        },
      ),
    );
  }
}
