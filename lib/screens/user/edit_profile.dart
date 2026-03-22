import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserEditProfileScreen extends StatefulWidget {
  const UserEditProfileScreen({super.key});

  @override
  State<UserEditProfileScreen> createState() => _UserEditProfileScreenState();
}

class _UserEditProfileScreenState extends State<UserEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();

  File? _profileImage;
  String? _profileImageUrl;
  String? _selectedGender;
  DateTime? _selectedDob;

  bool _isLoading = true;
  bool _isUpdating = false;

  final ImagePicker _picker = ImagePicker();

  final Color primaryDarkBlue = const Color(0xFF120A4D);
  final Color accentDarkBlue = const Color(0xFF120A4D);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _firstNameController.text = data['firstName'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _profileImageUrl = data['profileImageUrl'];
          
          print("Loaded profileImageUrl from Firestore: $_profileImageUrl");

          if (data['dob'] != null) {
            final timestamp = data['dob'] as Timestamp;
            _selectedDob = timestamp.toDate();
            _dobController.text =
                "${_selectedDob!.day.toString().padLeft(2, '0')}/${_selectedDob!.month.toString().padLeft(2, '0')}/${_selectedDob!.year}";
          }
          _selectedGender = data['gender'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  // add profile image picker
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  // add date picker for birthday selection
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: accentDarkBlue,
              onPrimary: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: accentDarkBlue),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
        _dobController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  // update user profile in firestore
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first')),
      );
      return;
    }

    setState(() => _isUpdating = true);

    try {
      String? newProfileImageUrl = _profileImageUrl;

      if (_profileImage != null) {
        final fileName = 'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = FirebaseStorage.instance.ref().child('profile_images/$fileName');
        await ref.putFile(_profileImage!);
        newProfileImageUrl = await ref.getDownloadURL();

        print("New profile picture uploaded successfully. URL: $newProfileImageUrl");
      } else {
        print("No new image selected → keeping existing URL: $newProfileImageUrl");
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phone': _phoneController.text.trim().replaceAll(RegExp(r'[^0-9]'), ''),
        'dob': _selectedDob != null ? Timestamp.fromDate(_selectedDob!) : null,
        'gender': _selectedGender,
        if (newProfileImageUrl != null) 'profileImageUrl': newProfileImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim();
      if (fullName.isNotEmpty && fullName != user.displayName) {
        await user.updateDisplayName(fullName);
        await user.reload();
      }

      if (mounted) {
        setState(() {
          _profileImage = null;
          _profileImageUrl = newProfileImageUrl;
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryDarkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(color: primaryDarkBlue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Profile Picture
              GestureDetector(
                onTap: _showImagePickerOptions,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty
                              ? NetworkImage(_profileImageUrl!)
                              : const NetworkImage('https://via.placeholder.com/150') as ImageProvider),
                      onBackgroundImageError: (_, __) {
                        print("Failed to load profile image from URL: $_profileImageUrl");
                      },
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentDarkBlue,           // ← changed to dark blue
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

            ]
          ),
        ),
      ),
    );
  }  
}