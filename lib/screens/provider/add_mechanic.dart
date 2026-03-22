// lib/screens/provider/add_mechanic.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class AddMechanicScreen extends StatefulWidget {
  const AddMechanicScreen({super.key});

  @override
  State<AddMechanicScreen> createState() => _AddMechanicScreenState();
}

class _AddMechanicScreenState extends State<AddMechanicScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  LatLng? _selectedLocation;

  Future<void> _openMapPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MapPickerScreen(),
      ),
    );

    if (result != null && result is LatLng) {
      setState(() => _selectedLocation = result);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select location")),
      );
      return;
    }

    setState(() {}); // trigger loading if you add _isLoading later

    try {
      final user = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance
          .collection('providers')
          .doc(user.uid)
          .set({
        "type": "mechanic",
        "name": _nameController.text.trim(),
        "phone": _phoneController.text.trim(),
        "location": GeoPoint(
          _selectedLocation!.latitude,
          _selectedLocation!.longitude,
        ),
        "createdAt": Timestamp.now(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mechanic added successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add mechanic: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Mechanic")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                validator: (v) => v!.trim().isEmpty ? "Enter name" : null,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                validator: (v) => v!.trim().isEmpty ? "Enter phone" : null,
                decoration: const InputDecoration(labelText: "Phone"),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text("Select Location"),
                subtitle: Text(_selectedLocation == null
                    ? "Tap to pick"
                    : "${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}"),
                trailing: const Icon(Icons.map),
                onTap: _openMapPicker,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _submit,
                child: const Text("Submit"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng _pickedLocation = const LatLng(6.9271, 79.8612);
  GoogleMapController? _mapController;

  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _suggestions = [];

  final String apiKey =
      "YOUR_ACTUAL_API_KEY_HERE"; // ← Replace with your real key

  @override
  void initState() {
    super.initState();
    _getLiveLocation();
  }

  Future<void> _getLiveLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final live = LatLng(pos.latitude, pos.longitude);

    setState(() {
      _pickedLocation = live;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(live, 17),
    );
  }

  Future<void> _searchPlaces(String input) async {
    if (input.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey";

    final res = await http.get(Uri.parse(url));
    final data = json.decode(res.body);

    setState(() {
      _suggestions = data["predictions"] ?? [];
    });
  }

  Future<void> _selectPlace(String placeId) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey";

    final res = await http.get(Uri.parse(url));
    final data = json.decode(res.body);

    final loc = data["result"]["geometry"]["location"];

    final newLoc = LatLng(loc["lat"], loc["lng"]);

    setState(() {
      _pickedLocation = newLoc;
      _suggestions = [];
      _searchController.clear();
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(newLoc, 17),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _pickedLocation,
              zoom: 14,
            ),
            onMapCreated: (c) => _mapController = c,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            onCameraMove: (pos) {
              _pickedLocation = pos.target;
            },
          ),
          const Center(
            child: Icon(Icons.location_pin, size: 45, color: Colors.red),
          ),
          Positioned(
            top: 50,
            left: 15,
            right: 15,
            child: Column(
              children: [
                Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(10),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchPlaces,
                    decoration: const InputDecoration(
                      hintText: "Search location...",
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(15),
                    ),
                  ),
                ),
                if (_suggestions.isNotEmpty)
                  Container(
                    height: 200,
                    color: Colors.white,
                    child: ListView.builder(
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final item = _suggestions[index];

                        return ListTile(
                          title: Text(item["description"]),
                          onTap: () => _selectPlace(item["place_id"]),
                        );
                      },
                    ),
                  )
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _pickedLocation);
              },
              child: const Text("Confirm Location"),
            ),
          )
        ],
      ),
    );
  }
}
