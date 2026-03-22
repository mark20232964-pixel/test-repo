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
}