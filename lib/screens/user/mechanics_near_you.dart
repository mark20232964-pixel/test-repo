import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'mechanic_details.dart';

class MechanicsNearYouScreen extends StatelessWidget {
  final Position currentPosition;

  const MechanicsNearYouScreen({super.key, required this.currentPosition});

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
        title: const Text("Mechanics Near You"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
            final loc = data["location"] as GeoPoint?;
            if (loc == null) return false;

            final dist = _distance(loc);
            return dist <= 50;
          }).toList();

          nearby.sort((a, b) {
            final locA =
                (a.data() as Map<String, dynamic>)["location"] as GeoPoint;
            final locB =
                (b.data() as Map<String, dynamic>)["location"] as GeoPoint;

            return _distance(locA).compareTo(_distance(locB));
          });

          if (nearby.isEmpty) {
            return const Center(child: Text("No nearby mechanics"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: nearby.length,
            itemBuilder: (context, index) {
              final doc = nearby[index];
              final data = doc.data() as Map<String, dynamic>;

              final GeoPoint loc = data["location"];
              final dist = _distance(loc);

              // 🔥 FIXED ID
              final String id = doc.id;

              final name = data["name"] ?? "Unnamed";
              final rating = (data["rating"] ?? 4.5).toDouble();
              final reviewsCount = data["reviewsCount"] ?? 0;
              final isVerified = data["isVerified"] ?? false;
              final joinedCount = data["joinedCount"] ?? 0;
              final photoUrl =
                  data["photoUrl"] ?? "https://via.placeholder.com/300x140";

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MechanicDetailsScreen(
                        providerId: id, // ✅ NOW SAFE
                        name: name,
                        mechanicLocation: LatLng(loc.latitude, loc.longitude),
                        rating: rating,
                        reviewsCount: reviewsCount,
                        description: data["description"] ??
                            "Professional mechanic service",
                        isVerified: isVerified,
                        joinedCount: joinedCount,
                        photoUrl: photoUrl,
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Container(
                        height: 140,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(photoUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        height: 140,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${dist.toStringAsFixed(1)} km away",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
