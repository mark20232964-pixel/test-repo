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

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('Select from Gallery'),
              tileColor: accentDarkBlue,
              textColor: Colors.white,
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('Take Photo'),
              tileColor: accentDarkBlue,
              textColor: Colors.white,
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
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

              // First Name
              TextFormField(
                controller: _firstNameController,
                style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'First Name',
                  labelStyle: const TextStyle(color: Colors.black54),
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.person, color: accentDarkBlue),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
              ),

              const SizedBox(height: 20),

              // Last Name
              TextFormField(
                controller: _lastNameController,
                style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  labelStyle: const TextStyle(color: Colors.black54),
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.person_outline, color: accentDarkBlue),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
              ),

              const SizedBox(height: 20),

              // Phone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  labelStyle: const TextStyle(color: Colors.black54),
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.phone, color: accentDarkBlue),
                  prefixText: '+94 ', 
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final cleaned = v.trim().replaceAll(RegExp(r'[^0-9]'), '');
                  if (cleaned.length != 9) return 'Enter valid 9-digit number';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Birthday
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dobController,
                    style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Birthday (Optional)',
                      labelStyle: const TextStyle(color: Colors.black54),
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.cake, color: accentDarkBlue),
                      hintText: 'DD/MM/YYYY',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: Icon(Icons.calendar_today, color: accentDarkBlue),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Gender
              DropdownButtonFormField<String>(
                value: _selectedGender,
                style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Gender (Optional)',
                  labelStyle: const TextStyle(color: Colors.black54),
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.wc, color: accentDarkBlue),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                  DropdownMenuItem(value: null, child: Text('Prefer not to say')),
                ],
                onChanged: (v) => setState(() => _selectedGender = v),
              ),

              const SizedBox(height: 48),

              // Update Button – now dark blue
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isUpdating ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentDarkBlue,          // ← changed to dark blue
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: _isUpdating
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Update Profile',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }  

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }
}