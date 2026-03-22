import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class ServiceRequestScreen extends StatefulWidget {
  final String initialQuery;

  const ServiceRequestScreen({super.key, required this.initialQuery});

  @override
  State<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  GoogleMapController? _mapController;
  Position? _userLocation;
  LatLng? _providerLocation;

  String? _providerName;
  String _eta = "";

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  bool _requestAccepted = false;
  bool _isSearching = false;

  String? _currentRequestId;
  StreamSubscription? _requestListener;
  Timer? _timeoutTimer;

  final polylinePoints = PolylinePoints();

  late AnimationController _animationController;
  late Animation<double> _animation;

  final String googleApiKey = "AIzaSyDC-Vg3GG5uDyDb5JuIzPKeKEIeUXwoXho";
  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    _getUserLocation();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _requestListener?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  // 📍 GET USER LOCATION
  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) return;

    _userLocation = await Geolocator.getCurrentPosition();

    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('user'),
        position: LatLng(_userLocation!.latitude, _userLocation!.longitude),
      ),
    );

    setState(() {});
  }

  // 🧠 ETA CALCULATION
  void calculateETA() {
    if (_userLocation == null || _providerLocation == null) return;

    double meters = Geolocator.distanceBetween(
      _providerLocation!.latitude,
      _providerLocation!.longitude,
      _userLocation!.latitude,
      _userLocation!.longitude,
    );

    double km = meters / 1000;

    double speed = 40; // km/h

    double hours = km / speed;
    int minutes = (hours * 60).round();

    setState(() {
      _eta = "$minutes min";
    });
  }

  // 🗺 DRAW ROUTE
  Future<void> _drawRoute() async {
    if (_userLocation == null || _providerLocation == null) return;

    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleApiKey,
      request: PolylineRequest(
        origin: PointLatLng(_userLocation!.latitude, _userLocation!.longitude),
        destination: PointLatLng(
          _providerLocation!.latitude,
          _providerLocation!.longitude,
        ),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      final points =
          result.points.map((e) => LatLng(e.latitude, e.longitude)).toList();

      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: const PolylineId("route"),
          color: const Color(0xFFB388FF),
          width: 6,
          points: points,
        ),
      );

      setState(() {});
    }
  }

  // 🔥 LIVE PROVIDER TRACKING
  void listenToProviderLocation(String requestId) {
    FirebaseFirestore.instance
        .collection('requests')
        .doc(requestId)
        .snapshots()
        .listen((doc) async {
      final data = doc.data();
      if (data == null) return;

      if (data['providerLocation'] != null) {
        GeoPoint loc = data['providerLocation'];

        LatLng newPos = LatLng(loc.latitude, loc.longitude);

        setState(() {
          _providerLocation = newPos;

          _markers.removeWhere((m) => m.markerId.value == 'provider');

          _markers.add(
            Marker(markerId: const MarkerId('provider'), position: newPos),
          );
        });

        await _drawRoute();
        calculateETA();
      }
    });
  }

  // 🔥 LISTEN REQUEST
  void listenToRequest(String requestId) {
    _requestListener = FirebaseFirestore.instance
        .collection('requests')
        .doc(requestId)
        .snapshots()
        .listen((doc) async {
      final data = doc.data();
      if (data == null) return;

      if (data['status'] == 'accepted') {
        _timeoutTimer?.cancel();

        final providerId = data['providerId'];
        if (providerId == null) return;

        await fetchProviderDetails(providerId);

        listenToProviderLocation(requestId);

        setState(() {
          _requestAccepted = true;
          _isSearching = false;
        });
      }
    });
  }

  // 🔧 FETCH PROVIDER
  Future<void> fetchProviderDetails(String providerId) async {
    final doc = await FirebaseFirestore.instance
        .collection('providers')
        .doc(providerId)
        .get();

    final data = doc.data();
    if (data == null) return;

    GeoPoint loc = data['location'];

    _providerLocation = LatLng(loc.latitude, loc.longitude);
    _providerName = data['name'];

    _markers.add(
      Marker(
        markerId: const MarkerId('provider'),
        position: _providerLocation!,
      ),
    );

    await _drawRoute();
    calculateETA();
  }

  // 🔍 SEARCH
  Future<void> _searchService(String query) async {
    if (_userLocation == null) return;

    setState(() {
      _isSearching = true;
      _requestAccepted = false;
    });

    final user = FirebaseAuth.instance.currentUser;

    final docRef = await FirebaseFirestore.instance.collection('requests').add({
      'userId': user?.uid ?? "guest",
      'userName': user?.displayName ?? "Guest User",
      'providerId': null,
      'issue': query,
      'location': GeoPoint(_userLocation!.latitude, _userLocation!.longitude),
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    _currentRequestId = docRef.id;

    listenToRequest(docRef.id);

    _timeoutTimer = Timer(const Duration(seconds: 30), () async {
      if (!_requestAccepted && _currentRequestId != null) {
        await FirebaseFirestore.instance
            .collection('requests')
            .doc(_currentRequestId)
            .update({'status': 'timeout'});

        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  // ❌ CANCEL
  Future<void> cancelRequest() async {
    if (_currentRequestId == null) return;

    await FirebaseFirestore.instance
        .collection('requests')
        .doc(_currentRequestId)
        .update({'status': 'cancelled'});

    _requestListener?.cancel();
    _timeoutTimer?.cancel();

    setState(() {
      _isSearching = false;
      _requestAccepted = false;
    });
  }
}

// 🎨 UI
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.only(
                top: 50,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF1B1B4B),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Search service",
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white12,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      _searchService(_searchController.text);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _userLocation != null
                      ? LatLng(
                          _userLocation!.latitude,
                          _userLocation!.longitude,
                        )
                      : const LatLng(6.9271, 79.8612),
                  zoom: 14,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                myLocationEnabled: true,
                markers: _markers,
                polylines: _polylines,
              ),
            ),
          ],
        ),

        // 🚀 SEARCHING PANEL
        if (_isSearching)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LinearProgressIndicator(color: Colors.deepPurple),
                  const SizedBox(height: 15),
                  const Text("Searching for nearby mechanic..."),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: cancelRequest,
                    child: const Text("Cancel Request"),
                  ),
                ],
              ),
            ),
          ),

        // ✅ ACCEPTED PANEL
        if (_requestAccepted)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _providerName ?? "Mechanic",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text("🚗 On the way"),
                  const SizedBox(height: 5),
                  Text(
                    "ETA: $_eta",
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
