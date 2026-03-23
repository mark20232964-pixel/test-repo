import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifiedVehicleScreen extends StatefulWidget {
  const VerifiedVehicleScreen({super.key});

  @override
  State<VerifiedVehicleScreen> createState() => _VerifiedVehicleScreenState();
}

class _VerifiedVehicleScreenState extends State<VerifiedVehicleScreen> {
  Map<String, dynamic>? vehicleData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVehicle();
  }

  Future<void> fetchVehicle() async {
    final user = FirebaseAuth.instance.currentUser;
    final snapshot = await FirebaseFirestore.instance
        .collection("vehicles")
        .where("userId", isEqualTo: user?.uid)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        vehicleData = snapshot.docs.first.data();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Verified Vehicle"),
        centerTitle: true,
      ),
      body: isLoading
    ? const Center(child: CircularProgressIndicator())
    : vehicleData == null
        ? const Center(child: Text("No vehicle found"))
        : Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // 🔥 LOGO + BRAND
                Column(
                  children: [
                    const Icon(Icons.directions_car, size: 80),
                    Text(
                      vehicleData!["brand"] ?? "Unknown Brand",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔥 CARD with details
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildRow("Vehicle Model", vehicleData!["model"] ?? "N/A"),
                      const SizedBox(height: 20),
                      buildRow("Number Plate", vehicleData!["plate"] ?? "N/A"),
                      const SizedBox(height: 20),
                      buildRow("Color", vehicleData!["color"] ?? "N/A"),
                      const SizedBox(height: 30),

                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement edit vehicle details later
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Edit feature coming soon')),
                            );
                          },
                          child: const Text("Edit"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }
  Widget buildRow(String title, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 5),
      Text(
        value,
        style: const TextStyle(fontSize: 16),
      ),
      const Divider(),
    ],
  );
}
}