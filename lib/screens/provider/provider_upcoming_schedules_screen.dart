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

  Future<void> _acceptRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('requests')
        .doc(requestId)
        .update({
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request accepted'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _declineRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('requests')
        .doc(requestId)
        .delete();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request declined and removed'),
          backgroundColor: Colors.orange,
        ),
      );
    }
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

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requestsForDay.length,
                  itemBuilder: (context, index) {
                    final data = requestsForDay[index].data() as Map<String, dynamic>;
                    final requestId = requestsForDay[index].id;
                    final status = data['status'] as String? ?? 'pending';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage: data['userPhoto'] != null
                                      ? NetworkImage(data['userPhoto'])
                                      : null,
                                  child: data['userPhoto'] == null
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['userName'] ?? 'User',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(data['issue'] ?? 'No issue specified'),
                                      Text(
                                        (data['scheduledTime'] as Timestamp?)
                                                ?.toDate()
                                                .toString()
                                                .substring(0, 16) ??
                                            '',
                                        style: const TextStyle(color: Colors.grey),
                                      ),

                                      if (status == 'accepted')
                                        const Padding(
                                          padding: EdgeInsets.only(top: 4),
                                          child: Text(
                                            'Accepted',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            if (status == 'pending') ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _acceptRequest(requestId),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                      child: const Text('Accept'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _declineRequest(requestId),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      child: const Text('Decline'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}