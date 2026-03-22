// lib/screens/provider/provider_dashboard.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'our_services_screen.dart';
import 'add_service_type.dart';
import 'provider_profile_screen.dart';
import 'provider_ongoing.dart';

class ProviderDashboard extends StatefulWidget {
  const ProviderDashboard({super.key});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {
  int _selectedIndex = 0;
  String? _activePopupRequestId;

  @override
  void initState() {
    super.initState();
    listenForRequests();
  }

  // 🔥 REAL-TIME REQUEST LISTENER
  void listenForRequests() {
    FirebaseFirestore.instance
        .collection('requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isEmpty) return;

      final doc = snapshot.docs.first;

      if (_activePopupRequestId == doc.id) return;

      _activePopupRequestId = doc.id;

      showEmergencyPopup(doc);
    });
  }

  // 🚨 POPUP
  void showEmergencyPopup(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "🚨 Emergency Request",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              Text(data['userName'] ?? "User"),
              const SizedBox(height: 5),
              Text(
                data['issue'] ?? "",
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await declineRequest(doc.id);
                        Navigator.pop(context);
                      },
                      child: const Text("Decline"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await acceptRequest(doc.id);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: const Text("Accept"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ ACCEPT
  Future<void> acceptRequest(String requestId) async {
    final providerId = FirebaseAuth.instance.currentUser?.uid ?? "provider";

    await FirebaseFirestore.instance
        .collection('requests')
        .doc(requestId)
        .update({'status': 'accepted', 'providerId': providerId});

    _activePopupRequestId = null;
  }

  // ❌ DECLINE
  Future<void> declineRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('requests')
        .doc(requestId)
        .update({'status': 'declined'});

    _activePopupRequestId = null;
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader("New Town, Ratnapura"),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                // 🔥 YOUR FEATURE (kept)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProviderOngoingScreen(),
                      ),
                    );
                  },
                  child: _buildMenuCard(
                    "Ongoing\nRequest",
                    'assets/images/ongoing.jpg',
                  ),
                ),

                const SizedBox(height: 15),

                _buildMenuCard("Calendar", 'assets/images/calendar.jpg'),

                const SizedBox(height: 15),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OurServicesScreen(),
                      ),
                    );
                  },
                  child: _buildMenuCard(
                    "Our\nServices",
                    'assets/images/service.jpg',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // 🔥 MERGED NAVIGATION
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddServiceTypeScreen(),
              ),
            );
            return;
          }

          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
            return;
          }

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
              radius: 12,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String location) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1B1B4B),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            location,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildMenuCard(String title, String imagePath) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.grey[300],
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.3),
            BlendMode.darken,
          ),
        ),
      ),
      padding: const EdgeInsets.all(25),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
