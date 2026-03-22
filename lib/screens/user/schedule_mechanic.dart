// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ScheduleMechanicScreen extends StatefulWidget {
  final Map<String, dynamic> schedule;
  const ScheduleMechanicScreen({super.key, required this.schedule});

  @override
  State<ScheduleMechanicScreen> createState() => _ScheduleMechanicScreenState();
}

class _ScheduleMechanicScreenState extends State<ScheduleMechanicScreen> {
  static const _primary = Color(0xFF1B1B4B);
  static const _accent = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    final name = widget.schedule['name'] as String? ?? 'Mechanic';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(name),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Container(
      color: _primary,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Text(
              'Schedule with $name',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.favorite_border, color: Colors.white70, size: 22),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A)));
  }
}