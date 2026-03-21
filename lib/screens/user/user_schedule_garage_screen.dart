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
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.chevron_left, size: 28, color: Colors.black87),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Schedule time',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.favorite_border, size: 24, color: Colors.black87),
          ),
        ],
      ),
    );
  }
  Widget _buildTimePickers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Time',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildTimeCard(
              hour: _startHour,
              minute: _startMinute,
              isAm: _startIsAm,
              isActive: true,
              onChanged: (h, m, am) {
                setState(() {
                  _startHour = h;
                  _startMinute = m;
                  _startIsAm = am;
                });
              },
            ),
            // const SizedBox(width: 12),
            // _buildTimeCard(
            //   hour: _endHour,
            //   minute: _endMinute,
            //   isAm: _endIsAm,
            //   isActive: false,
            //   onChanged: (h, m, am) {
            //     setState(() {
            //       _endHour = h;
            //       _endMinute = m;
            //       _endIsAm = am;
            //     });
            //   },
            // ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeCard({
    required int hour,
    required int minute,
    required bool isAm,
    required bool isActive,
    required Function(int, int, bool) onChanged,
  }) {
    return GestureDetector(
      onTap: () => _showTimePicker(hour, minute, isAm, onChanged),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: isActive ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white54, width: 1.5),
                ),
                child: const Icon(Icons.circle, size: 10, color: Colors.white),
              )
            else
              Icon(Icons.access_time, size: 18, color: Colors.grey.shade500),
            const SizedBox(width: 8),
            Text(
              '${hour.toString().padLeft(2, '0')} : ${minute.toString().padLeft(2, '0')}  ${isAm ? 'am' : 'pm'}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimePicker(int hour, int minute, bool isAm, Function(int, int, bool) onChanged) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        int selectedHour = hour;
        int selectedMinute = minute;
        bool selectedIsAm = isAm;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _spinnerColumn(
                        value: selectedHour,
                        min: 1,
                        max: 12,
                        onChanged: (v) => setModalState(() => selectedHour = v),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(':', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      ),
                      _spinnerColumn(
                        value: selectedMinute,
                        min: 0,
                        max: 59,
                        onChanged: (v) => setModalState(() => selectedMinute = v),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () => setModalState(() => selectedIsAm = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: selectedIsAm ? Colors.black : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('AM', style: TextStyle(color: selectedIsAm ? Colors.white : Colors.black)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => setModalState(() => selectedIsAm = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: !selectedIsAm ? Colors.black : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('PM', style: TextStyle(color: !selectedIsAm ? Colors.white : Colors.black)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        onChanged(selectedHour, selectedMinute, selectedIsAm);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Confirm'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _spinnerColumn({
    required int value,
    required int min,
    required int max,
    required Function(int) onChanged,
  }) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up),
          onPressed: () => onChanged(value < max ? value + 1 : min),
        ),
        Text(
          value.toString().padLeft(2, '0'),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => onChanged(value > min ? value - 1 : max),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return Column(
      children: [
        _buildMonthHeader(),
        const SizedBox(height: 12),
        _buildDayLabels(),
        const SizedBox(height: 8),
        _buildCalendarGrid(),
      ],
    );
  }

  Widget _buildMonthHeader() {
    final monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => setState(() {
            _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
          }),
          child: const Icon(Icons.chevron_left, size: 22, color: Colors.black87),
        ),
        Text(
          '${monthNames[_currentMonth.month]} ${_currentMonth.year}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        GestureDetector(
          onTap: () => setState(() {
            _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
          }),
          child: const Icon(Icons.chevron_right, size: 22, color: Colors.black87),
        ),
      ],
    );
  }