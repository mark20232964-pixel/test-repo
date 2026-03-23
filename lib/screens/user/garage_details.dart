import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:roadresq/screens/user/schedule_mechanic.dart';
import 'package:url_launcher/url_launcher.dart';

class GarageDetailsScreen extends StatefulWidget {
  final String garageId;
  final String name;
  final LatLng location;
  final String description;

  const GarageDetailsScreen({
    super.key,
    required this.garageId,
    required this.name,
    required this.location,
    required this.description,
  });

  @override
  State<GarageDetailsScreen> createState() => _GarageDetailsScreenState();
}

class _GarageDetailsScreenState extends State<GarageDetailsScreen> {
  LatLng? userLocation;
  List<LatLng> polylineCoordinates = [];
  GoogleMapController? _mapController;

  final String apiKey = "YOUR_API_KEY"; // 🔥 PUT YOUR REAL API KEY

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
      print("Location error: $e");
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
        widget.location.latitude,
        widget.location.longitude,
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

    double south = userLocation!.latitude < widget.location.latitude
        ? userLocation!.latitude
        : widget.location.latitude;

    double west = userLocation!.longitude < widget.location.longitude
        ? userLocation!.longitude
        : widget.location.longitude;

    double north = userLocation!.latitude > widget.location.latitude
        ? userLocation!.latitude
        : widget.location.latitude;

    double east = userLocation!.longitude > widget.location.longitude
        ? userLocation!.longitude
        : widget.location.longitude;

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
        "https://www.google.com/maps/dir/?api=1&destination=${widget.location.latitude},${widget.location.longitude}&travelmode=driving";

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps')),
      );
    }
  }

  void _bookNow() {
    Map<String, dynamic> schedule = {
      'providerId': widget.garageId,
      'name': widget.name,
      'location': GeoPoint(widget.location.latitude, widget.location.longitude),
      'description': widget.description,
      'userLocation': GeoPoint(userLocation!.latitude, userLocation!.longitude)
    };

    Navigator.push(context,
        MaterialPageRoute(builder: (context)=>ScheduleMechanicScreen(schedule: schedule)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: userLocation ?? widget.location,
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
                markerId: const MarkerId("garage"),
                position: widget.location,
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
          Container(color: Colors.black.withOpacity(0.4)),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),

                      Text(widget.description),
                      const SizedBox(height: 20),

                      // 🔥 BUTTONS LIKE MECHANIC SCREEN
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
                              onPressed: _bookNow,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6A48FF),
                                padding:
                                const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text(
                                "Book Now",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}