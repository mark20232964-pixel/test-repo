import 'package:flutter/material.dart';

class ProviderRequestDetailsScreen extends StatelessWidget {
  const ProviderRequestDetailsScreen({
    super.key,
    required this.requestId,
    required this.data,
  });

  final String requestId;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text("Request Details"),
      ),
    );
  }
}
