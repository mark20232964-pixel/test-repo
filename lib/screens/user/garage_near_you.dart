import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'garage_details.dart';

class GaragesNearYouScreen extends StatelessWidget {
  final Position currentPosition;

  const GaragesNearYouScreen({super.key, required this.currentPosition});

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
        title: const Text("Garages Near You"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("garages").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          final nearby = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final loc = data["location"] as GeoPoint?;
            if (loc == null) return false;

            return _distance(loc) <= 50;
          }).toList();

          nearby.sort((a, b) {
            final locA =
                (a.data() as Map<String, dynamic>)["location"] as GeoPoint;
            final locB =
                (b.data() as Map<String, dynamic>)["location"] as GeoPoint;

            return _distance(locA).compareTo(_distance(locB));
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: nearby.length,
            itemBuilder: (context, index) {
              final doc = nearby[index];
              final data = doc.data() as Map<String, dynamic>;
              final GeoPoint loc = data["location"];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GarageDetailsScreen(
                        garageId: doc.id,
                        name: data["name"],
                        location: LatLng(loc.latitude, loc.longitude),
                        description: data["description"] ?? "",
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    title: Text(data["name"]),
                    subtitle:
                        Text("${_distance(loc).toStringAsFixed(1)} km away"),
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