// lib/screens/provider/provider_profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
import '../common/role_selection_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Firebase data
  String? profileImageUrl;
  List<String> verificationDocs = [];
  String? _providerName;
  String? _providerEmail;
  bool _isLoading = true;

  // Bottom nav selected index
  int _selectedIndex = 3; // profile tab

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Load data from Firestore
  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('providers')
          .doc('test-provider-1')
          .get();

      if (doc.exists) {
        setState(() {
          _providerName = doc['name'] ?? "Name not set";
          _providerEmail = doc['email'] ?? "Email not set";
          profileImageUrl = doc['profileImageUrl'];
          verificationDocs = List<String>.from(doc['verificationDocs'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _providerName = "No profile data found";
          _providerEmail = "Add data in Firestore";
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Firestore load error: $e');
      setState(() {
        _providerName = "Error loading data";
        _providerEmail = e.toString();
        _isLoading = false;
      });
    }
  }

  // Upload Profile Picture
  Future<void> _uploadProfilePicture() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final fileName = path.basename(image.path);
    final ref = FirebaseStorage.instance.ref().child(
          'provider_profiles/test-provider-1/$fileName',
        );

    await ref.putFile(File(image.path));
    final downloadUrl = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('providers')
        .doc('test-provider-1')
        .set({'profileImageUrl': downloadUrl}, SetOptions(merge: true));

    setState(() => profileImageUrl = downloadUrl);
  }

  // Upload Verification Document
  Future<void> _uploadVerificationDoc() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return;

    final fileName = path.basename(file.path);
    final ref = FirebaseStorage.instance.ref().child(
          'provider_docs/test-provider-1/$fileName',
        );

    await ref.putFile(File(file.path));
    final downloadUrl = await ref.getDownloadURL();

    verificationDocs.add(downloadUrl);

    await FirebaseFirestore.instance
        .collection('providers')
        .doc('test-provider-1')
        .update({'verificationDocs': verificationDocs});

    setState(() {});
  }

  // Edit Profile Dialog
  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _providerName ?? '');
    final emailController = TextEditingController(text: _providerEmail ?? '');

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

  // Logout
  void _logout() {
    // TODO: Add real Firebase sign out later
    // await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      (route) => false,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: profileImageUrl != null
                              ? NetworkImage(profileImageUrl!)
                              : const NetworkImage(
                                  'https://via.placeholder.com/150'),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _uploadProfilePicture,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF6A48FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _providerName ?? "Name not set",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _providerEmail ?? "Email not set",
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
                  _buildTile(Icons.history, "History", () {}),
                  _buildTile(Icons.notifications_outlined, "Verify doc",
                      _uploadVerificationDoc),
                  _buildTile(Icons.settings_outlined, "Settings", () {}),
                  _buildTile(Icons.language, "Languages", () {}),
                  _buildTile(
                      Icons.privacy_tip_outlined, "Privacy Policy", () {}),
                  _buildTile(Icons.help_outline, "Support Center", () {}),
                  const SizedBox(height: 40),
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
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: ''),
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

  Widget _buildTile(IconData icon, String title, [VoidCallback? onTap]) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(color: Colors.black)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
      onTap: onTap,
    );
  }
}
