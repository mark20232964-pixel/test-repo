import 'package:flutter/material.dart';

class ProviderOngoingScreen extends StatefulWidget {
  const ProviderOngoingScreen({super.key});

  @override
  State<ProviderOngoingScreen> createState() => _ProviderOngoingScreenState();
}

class _ProviderOngoingScreenState extends State<ProviderOngoingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ongoing Requests"),
      ),
      body: const Center(
        child: Text("Ongoing Requests Screen"),
      ),
    );
  }
}
