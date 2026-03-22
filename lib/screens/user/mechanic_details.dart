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

  final String apiKey = "YOUR_API_KEY_HERE";

  @override
  void initState() {
    super.initState();
    _loadEverything();
  }

  // 🚀 LOAD WITHOUT BLOCKING UI
  Future<void> _loadEverything() async {
    // STEP 1: Get location FIRST
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    userLocation = LatLng(pos.latitude, pos.longitude);

    setState(() {}); // 🔥 SHOW MAP IMMEDIATELY

    // STEP 2: Load route AFTER UI shows
    await _getRoute();

    setState(() {}); // 🔥 UPDATE ROUTE
  }

  // 🛣️ ROUTE
  Future<void> _getRoute() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineRequest request = PolylineRequest(
      origin: PointLatLng(
        userLocation!.latitude,
        userLocation!.longitude,
      ),
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

      // 🔥 MOVE CAMERA TO FIT ROUTE
      _fitMapToRoute();
    }
  }

  // 🔥 AUTO ZOOM TO SHOW BOTH USER + MECHANIC
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

  // 🚗 OPEN GOOGLE MAPS
  Future<void> _openGoogleMaps() async {
    final url =
        "https://www.google.com/maps/dir/?api=1&destination=${widget.mechanicLocation.latitude},${widget.mechanicLocation.longitude}&travelmode=driving";

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: Stack(
        children: [
          // 🔥 MAP ALWAYS SHOWS (NO WAIT)
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
                ),
              Marker(
                markerId: const MarkerId("mechanic"),
                position: widget.mechanicLocation,
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

          // 🔥 LOADING (only small overlay now)
          if (userLocation == null)
            const Center(child: CircularProgressIndicator()),

          // 🔘 BUTTONS
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _openGoogleMaps,
                  child: const Text("🚗 Start Navigation"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
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
