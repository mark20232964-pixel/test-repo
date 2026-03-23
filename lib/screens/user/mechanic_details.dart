// lib/screens/user/mechanic_details.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:roadresq/screens/user/schedule_mechanic.dart';
import 'package:url_launcher/url_launcher.dart';

class MechanicDetailsScreen extends StatefulWidget {
  final String providerId;
  final String name;
  final LatLng mechanicLocation;
  final double rating;
  final int reviewsCount;
  final String description;
  final bool isVerified;
  final int joinedCount;
  final String photoUrl;

  const MechanicDetailsScreen({
    super.key,
    required this.providerId,
    required this.name,
    required this.mechanicLocation,
    required this.rating,
    required this.reviewsCount,
    required this.description,
    required this.isVerified,
    required this.joinedCount,
    required this.photoUrl,
  });

  @override
  State<MechanicDetailsScreen> createState() => _MechanicDetailsScreenState();
}

class _MechanicDetailsScreenState extends State<MechanicDetailsScreen> {
  LatLng? userLocation;
  List<LatLng> polylineCoordinates = [];
  GoogleMapController? _mapController;

  final String apiKey = "AIzaSyDC-Vg3GG5uDyDb5JuIzPKeKEIeUXwoXho";

  @override
  void initState() {
    super.initState();
    _loadEverything();
  }

  Future<void> _loadEverything() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      userLocation = LatLng(pos.latitude, pos.longitude);
    } catch (e) {
      // Fallback if location fails
    }

    await _getRoute();
    setState(() {});
  }

  Future<void> _getRoute() async {
    if (userLocation == null) return;

    PolylinePoints polylinePoints = PolylinePoints();

    PolylineRequest request = PolylineRequest(
      origin: PointLatLng(userLocation!.latitude, userLocation!.longitude),
      destination: PointLatLng(
        widget.mechanicLocation.latitude,
        widget.mechanicLocation.longitude,
      ),
      mode: TravelMode.driving,
    );

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: request,
      googleApiKey: apiKey,
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates =
          result.points.map((e) => LatLng(e.latitude, e.longitude)).toList();
      _fitMapToRoute();
    }
  }

  void _fitMapToRoute() {
    if (_mapController == null || userLocation == null) return;

    // Manual southwest/northeast calculation
    double south = userLocation!.latitude < widget.mechanicLocation.latitude
        ? userLocation!.latitude
        : widget.mechanicLocation.latitude;
    double west = userLocation!.longitude < widget.mechanicLocation.longitude
        ? userLocation!.longitude
        : widget.mechanicLocation.longitude;
    double north = userLocation!.latitude > widget.mechanicLocation.latitude
        ? userLocation!.latitude
        : widget.mechanicLocation.latitude;
    double east = userLocation!.longitude > widget.mechanicLocation.longitude
        ? userLocation!.longitude
        : widget.mechanicLocation.longitude;

    final bounds = LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }

  Future<void> _openDirections() async {
    final url =
        "https://www.google.com/maps/dir/?api=1&destination=${widget.mechanicLocation.latitude},${widget.mechanicLocation.longitude}&travelmode=driving";

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: userLocation ?? widget.mechanicLocation,
              zoom: 14,
            ),
            onMapCreated: (c) => _mapController = c,
            markers: {
              if (userLocation != null)
                Marker(
                  markerId: const MarkerId("user"),
                  position: userLocation!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
                ),
              Marker(
                markerId: const MarkerId("mechanic"),
                position: widget.mechanicLocation,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed),
              ),
            },
            polylines: {
              Polyline(
                polylineId: const PolylineId("route"),
                points: polylineCoordinates,
                width: 5,
                color: Colors.blue,
              )
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_border,
                            color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          widget.photoUrl,
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Colors.grey[800],
                            child: const Icon(Icons.person,
                                size: 100, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.name,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          if (widget.isVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
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
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            "${widget.rating.toStringAsFixed(1)} (${widget.reviewsCount})",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.description,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {},
                        child: const Text("Read More",
                            style: TextStyle(color: Color(0xFF6A48FF))),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _openDirections,
                              icon: const Icon(Icons.directions_car),
                              label: const Text("Directions"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black87,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Map<String, dynamic> schedule = {
                                  'providerId': widget.providerId,
                                  'name': widget.name,
                                  'location': GeoPoint(widget.mechanicLocation.latitude, widget.mechanicLocation.longitude),
                                  'rating': widget.rating,
                                  'reviewsCount': widget.reviewsCount,
                                  'description': widget.description,
                                  'isVerified': widget.isVerified,
                                  'joinedCount': widget.joinedCount,
                                  'photoUrl': widget.photoUrl,
                                  'userLocation': GeoPoint(userLocation!.latitude, userLocation!.longitude)
                                };

                                Navigator.push(context,
                                MaterialPageRoute(builder: (context)=>ScheduleMechanicScreen(schedule: schedule)));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6A48FF),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text(
                                "Book Now",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
