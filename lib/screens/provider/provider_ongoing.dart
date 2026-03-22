import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'provider_request_details.dart';

class ProviderOngoingScreen extends StatefulWidget {
  const ProviderOngoingScreen({super.key});

  @override
  State<ProviderOngoingScreen> createState() => _ProviderOngoingScreenState();
}

class _ProviderOngoingScreenState extends State<ProviderOngoingScreen> {
  final String providerId =
      FirebaseAuth.instance.currentUser?.uid ?? "provider";

  Position? _providerLocation;

  final int timeoutMinutes = 30;

  StreamSubscription<Position>? _positionStream;

  Future<void> getProviderLocation() async {
    _providerLocation = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getProviderLocation();
  }

  void startLiveTracking(String requestId) {
    _positionStream?.cancel();

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) async {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({
        'providerLocation': GeoPoint(
          position.latitude,
          position.longitude,
        ),
      });
    });
  }

  void stopTracking() {
    _positionStream?.cancel();
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }

  double calculateDistance(GeoPoint userLocation) {
    if (_providerLocation == null) return 0;

    double meters = Geolocator.distanceBetween(
      _providerLocation!.latitude,
      _providerLocation!.longitude,
      userLocation.latitude,
      userLocation.longitude,
    );

    return meters / 1000;
  }

  bool isExpired(Timestamp? timestamp) {
    if (timestamp == null) return false;

    final requestTime = timestamp.toDate();
    final now = DateTime.now();

    return now.difference(requestTime).inMinutes > timeoutMinutes;
  }

  Future<void> deleteIfExpired(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    if (isExpired(data['timestamp'])) {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(doc.id)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ongoing Requests"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('providerId', isEqualTo: providerId)
            .where('status', isEqualTo: 'accepted')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(child: Text("No ongoing requests"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final data = doc.data() as Map<String, dynamic>;

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(data['userName'] ?? "User"),
              );
            },
          );
        },
      ),
    );
  }
}
