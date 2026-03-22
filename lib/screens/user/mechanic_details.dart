// lib/screens/user/mechanic_details.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
