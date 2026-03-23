import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../common/role_selection_screen.dart';
import 'verify_vehicle_screen.dart';
import 'verified_vehicle_screen.dart'; // ✅ NEW SCREEN

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  int _selectedIndex = 3;

  final user = FirebaseAuth.instance.currentUser;

  // ✅ NEW FUNCTION (CHECK VEHICLE)
  Future<void> _handleVehicleNavigation() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("vehicles")
        .where("userId", isEqualTo: user?.uid)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // 🔥 Vehicle exists → go to verified screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const VerifiedVehicleScreen(),
        ),
      );
    } else {
      // 🔥 No vehicle → go to verify form
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const VerifyVehicleScreen(),
        ),
      );
    }
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: user?.displayName ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            const SizedBox(height: 16),
            Text(
              "Email: ${user?.email ?? 'Not available'}",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty && newName != user?.displayName) {
                await user?.updateDisplayName(newName);
                await user?.reload();
                setState(() {});
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A48FF)),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),

            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : const NetworkImage('https://via.placeholder.com/150'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Change photo coming soon")),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_outlined,
                            size: 18, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            Text(
              user?.displayName ?? 'User',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? 'No email',
              style: const TextStyle(color: Colors.grey),
            ),

            TextButton(
              onPressed: _showEditProfileDialog,
              child: const Text(
                "Edit profile",
                style: TextStyle(color: Color(0xFF6A48FF)),
              ),
            ),

            const SizedBox(height: 30),

            _buildTile(Icons.history, "History", () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History tapped')));
            }),

            // 🔥 UPDATED TILE
            _buildTile(Icons.notifications_outlined, "Verify vehicle", () {
              _handleVehicleNavigation();
            }),

            _buildTile(Icons.settings_outlined, "Settings", () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings tapped')));
            }),
            _buildTile(Icons.language, "Languages", () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Languages tapped')));
            }),
            _buildTile(Icons.privacy_tip_outlined, "Privacy Policy", () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy Policy tapped')));
            }),
            _buildTile(Icons.help_outline, "Support Center", () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Support Center tapped')));
            }),
            const SizedBox(height: 20),

            _buildTile(Icons.logout, "Log out", _logout),
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
          setState(() {
            _selectedIndex = index;
          });
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

  Widget _buildTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(color: Colors.black)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
      onTap: onTap,
    );
  }
}