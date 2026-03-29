import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class VerifiedVehicleScreen extends StatefulWidget {
  const VerifiedVehicleScreen({super.key});

  @override
  State<VerifiedVehicleScreen> createState() => _VerifiedVehicleScreenState();
}

class _VerifiedVehicleScreenState extends State<VerifiedVehicleScreen> {
  Map<String, dynamic>? vehicleData;
  bool isLoading = true;
  bool isEditing = false;

  int _selectedIndex = 3;

  StreamSubscription<QuerySnapshot>? _subscription;

  late TextEditingController modelController;
  late TextEditingController plateController;
  late TextEditingController colorController;

  @override
  void initState() {
    super.initState();
    _listenToVehicle();
  }

  void _listenToVehicle() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    _subscription = FirebaseFirestore.instance
        .collection("vehicles")
        .where("userId", isEqualTo: user.uid)
        .limit(1)
        .snapshots()
        .listen(
      (snapshot) {
        setState(() {
          vehicleData = snapshot.docs.isNotEmpty
              ? snapshot.docs.first.data() as Map<String, dynamic>
              : null;

          if (vehicleData != null) {
            modelController =
                TextEditingController(text: vehicleData!["model"]);
            plateController =
                TextEditingController(text: vehicleData!["plate"]);
            colorController =
                TextEditingController(text: vehicleData!["color"]);
          }

          isLoading = false;
        });
      },
      onError: (error) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading vehicle: $error')),
        );
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    modelController.dispose();
    plateController.dispose();
    colorController.dispose();
    super.dispose();
  }

  Future<void> _updateVehicle() async {
    final user = FirebaseAuth.instance.currentUser;

    final query = await FirebaseFirestore.instance
        .collection("vehicles")
        .where("userId", isEqualTo: user!.uid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update({
        "model": modelController.text.trim(),
        "plate": plateController.text.trim(),
        "color": colorController.text.trim(),
      });
    }

    setState(() {
      isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Vehicle Updated ✅")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Verified Vehicle"),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Loading your vehicle details...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : vehicleData == null
              ? const Center(child: Text("No vehicle found"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // ICON + BRAND
                      Column(
                        children: [
                          Icon(
                            Icons.directions_car_filled,
                            size: 90,
                            color: const Color.fromARGB(255, 11, 11, 35),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            vehicleData!["brand"] ?? "Unknown Brand",
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 21, 17, 39),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // CARD
                      Card(
                        elevation: 4,
                        color: const Color.fromARGB(255, 206, 206, 206),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildRow("Vehicle Model", modelController),
                              buildRow("Number Plate", plateController),
                              buildRow("Color", colorController),

                              const SizedBox(height: 30),

                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    if (!isEditing) {
                                      setState(() {
                                        isEditing = true;
                                      });
                                    } else {
                                      _updateVehicle();
                                    }
                                  },
                                  icon: Icon(
                                      isEditing ? Icons.check : Icons.edit),
                                  label: Text(
                                      isEditing ? "Submit" : "Edit Vehicle"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 5, 4, 13),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF6A48FF),
        unselectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ""),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined), label: ""),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF6A48FF),
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            label: "",
          ),
        ],
      ),
    );
  }

  Widget buildRow(String title, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(137, 42, 42, 42),
          ),
        ),
        const SizedBox(height: 6),

        isEditing
            ? TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                ),
              )
            : Text(
                controller.text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(221, 23, 23, 23),
                ),
              ),

        const Divider(height: 30),
      ],
    );
  }
}