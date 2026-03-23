// lib/screens/provider/provider_add_new_garage_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class ProviderAddNewGarageScreen extends StatefulWidget {
  const ProviderAddNewGarageScreen({super.key});

  @override
  State<ProviderAddNewGarageScreen> createState() =>
      _ProviderAddNewGarageScreenState();
}

class _ProviderAddNewGarageScreenState
    extends State<ProviderAddNewGarageScreen> {
  final _formKey = GlobalKey<FormState>();

  // Garage Info Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _numWorkersController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Location
  LatLng? _currentLocation;
  bool _isGettingLocation = false;

  // Dynamic Workers
  List<Map<String, dynamic>> _workers = [];
  final List<TextEditingController> _workerNameControllers = [];
  final List<TextEditingController> _workerRoleControllers = [];
  final List<TextEditingController> _workerPhoneControllers = [];

  bool _isLoading = false;

  final Map<String, bool> _serviceCategories = {
    'Towing': true,
    'Battery Replacement': false,
    'Tire Change': false,
    'Fuel Delivery': false,
    'Jump Start': true,
    'Emergency Repair': true,
    'Other': false,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _numWorkersController.dispose();
    _descriptionController.dispose();
    for (var c in _workerNameControllers) c.dispose();
    for (var c in _workerRoleControllers) c.dispose();
    for (var c in _workerPhoneControllers) c.dispose();
    super.dispose();
  }

  void _addWorker() {
    setState(() {
      _workers.add({'name': '', 'role': '', 'phone': ''});
      _workerNameControllers.add(TextEditingController());
      _workerRoleControllers.add(TextEditingController());
      _workerPhoneControllers.add(TextEditingController());
    });
  }

  void _removeWorker(int index) {
    setState(() {
      _workers.removeAt(index);
      _workerNameControllers.removeAt(index).dispose();
      _workerRoleControllers.removeAt(index).dispose();
      _workerPhoneControllers.removeAt(index).dispose();
    });
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MapPickerScreen(),
      ),
    );

    if (result != null && result is LatLng) {
      setState(() {
        _currentLocation = result;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location selected: ${result.latitude.toStringAsFixed(6)}, '
            '${result.longitude.toStringAsFixed(6)}',
          ),
        ),
      );
    }
  }

  Future<void> _submitGarage() async {
    if (!_formKey.currentState!.validate()) return;

    final selectedServices = _serviceCategories.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one service')),
      );
      return;
    }

    final numberOfWorkers =
        int.tryParse(_numWorkersController.text.trim()) ?? 0;
    if (numberOfWorkers <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Number of workers must be > 0')),
      );
      return;
    }

    for (int i = 0; i < _workers.length; i++) {
      final name = _workerNameControllers[i].text.trim();
      final role = _workerRoleControllers[i].text.trim();
      final phone = _workerPhoneControllers[i].text.trim();

      if (name.isEmpty || role.isEmpty || phone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All worker fields are required')),
        );
        return;
      }
      _workers[i] = {'name': name, 'role': role, 'phone': phone};
    }

    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set garage location')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      await FirebaseFirestore.instance.collection('garages').add({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'contact': _contactController.text.trim(),
        'numberOfWorkers': numberOfWorkers,
        'description': _descriptionController.text.trim(),
        'services': selectedServices,
        'workers': _workers,
        'location': GeoPoint(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
        ),
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFFE6F4E6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.green,
                child: Icon(Icons.check, color: Colors.white, size: 50),
              ),
              const SizedBox(height: 16),
              const Text(
                'Success!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Garage Added Successfully!',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('OK', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add a Garage'),
        backgroundColor: const Color(0xFF1B1B4B),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Garage Info
                const Text(
                  'Garage Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration('Garage Name'),
                  validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('Email Address'),
                  validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _contactController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration('Contact Number'),
                  validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _numWorkersController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Number of Workers'),
                  validator: (v) =>
                      (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Must be > 0' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration:
                      _inputDecoration('Small Description about Garage'),
                  validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),

                // Services
                const Text(
                  'Services Offered',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                ..._serviceCategories.keys.map(
                  (service) => CheckboxListTile(
                    title: Text(service),
                    value: _serviceCategories[service],
                    onChanged: (val) =>
                        setState(() => _serviceCategories[service] = val!),
                  ),
                ),
                const SizedBox(height: 24),

                // Workers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Garage Workers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: _addWorker,
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  _workers.length,
                  (i) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _workerNameControllers[i],
                            decoration: _inputDecoration('Worker Name'),
                            validator: (v) =>
                                v!.trim().isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _workerRoleControllers[i],
                            decoration:
                                _inputDecoration('Role (e.g. Mechanic)'),
                            validator: (v) =>
                                v!.trim().isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _workerPhoneControllers[i],
                            keyboardType: TextInputType.phone,
                            decoration: _inputDecoration('Phone Number'),
                            validator: (v) =>
                                v!.trim().isEmpty ? 'Required' : null,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeWorker(i),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Location
                const Text(
                  'Garage Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                ListTile(
                  leading: const Icon(
                    Icons.location_on,
                    color: Color(0xFF120A4D),
                    size: 32,
                  ),
                  title: const Text(
                    'Set Garage Location',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: _currentLocation == null
                      ? const Text(
                          'Tap to use current location',
                          style: TextStyle(color: Colors.grey),
                        )
                      : Text(
                          '${_currentLocation!.latitude.toStringAsFixed(6)}, '
                          '${_currentLocation!.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: Colors.grey,
                  ),
                  tileColor: Colors.grey[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: _isGettingLocation ? null : _pickLocation,
                ),

                if (_currentLocation == null)
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 4, bottom: 16),
                    child: Text(
                      'Location is required',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),

                if (_isGettingLocation)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ),

                const SizedBox(height: 32),

                // Submit
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitGarage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF120A4D),
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'ADD GARAGE',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

///////////////////////////////////////////////////////////////
/// 🔥 MAP PICKER SCREEN (DO NOT CHANGE UI ABOVE)
///////////////////////////////////////////////////////////////

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng _pickedLocation = const LatLng(6.9271, 79.8612); // default
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final loc = LatLng(pos.latitude, pos.longitude);

      setState(() => _pickedLocation = loc);

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(loc, 16),
      );
    } catch (e) {
      // silent fail (no UI break)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick Location")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: _pickedLocation, zoom: 14),
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onCameraMove: (position) {
              _pickedLocation = position.target;
            },
          ),

          // Center Pin
          const Center(
            child: Icon(Icons.location_pin, size: 45, color: Colors.red),
          ),

          // Confirm Button
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _pickedLocation),
              child: const Text("Confirm Location"),
            ),
          )
        ],
      ),
    );
  }
}