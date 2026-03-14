
import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
    String _userName = "Danel Fernando";
    String _userEmail = "danelfernando@gmail.com";

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
      const SizedBox(height: 20),

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

      // Name and email (placeholders for now)
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
    ],
  ),
),
    );
  }
}