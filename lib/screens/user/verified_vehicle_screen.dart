import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

/// VerifiedVehicleScreen
/// Displays the user's verified vehicle information fetched from Firestore.
/// Supports real-time updates, loading/error/empty states, and bottom navigation.
class VerifiedVehicleScreen extends StatefulWidget {
  const VerifiedVehicleScreen({super.key});

  @override
  State<VerifiedVehicleScreen> createState() => _VerifiedVehicleScreenState();
}

class _VerifiedVehicleScreenState extends State<VerifiedVehicleScreen> {
  Map<String, dynamic>? vehicleData;
  bool isLoading = true;
  int _selectedIndex = 3; // start with profile tab highlighted

  StreamSubscription<QuerySnapshot>? _subscription;

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
          vehicleData = snapshot.docs.isNotEmpty ? snapshot.docs.first.data() : null;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Verified Vehicle"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A48FF)),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Loading your vehicle details...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : vehicleData == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sentiment_dissatisfied_outlined,
                            size: 90, color: Colors.grey[400]),
                        const SizedBox(height: 24),
                        const Text(
                          'No vehicle registered yet',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Add your vehicle to get verified and unlock full RoadResQ features',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Navigate to "Add Vehicle" screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Add vehicle feature coming soon')),
                            );
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Add Vehicle'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A48FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    // TODO: Force refresh vehicle data
                    await Future.delayed(const Duration(milliseconds: 800));
                    setState(() => isLoading = true);
                    _listenToVehicle();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        // LOGO + BRAND
                        Column(
                          children: [
                            Icon(Icons.directions_car_filled,
                                size: 90, color: const Color(0xFF6A48FF)),
                            const SizedBox(height: 12),
                            Text(
                              vehicleData!["brand"] ?? "Unknown Brand",
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6A48FF),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // CARD with details
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildRow("Vehicle Model", vehicleData!["model"] ?? "N/A"),
                                const Divider(height: 32),
                                buildRow("Number Plate", vehicleData!["plate"] ?? "N/A"),
                                const Divider(height: 32),
                                buildRow("Color", vehicleData!["color"] ?? "N/A"),
                                const SizedBox(height: 40),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // TODO: Implement edit vehicle details
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Edit feature coming soon')),
                                      );
                                    },
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text("Edit Vehicle"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6A48FF),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
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
                ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF6A48FF),
        unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: ""),
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

  Widget buildRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 17),
        ),
        const Divider(height: 30),
      ],
    );
  }
}