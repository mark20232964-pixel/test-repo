
// UserProfileScreen - Displays user info, edit profile dialog, list options, logout
// Navigation: from dashboard avatar icon → here
// Features: editable name/email, list tiles, bottom nav with highlight

import 'package:flutter/material.dart';
import '../common/role_selection_screen.dart';
import 'verify_vehicle_screen.dart';

class UserProfileScreen extends StatefulWidget {  
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();  
}

class _UserProfileScreenState extends State<UserProfileScreen> {
    String _userName = "Danel Fernando";
    String _userEmail = "danelfernando@gmail.com";

    int _selectedIndex = 3;

    void _showEditProfileDialog() {
  final nameController = TextEditingController(text: _userName);
  final emailController = TextEditingController(text: _userEmail);

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
              _userName = nameController.text.trim().isNotEmpty
                  ? nameController.text
                  : _userName;
              _userEmail = emailController.text.trim().isNotEmpty
                  ? emailController.text
                  : _userEmail;
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
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
              radius: 50,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Change photo coming soon")),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    size: 18,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 15),

      // Name and email 
      Text(
  _userName,
  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      Text(
  _userEmail,
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

// List tiles
_buildTile(Icons.history, "History", () {
  // TODO: Navigate to history screen later
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('History tapped')),
  );
}),
_buildTile(Icons.notifications_outlined, "Verify vehicle", () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const VerifyVehicleScreen()),
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
const SizedBox(height: 20),

// TODO: Add confirmation dialog before logout
_buildTile(Icons.logout, "Log out", () {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
    (route) => false, 
  );
}),
    ],
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
}

Widget _buildTile(IconData icon, String title, VoidCallback onTap) {
  return ListTile(
    leading: Icon(icon, color: Colors.black),
    title: Text(title, style: const TextStyle(color: Colors.black)),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
    onTap: onTap,
  );
}