// lib/screens/provider/profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
import '../common/role_selection_screen.dart'; // for logout (adjust path if needed)

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? profileImageUrl;
  List<String> verificationDocs = [];
  String? _userName;
  String? _userEmail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('providers')
          .doc('test-provider-1') // ← your test document ID
          .get();

      if (doc.exists) {
        setState(() {
          _userName = doc['name'] ?? "Name not set";
          _userEmail = doc['email'] ?? "Email not set";
          profileImageUrl = doc['profileImageUrl'];
          verificationDocs = List<String>.from(doc['verificationDocs'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _userName = "No profile data found";
          _userEmail = "Add data in Firestore";
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Firestore load error: $e');
      setState(() {
        _userName = "Error loading data";
        _userEmail = e.toString();
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

  // Upload Verification Documents
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

  // Logout (placeholder - update when auth is ready)
  void _logout() {
    // FirebaseAuth.instance.signOut(); // Uncomment when auth is added
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1B4B),
        elevation: 0,
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6A48FF)),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Profile Picture
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: profileImageUrl != null
                              ? NetworkImage(profileImageUrl!)
                              : const AssetImage(
                                  'assets/images/default_profile.jpg',
                                ) as ImageProvider,
                          backgroundColor: Colors.grey[800],
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _uploadProfilePicture,
                            child: Container(
                              padding: const EdgeInsets.all(8),
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

                  // Name & Email from Firestore
                  Text(
                    _userName ?? "Name not set",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userEmail ?? "Email not set",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),

                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {}, // Add edit logic later
                    child: const Text(
                      "Edit profile",
                      style: TextStyle(color: Color(0xFF6A48FF)),
                    ),
                  ),

                  const Divider(height: 40, color: Colors.white24),

                  // General Section
                  _buildSection("General", [
                    _buildTile(Icons.history, "History"),
                    _buildTile(Icons.notifications, "Notification"),
                    _buildTile(
                      Icons.description,
                      "Verify Docs",
                      onTap: _uploadVerificationDoc,
                    ),
                  ]),

                  const Divider(height: 40, color: Colors.white24),

                  // Support Section
                  _buildSection("Support", [
                    _buildTile(Icons.settings, "Settings"),
                    _buildTile(Icons.language, "Languages"),
                    _buildTile(Icons.privacy_tip, "Privacy Policy"),
                    _buildTile(Icons.support_agent, "Support Center"),
                    _buildTile(
                      Icons.logout,
                      "Log out",
                      onTap: _logout,
                      color: Colors.redAccent,
                    ),
                  ]),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, List<Widget> tiles) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...tiles,
        ],
      ),
    );
  }

  Widget _buildTile(
    IconData icon,
    String title, {
    VoidCallback? onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF6A48FF)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.white70,
      ),
      onTap: onTap,
    );
  }
}
