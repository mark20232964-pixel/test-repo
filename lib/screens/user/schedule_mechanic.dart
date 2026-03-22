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

  DateTime _currentMonth = DateTime.now();

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
                    _buildMechanicProfile(name),
                    const SizedBox(height: 20),
                    _buildSectionLabel('Pick a Date'),
                    const SizedBox(height: 10),
                    _buildCalendarCard(),
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

  Widget _buildMechanicProfile(String name) {
    final experience = widget.schedule['experience'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: _primary.withOpacity(0.1),
            backgroundImage: widget.schedule['avatar'] != null
                ? NetworkImage(widget.schedule['avatar'] as String)
                : null,
            child: widget.schedule['avatar'] == null
                ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'M',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _primary),
            )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A))),
                if (experience.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(experience,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          _buildMonthHeader(),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    const monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => setState(() => _currentMonth =
              DateTime(_currentMonth.year, _currentMonth.month - 1)),
          child: const Icon(Icons.chevron_left, size: 22, color: _primary),
        ),
        Text(
          '${monthNames[_currentMonth.month]} ${_currentMonth.year}',
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700, color: _primary),
        ),
        GestureDetector(
          onTap: () => setState(() => _currentMonth =
              DateTime(_currentMonth.year, _currentMonth.month + 1)),
          child: const Icon(Icons.chevron_right, size: 22, color: _primary),
        ),
      ],
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