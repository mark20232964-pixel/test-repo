// lib/screens/provider/profile_screen.dart
//
// Provider Profile Screen
// Displays provider info, allows editing profile,
// shows list of options, and logout to role selection.
// Built incrementally in 10 commits for clear progress.
// Features: dynamic name/email, edit dialog, list tiles, bottom nav with highlight.
// Note: Firebase integration (Firestore/Storage) can be added later.

import 'package:flutter/material.dart';
import '../common/role_selection_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Editable provider data
  String _providerName = "Provider Name";
  String _providerEmail = "provider@example.com";

  // Bottom nav selected index — starts with profile tab highlighted
  int _selectedIndex = 3; // 3 = profile avatar

  // Edit profile dialog
  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _providerName);
    final emailController = TextEditingController(text: _providerEmail);

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
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _providerName = nameController.text.trim().isNotEmpty
                    ? nameController.text
                    : _providerName;
                _providerEmail = emailController.text.trim().isNotEmpty
                    ? emailController.text
                    : _providerEmail;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A48FF),
            ),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Profile photo + camera overlay
            Center(
              child: Stack(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        NetworkImage('https://via.placeholder.com/150'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Change photo coming soon')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text(
              _providerName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _providerEmail,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            TextButton(
              onPressed: _showEditProfileDialog,
              child: const Text(
                "Edit profile",
                style: TextStyle(color: Color(0xFF6A48FF)),
              ),
            ),

            const SizedBox(height: 30),

            // List tiles
            _buildTile(Icons.history, "History", () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History tapped')),
              );
            }),
            _buildTile(Icons.notifications_outlined, "Verify doc", () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verify doc tapped')),
              );
            }),
            _buildTile(Icons.settings_outlined, "Settings", () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings tapped')),
              );
            }),
            _buildTile(Icons.language, "Languages", () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Languages tapped')),
              );
            }),
            _buildTile(Icons.privacy_tip_outlined, "Privacy Policy", () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy Policy tapped')),
              );
            }),
            _buildTile(Icons.help_outline, "Support Center", () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Support Center tapped')),
              );
            }),

            // Logout tile
            const SizedBox(height: 40),

            // TODO: Add confirmation dialog before logout (e.g. "Are you sure?")
            _buildTile(Icons.logout, "Log out", () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const RoleSelectionScreen()),
                (route) => false,
              );
            }),
          ],
        ),
      ),

      // Bottom navigation bar - interactive with highlight
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF6A48FF),
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            label: '',
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
