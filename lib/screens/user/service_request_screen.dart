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
}
