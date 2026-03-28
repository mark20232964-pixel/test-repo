import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProviderUpcomingSchedulesScreen extends StatefulWidget {
  const ProviderUpcomingSchedulesScreen({super.key});

  @override
  State<ProviderUpcomingSchedulesScreen> createState() => _ProviderUpcomingSchedulesScreenState();
}

class _ProviderUpcomingSchedulesScreenState extends State<ProviderUpcomingSchedulesScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  Stream<QuerySnapshot>? _requestsStream;

  @override
  void initState() {
    super.initState();

    final providerId = FirebaseAuth.instance.currentUser?.uid;

    if (providerId != null) {
      _requestsStream = FirebaseFirestore.instance
          .collection('requests')
          .where('providerId', isEqualTo: providerId)
          .where('status', whereIn: ['pending', 'accepted'])
          .snapshots();
    }
  }

  bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Schedules'),
        backgroundColor: const Color(0xFF1B1B4B),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2024),
            lastDay: DateTime(2027),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),

          const Divider(height: 1),

          const Expanded(
            child: Center(
              child: Text('Loading schedules...'),
            ),
          ),
        ],
      ),
    );
  }
}