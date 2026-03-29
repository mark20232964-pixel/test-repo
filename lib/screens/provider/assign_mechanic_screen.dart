import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AssignMechanicScreen extends StatelessWidget {
  final String requestId;

  const AssignMechanicScreen({super.key, required this.requestId});

  Future<void> assignMechanic(BuildContext context, String name) async {
    await FirebaseFirestore.instance
        .collection('requests')
        .doc(requestId)
        .update({
      'assignedMechanic': name,
    });

    Navigator.pop(context, name); // 🔥 RETURN NAME
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Mechanic'),
        backgroundColor: const Color(0xFF1B1B4B),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('garages')
            .where('createdBy', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final garage = snapshot.data!.docs[index];
              final workers = garage['workers'] as List<dynamic>? ?? [];

              return Column(
                children: workers.map((workerData) {
                  final worker = workerData as Map<String, dynamic>;
                  final name = worker['name'] ?? 'Unknown';

                  return Card(
                    child: ListTile(
                      title: Text(name),
                      trailing: ElevatedButton(
                        onPressed: () => assignMechanic(context, name),
                        child: const Text("ASSIGN"),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
