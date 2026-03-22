// lib/screens/user/user_dashboard.dart

import 'package:flutter/material.dart';
import 'user_profile_screen.dart';
import 'service_request_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;

  final TextEditingController searchController = TextEditingController();

  void goToSearch() {
    String query = searchController.text.trim();

    if (query.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceRequestScreen(initialQuery: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          //  MERGED HEADER
          Container(
            padding: const EdgeInsets.only(
              top: 50,
              left: 20,
              right: 20,
              bottom: 30,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF1B1B4B),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Location",
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        Text(
                          "Bilzen, Tanjungbalai",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.error, color: Colors.red, size: 30),
                  ],
                ),

                const SizedBox(height: 20),

                //  YOUR SEARCH BAR (MERGED)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onSubmitted: (value) => goToSearch(),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Search Service",
                          hintStyle: const TextStyle(color: Colors.white54),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.white),
                          filled: true,
                          fillColor: Colors.white12,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: goToSearch,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A48FF),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Icons.search, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // BODY
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildOptionCard(
                  "Book a\nMechanic",
                  'assets/images/mechanic.jpg',
                ),
                const SizedBox(height: 15),
                _buildOptionCard(
                  "Book a\nGarage",
                  'assets/images/garage.jpg',
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
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserProfileScreen(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tapped nav item $index')),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined), label: ''),
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
}

Widget _buildOptionCard(String title, String imagePath) {
  return Container(
    height: 160,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25),
      image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
    ),
    padding: const EdgeInsets.all(25),
    alignment: Alignment.centerLeft,
    child: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
