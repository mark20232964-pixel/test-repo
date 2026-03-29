// lib/screens/user/app_payments.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AppPaymentsScreen extends StatefulWidget {
  const AppPaymentsScreen({super.key});

  @override
  State<AppPaymentsScreen> createState() => _AppPaymentsScreenState();
}

class _AppPaymentsScreenState extends State<AppPaymentsScreen> {
  final user = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot>? _paymentsStream;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _paymentsStream = FirebaseFirestore.instance
          .collection("requests")
          .where("userId", isEqualTo: user!.uid)
          .where('status', isEqualTo: 'completed')
          .orderBy("CompletedAt", descending: true)
          .snapshots();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Refreshed Successfully"),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

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
                ],
              ),
            );
          }

          double total = docs.fold(0.0, (sum, doc) {
            final data = doc.data() as Map<String, dynamic>;
            return sum + ((data['amount'] as num?)?.toDouble() ?? 0.0);
          });

          return Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B4B),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text("Total Spent",
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Text(
                      "LKR ${total.toStringAsFixed(0)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final timestamp =
                        (data['timestamp'] as Timestamp?)?.toDate().toLocal() ??
                            DateTime.now();
                    final status = data['status'] ?? "Unknown";
                    final date =
                        "${timestamp.day}/${timestamp.month}/${timestamp.year}";

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading:
                            const Icon(Icons.check_circle, color: Colors.green),
                        title: Text(
                          data['serviceType'] ?? data['issue'] ?? 'Service',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            date,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ),
                        trailing: Text(
                          "LKR ${(data['amount'] as num?)?.toStringAsFixed(0) ?? '0'}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B1B4B),
                          ),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Payment Details"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "Service: ${data['serviceType'] ?? data['issue'] ?? 'N/A'}"),
                                    const SizedBox(height: 8),
                                    Text(
                                        "Amount: LKR ${(data['amount'] as num?)?.toStringAsFixed(0) ?? '0'}"),
                                    const SizedBox(height: 8),
                                    Text("Status: $status"),
                                    const SizedBox(height: 8),
                                    Text("Date: $date"),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Close"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
