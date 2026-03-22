import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  LatLng _selectedLocation = const LatLng(6.9271, 79.8612); // default Colombo
  final TextEditingController _searchController = TextEditingController();

  Marker? _marker;

  @override
  void initState() {
    super.initState();
    _updateMarker();
  }

  void _updateMarker() {
    _marker = Marker(
      markerId: const MarkerId('selected'),
      position: _selectedLocation,
      draggable: true,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      onDragEnd: (newPosition) {
        setState(() {
          _selectedLocation = newPosition;
        });
      },
    );
  }

  Future<void> _searchLocation() async {
    String location = _searchController.text.trim();

    if (location.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(location);

      if (locations.isNotEmpty) {
        final loc = locations.first;

        LatLng newLatLng = LatLng(loc.latitude, loc.longitude);

        final controller = await _controller.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: newLatLng, zoom: 16),
          ),
        );

        setState(() {
          _selectedLocation = newLatLng;
          _updateMarker();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location not found")),
      );
    }
  }

  void _saveLocation() {
    Navigator.pop(context, _selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _controller.complete(controller);
            },
            markers: {_marker!},
            onTap: (latLng) {
              setState(() {
                _selectedLocation = latLng;
                _updateMarker();
              });
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),

          // 🔍 SEARCH BAR
          Positioned(
            top: 20,
            left: 15,
            right: 15,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search location...",
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(15),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchLocation,
                  ),
                ),
              ),
            ),
          ),

          // 💾 SAVE BUTTON
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _saveLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A48FF),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                "Save Location",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
