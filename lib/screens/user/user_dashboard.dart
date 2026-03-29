// lib/screens/user/user_dashboard.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'user_profile_screen.dart';
import 'service_request_screen.dart';
import 'mechanics_near_you.dart';
import '../user/garage_near_you.dart'; //
import '../user/sos_services.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;
  final TextEditingController searchController = TextEditingController();

  bool _isGettingLocation = false;
  String userLocation = "Getting location...";

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  // 🔥 FETCH USER LOCATION NAME
  Future<void> _loadUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => userLocation = "Location disabled");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => userLocation = "Permission denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => userLocation = "Permission blocked");
        return;
      }

      Position position = await Geolocator.getCurrentPosition();

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks.first;

      setState(() {
        userLocation = "${place.locality ?? ''}, ${place.country ?? ''}";
      });
    } catch (e) {
      setState(() => userLocation = "Location error");
    }
  }

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

  // 🔥 MECHANICS
  Future<void> _getLocationAndOpenMechanics() async {
    setState(() => _isGettingLocation = true);

    try {
      Position position = await Geolocator.getCurrentPosition();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MechanicsNearYouScreen(currentPosition: position),
        ),
      );
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  // 🔥 GARAGES
  Future<void> _getLocationAndOpenGarages() async {
    setState(() => _isGettingLocation = true);

    try {
      Position position = await Geolocator.getCurrentPosition();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GaragesNearYouScreen(currentPosition: position),
        ),
      );
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // 🔥 HEADER
          Container(
            padding:
                const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 25),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2C2A6A), Color(0xFF4A3FA7)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Location",
                            style:
                                TextStyle(color: Colors.white60, fontSize: 12)),
                        Text(userLocation,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    // adding sos button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SosScreen(),
                          ),
                        );
                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 12,
                        child: Icon(Icons.notifications,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: searchController,
                          onSubmitted: (_) => goToSearch(),
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Search Service",
                            hintStyle: TextStyle(color: Colors.white60),
                            prefixIcon: Icon(Icons.search, color: Colors.white),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: goToSearch,
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.tune, color: Colors.white),
                      ),
                    )
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
                _buildCard(
                  "Book a\nMechanic",
                  "assets/images/mechanic.jpg",
                  onTap:
                      _isGettingLocation ? null : _getLocationAndOpenMechanics,
                ),
                const SizedBox(height: 20),
                _buildCard(
                  "Book a\nGarage",
                  "assets/images/garage.jpg",
                  onTap: _isGettingLocation ? null : _getLocationAndOpenGarages,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF6A48FF),
        unselectedItemColor: Colors.black87,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // Only Profile needs navigation (index 3)
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserProfileScreen(),
              ),
            );
          }
          // Home (index 0), Favorite (1), Bag (2) will just change the tab
          // (we will handle content switching in the next step)
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ""),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined), label: ""),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 12,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            label: "",
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String image, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black.withOpacity(0.35),
          ),
          padding: const EdgeInsets.all(20),
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
