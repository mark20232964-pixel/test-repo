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