import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  bool _isLoading = false;
  Position? _currentPosition;
  List<Map<String, dynamic>> _nearbyServices = [];
  String? _errorMessage;
  String? _lastSosDocumentId;
  bool _sosActive = false;

  StreamSubscription<Position>? _positionStreamSubscription;

  // Google Places API key
  static const String _googleApiKey = 'AIzaSyDC-Vg3GG5uDyDb5JuIzPKeKEIeUXwoXho';

  // Controls how often we re-search places (avoid API spam)
  Position? _lastSearchedPosition;
  static const double _minDistanceToRefresh = 300.0; // meters

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startSos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _nearbyServices.clear();
      _lastSosDocumentId = null;
      _sosActive = false;
    });

    // 1. Permissions & services
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Location services are disabled. Please enable them.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError('Location permission denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showError('Location permission permanently denied.\nPlease enable in settings.');
      return;
    }

    try {
      // 2. Get initial position
      final initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() => _currentPosition = initialPosition);

      // 3. Log SOS to Firestore
      final sosDocId = await _logSosAlert(initialPosition.latitude, initialPosition.longitude);
      if (sosDocId != null && mounted) {
        setState(() {
          _lastSosDocumentId = sosDocId;
          _sosActive = true;
        });
      }

      // 4. Initial nearby search
      await _searchNearbyEmergencyServices(initialPosition.latitude, initialPosition.longitude);
      _lastSearchedPosition = initialPosition;

      // 5. Start live location stream
      _startLiveLocationUpdates();

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      _showError('Failed to start SOS: $e');
    }
  }

  void _startLiveLocationUpdates() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,      // or high / medium
      distanceFilter: 50,                   // update only after 50m movement
      timeLimit: Duration(seconds: 80),     // safety timeout
    );

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) async {
        if (!mounted) return;

        setState(() => _currentPosition = position);

        // Only re-search if moved far enough (save API quota)
        if (_lastSearchedPosition == null ||
            Geolocator.distanceBetween(
              _lastSearchedPosition!.latitude,
              _lastSearchedPosition!.longitude,
              position.latitude,
              position.longitude,
            ) >= _minDistanceToRefresh) {
          await _searchNearbyEmergencyServices(position.latitude, position.longitude);
          _lastSearchedPosition = position;
        }
      },
      onError: (e) {
        _showError('Location stream error: $e');
      },
    );
  }

  Future<String?> _logSosAlert(double lat, double lng) async {
    final user = FirebaseAuth.instance.currentUser;
    try {
      final docRef = await FirebaseFirestore.instance.collection('sos_alerts').add({
        'userId': user?.uid ?? 'anonymous',
        'timestamp': FieldValue.serverTimestamp(),
        'location': GeoPoint(lat, lng),
        'accuracy': _currentPosition?.accuracy ?? 0.0,
        'status': 'active',
      });
      print("SOS logged → ID: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      print("Error logging SOS: $e");
      return null;
    }
  }

  Future<void> _searchNearbyEmergencyServices(double lat, double lng) async {
    const types = ['hospital', 'police', 'fire_station'];
    final List<Map<String, dynamic>> results = [];

    for (String type in types) {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=$lat,$lng'
        '&radius=5000' // 5 km
        '&type=$type'
        '&key=$_googleApiKey',
      );

      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'OK' && data['results'] != null) {
            for (var place in data['results'] as List) {
              final name = place['name'] ?? 'Unknown';
              final vicinity = place['vicinity'] ?? '';
              final rating = place['rating']?.toString() ?? 'N/A';
              final latLng = place['geometry']['location'];
              final distance = Geolocator.distanceBetween(lat, lng, latLng['lat'], latLng['lng']) / 1000;

              results.add({
                'name': name,
                'type': type[0].toUpperCase() + type.substring(1),
                'vicinity': vicinity,
                'distance': '${distance.toStringAsFixed(1)} km',
                'rating': rating,
                'phone': place['formatted_phone_number'] ?? place['international_phone_number'] ?? null,
              });
            }
          }
        }
      } catch (e) {
        print("Error searching $type: $e");
      }
    }

    if (mounted) {
      setState(() {
        _nearbyServices = results;
        if (_nearbyServices.isEmpty && _errorMessage == null) {
          _errorMessage = 'No emergency services found within 5 km.';
        }
      });
    }
  }

  Future<void> _cancelSosAlert() async {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;

    if (_lastSosDocumentId == null) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('sos_alerts').doc(_lastSosDocumentId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          _sosActive = false;
          _lastSosDocumentId = null;
          _nearbyServices.clear();
          _errorMessage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SOS alert cancelled'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      _showError('Failed to cancel SOS: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (mounted) {
      setState(() {
        _errorMessage = msg;
        _isLoading = false;
      });
    }
  }

  Future<void> _callNumber(String? phone) async {
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number available')),
      );
      return;
    }
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open dialer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1B4B),
        foregroundColor: Colors.white,
        title: const Text('SOS Emergency'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : _nearbyServices.isNotEmpty || _errorMessage != null
              ? _buildServicesList()
              : _buildSosButtonScreen(),
    );
  }

  Widget _buildSosButtonScreen() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Your live location will be used to find nearby help",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _sosActive ? null : _startSos,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _sosActive ? Colors.grey[800] : Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: (_sosActive ? Colors.grey : Colors.red).withOpacity(0.6),
                    blurRadius: 50,
                    spreadRadius: 15,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _sosActive ? 'LIVE' : 'SOS',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (_sosActive) ...[
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _cancelSosAlert,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('CANCEL SOS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Tap if sent by mistake', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ] else ...[
            const SizedBox(height: 40),
            const Text("Tap for immediate emergency help", style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _startSos,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('SEND SOS ALERT', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServicesList() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Nearby Emergency Services (Live)',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_currentPosition != null)
          Text(
            'Live location: ${_currentPosition!.latitude.toStringAsFixed(5)}, ${_currentPosition!.longitude.toStringAsFixed(5)}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        const SizedBox(height: 24),
        ..._nearbyServices.map((service) => Card(
              color: const Color(0xFF1B1B4B),
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Icon(
                  service['type'] == 'Police' ? Icons.local_police :
                  service['type'] == 'Hospital' ? Icons.local_hospital :
                  Icons.fire_truck,
                  color: const Color(0xFF6A48FF),
                  size: 40,
                ),
                title: Text(service['name'], style: const TextStyle(color: Colors.white, fontSize: 17)),
                subtitle: Text('${service['distance']} • ${service['type']}', style: const TextStyle(color: Colors.white70)),
                trailing: service['phone'] != null
                    ? ElevatedButton(
                        onPressed: () => _callNumber(service['phone']),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A48FF)),
                        child: const Text('Call Now'),
                      )
                    : const Text('No phone', style: TextStyle(color: Colors.grey)),
              ),
            )),
        const SizedBox(height: 30),
        const Text(
          'Services updated based on your live location.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}