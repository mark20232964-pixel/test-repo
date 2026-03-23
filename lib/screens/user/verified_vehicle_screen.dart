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
              : const Center(
                  child: Text('Vehicle data loaded - details coming in next commit'),
                ),
    );
  }
}