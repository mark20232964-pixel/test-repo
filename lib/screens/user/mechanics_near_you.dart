// lib/screens/user/mechanics_near_you.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // ← THIS WAS MISSING
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
            return const Center(child: Text("No mechanics found nearby"));
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
                (a.data() as Map<String, dynamic>)["location"] as GeoPoint?;
            final locB =
                (b.data() as Map<String, dynamic>)["location"] as GeoPoint?;
            if (locA == null || locB == null) return 0;
            final d1 = _distance(locA);
            final d2 = _distance(locB);
            return d1.compareTo(d2);
          });

          if (nearby.isEmpty) {
            return const Center(child: Text("No mechanics within 50km"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: nearby.length,
            itemBuilder: (context, index) {
              final data = nearby[index].data() as Map<String, dynamic>;
              final loc = data["location"] as GeoPoint;
              final dist = _distance(loc);

              final id = data["ownerUid"];
              final name = data["name"] as String? ?? "Unnamed Mechanic";
              final rating = (data["rating"] as num?)?.toDouble() ?? 4.5;
              final reviewsCount = data["reviewsCount"] as int? ?? 230;
              final isVerified = data["isVerified"] as bool? ?? true;
              final joinedCount = data["joinedCount"] as int? ?? 24;
              final photoUrl = data["photoUrl"] as String? ??
                  'https://via.placeholder.com/300x140';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MechanicDetailsScreen(
                        providerId: id,
                        name: name,
                        mechanicLocation: LatLng(loc.latitude, loc.longitude),
                        rating: rating,
                        reviewsCount: reviewsCount,
                        description: data["description"] as String? ??
                            "Expert on-site vehicle assistance, specializing in diagnosing breakdown issues and performing quick repairs.",
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
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  "${rating.toStringAsFixed(1)} ($reviewsCount)",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(width: 12),
                                if (isVerified)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      "Verified",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${dist.toStringAsFixed(1)} km away • $joinedCount Person Joined",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14),
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
