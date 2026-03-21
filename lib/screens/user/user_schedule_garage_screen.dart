import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schedule Time',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      home: const ScheduleTimeScreen(),
    );
  }
}

class ScheduleTimeScreen extends StatefulWidget {
  const ScheduleTimeScreen({super.key});

  @override
  State<ScheduleTimeScreen> createState() => _ScheduleTimeScreenState();
}
class _ScheduleTimeScreenState extends State<ScheduleTimeScreen> {
  // Selected dates
  final Set<int> _selectedDates = {};

  // Current month/year
  DateTime _currentMonth = DateTime.now();

  // Time pickers
  int _startHour = 10;
  int _startMinute = 30;
  bool _startIsAm = true;

  // int _endHour = 5;
  // int _endMinute = 30;
  // bool _endIsAm = false;

  // Special date colors
  // final Map<int, Color> _dateColors = {
  //   6: const Color(0xFFE53935),   // red
  //   19: const Color(0xFFE53935),  // red
  //   20: Colors.white,
  //   21: Colors.white,
  //   22: const Color(0xFFE53935),  // red outline
  // };

  // Dates that are "range" (light highlight)
  final Set<int> _rangeDates = {20, 21};

  // Days with range highlight (connected row)
  final Set<int> _rangeHighlight = {19, 20, 21, 22};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildTimePickers(),
                    const SizedBox(height: 24),
                    _buildCalendar(),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                    const SizedBox(height: 12),
                    _buildReadMore(),
                  ],
                ),
              ),
            ),
            _buildBookNowButton(),
          ],
        ),
      ),
    );
  }