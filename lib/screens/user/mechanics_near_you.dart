import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'mechanic_details.dart'; // 👈 ADD THIS

class MechanicsNearYouScreen extends StatelessWidget {
  final Position currentPosition;

  const MechanicsNearYouScreen({super.key, required this.currentPosition});

  // 🔥 DISTANCE CALCULATION (ACCURATE)
  double _distance(GeoPoint loc) {
    return Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          loc.latitude,
          loc.longitude,
        ) /
        1000;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Mechanics"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("providers")
            .where("type", isEqualTo: "mechanic")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No mechanics found"));
          }

          final docs = snapshot.data!.docs;

          final nearby = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;

            if (data["location"] == null) return false;

            final GeoPoint loc = data["location"];
            final dist = _distance(loc);

            return dist <= 50;
          }).toList();

          nearby.sort((a, b) {
            final locA = (a.data() as Map<String, dynamic>)["location"];
            final locB = (b.data() as Map<String, dynamic>)["location"];

            final d1 = _distance(locA);
            final d2 = _distance(locB);

            return d1.compareTo(d2);
          });

          if (nearby.isEmpty) {
            return const Center(
              child: Text("No nearby mechanics found"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: nearby.length,
            itemBuilder: (context, i) {
              final data = nearby[i].data() as Map<String, dynamic>;

              final GeoPoint loc = data["location"];
              final dist = _distance(loc);

              return Card(
                color: const Color(0xFF161B22),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),

                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF6A48FF),
                    child: Icon(Icons.build, color: Colors.white),
                  ),

                  title: Text(
                    data["name"] ?? "Unnamed",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  subtitle: Text(
                    "${dist.toStringAsFixed(2)} km away",
                    style: const TextStyle(color: Colors.white70),
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white54,
                    size: 16,
                  ),

                  // 🔥🔥 THIS IS THE IMPORTANT PART YOU WERE MISSING
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MechanicDetailsScreen(
                          name: data["name"] ?? "Mechanic",
                          mechanicLocation: LatLng(loc.latitude, loc.longitude),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
