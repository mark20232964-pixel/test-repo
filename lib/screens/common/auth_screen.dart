// lib/screens/common/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../user/user_dashboard.dart';
import '../provider/provider_dashboard.dart';

class AuthScreen extends StatefulWidget {
  final String role;

  const AuthScreen({super.key, required this.role});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginMode = true;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _authenticate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential credential;

      if (_isLoginMode) {
        credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        if (_passwordController.text != _confirmPasswordController.text) {
          throw 'Passwords do not match';
        }

        credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await credential.user?.updateDisplayName(
          _nameController.text.trim(),
        );
      }

      final user = credential.user;

      if (user != null) {
        await user.reload();
        final currentUser = FirebaseAuth.instance.currentUser;

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : currentUser?.displayName ?? 'Unknown',
          'email': currentUser?.email ?? _emailController.text.trim(),
          'role': widget.role,
          'profilePicUrl': currentUser?.photoURL ?? '',
          'createdAt': _isLoginMode ? null : FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', widget.role);

      if (widget.role == 'provider') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ProviderDashboard()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const UserDashboard()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = "${e.message}";
      });
    } catch (e) {
      setState(() {
        _errorMessage = "$e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 🔥 CURVED HEADER WITH LOGO
          SizedBox(
            height: 260,
            width: double.infinity,
            child: Stack(
              children: [
                ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    height: 260,
                    color: const Color(0xFF1B1464),
                  ),
                ),

                // 🖼 LOGO (TOP RIGHT)
                Positioned(
                  top: 50,
                  right: 20,
                  child: Container(
                    width: 80, // 🔥 bigger
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.jpeg',
                        fit: BoxFit.cover, // 🔥 THIS removes white gaps
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      _isLoginMode ? "Sign in" : "Sign up",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 40,
                      height: 3,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 30),
                    if (!_isLoginMode)
                      _buildInput(_nameController, "Full Name"),
                    if (!_isLoginMode) const SizedBox(height: 20),
                    _buildInput(_emailController, "Email"),
                    const SizedBox(height: 20),
                    _buildInput(_passwordController, "Password",
                        isPassword: true),
                    if (!_isLoginMode) ...[
                      const SizedBox(height: 20),
                      _buildInput(
                          _confirmPasswordController, "Confirm Password",
                          isPassword: true),
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 20),
                      Text(_errorMessage!,
                          style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 30),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _authenticate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B1464),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                _isLoginMode ? "Login" : "Create Account",
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLoginMode = !_isLoginMode;
                            _errorMessage = null;
                          });
                        },
                        child: Text(
                          _isLoginMode
                              ? "Don't have an account? Sign up"
                              : "Already have an account? Login",
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label,
      {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black26),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1B1464)),
        ),
      ),
    );
  }
}

// 🌊 CUSTOM WAVE CLIPPER (THIS IS THE MAGIC)
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0, size.height - 60);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 40,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 80,
      size.width,
      size.height - 50,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
