// lib/screens/provider/provider_dashboard.dart

import 'package:flutter/material.dart';
import 'our_services_screen.dart';

class ProviderDashboard extends StatefulWidget {
  const ProviderDashboard({super.key});

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {
  int _selectedIndex = 0; // 0 = home selected by default
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header with location
          Container(
            padding:
                const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
            decoration: const BoxDecoration(
              color: Color(0xFF1B1B4B), // dark navy blue
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: const Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text(
                  "New Town, Ratnapura",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              ],
            ),
          ),

          // Temporary placeholder for the rest (menu cards will come next)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                _buildMenuCard("Ongoing\nRequest", 'assets/images/ongoing.jpg'),
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
                      "Our\nServices", 'assets/images/service.jpg'),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex, // ← this uses the state variable
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
              backgroundImage: NetworkImage(
                  'https://via.placeholder.com/150'), // temp avatar
            ),
            label: '',
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex =
                index; // this makes the selected icon highlight in black
          });
        },
      ),
    );
  }
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
        colorFilter:
            ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
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
