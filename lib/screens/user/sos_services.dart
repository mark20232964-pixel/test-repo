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
      body: const Center(child: Text("SOS Screen")),
    );
  }
}