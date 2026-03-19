import 'package:flutter/material.dart';

class AddGarageScreen extends StatefulWidget {
  const AddGarageScreen({super.key});

  @override
  State<AddGarageScreen> createState() => _AddGarageScreenState();
}

class _AddGarageScreenState extends State<AddGarageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Garage'),
      ),
      body: const Center(
        child: Text('Add Garage Screen'),
      ),
    );
  }
}