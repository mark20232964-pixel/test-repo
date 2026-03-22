// lib/screens/user/mechanic_details.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';

class MechanicDetailsScreen extends StatefulWidget {
  final String name;
  final LatLng mechanicLocation;

  const MechanicDetailsScreen({
    super.key,
    required this.name,
    required this.mechanicLocation,
  });

  @override
  State<MechanicDetailsScreen> createState() => _MechanicDetailsScreenState();
}

class _MechanicDetailsScreenState extends State<MechanicDetailsScreen> {
  LatLng? userLocation;
  List<LatLng> polylineCoordinates = [];
  GoogleMapController? _mapController;

  final String apiKey =
      "YOUR_ACTUAL_GOOGLE_API_KEY_HERE"; // ← Replace with your real key

  @override
  void initState() {
    super.initState();
    _loadEverything();
  }

  // Load location & route without blocking UI
  Future<void> _loadEverything() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      userLocation = LatLng(pos.latitude, pos.longitude);
    } catch (e) {
      // Fallback to mechanic location if user location fails
    }

    await _getRoute();
    setState(() {});
  }

  // Get driving route polyline
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

  // Auto zoom to show both user and mechanic
  void _fitMapToRoute() {
    if (_mapController == null || userLocation == null) return;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        userLocation!.latitude < widget.mechanicLocation.latitude
            ? userLocation!.latitude
            : widget.mechanicLocation.latitude,
        userLocation!.longitude < widget.mechanicLocation.longitude
            ? userLocation!.longitude
            : widget.mechanicLocation.longitude,
      ),
      northeast: LatLng(
        userLocation!.latitude > widget.mechanicLocation.latitude
            ? userLocation!.latitude
            : widget.mechanicLocation.latitude,
        userLocation!.longitude > widget.mechanicLocation.longitude
            ? userLocation!.longitude
            : widget.mechanicLocation.longitude,
      ),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }

  // Open Google Maps app for navigation
  Future<void> _openGoogleMaps() async {
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
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: const Color(0xFF120A4D),
        foregroundColor: Colors.white,
      ),
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
            myLocationButtonEnabled: true,
          ),

          // Loading overlay
          if (userLocation == null)
            const Center(child: CircularProgressIndicator()),

          // Bottom buttons
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _openGoogleMaps,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF120A4D),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("🚗 Start Navigation"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Back"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
