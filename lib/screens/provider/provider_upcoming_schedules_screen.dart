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

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _requestsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No upcoming schedules yet.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                // 🔥 FILTER BY SELECTED DAY
                final requestsForDay = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final ts = data['scheduledTime'] as Timestamp?;
                  return ts != null && isSameDay(ts.toDate(), _selectedDay);
                }).toList();

                if (requestsForDay.isEmpty) {
                  return const Center(
                    child: Text(
                      "No schedules for selected day.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return Center(
                  child: Text(
                    "Schedules for day: ${requestsForDay.length}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}