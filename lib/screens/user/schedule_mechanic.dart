// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:roadresq/models/schedule.dart';
import 'package:roadresq/repositories/schedule_repository.dart';
import 'package:roadresq/screens/services/service.dart';

class ScheduleMechanicScreen extends StatefulWidget {
  final Map<String, dynamic> schedule;
  const ScheduleMechanicScreen({super.key, required this.schedule});

  @override
  State<ScheduleMechanicScreen> createState() => _ScheduleMechanicScreenState();
}

class _ScheduleMechanicScreenState extends State<ScheduleMechanicScreen> {
  static const _primary = Color(0xFF1B1B4B);
  static const _accent = Color(0xFFE53935);

  int? _selectedDate;
  DateTime _currentMonth = DateTime.now();
  int _startHour = 10;
  int _startMinute = 0;
  bool _startIsAm = true;
  bool _isLoading = false;

  final _repository = ScheduleRepository();

  Future<void> _scheduleNow() async {
    setState(() => _isLoading = true);
    print(widget.schedule['location']);
    final schedule = ScheduleModel(
      userId: AuthService().currentUser!.uid,
      providerId: widget.schedule['providerId'] as String,
      issue: '',
      location: widget.schedule['userLocation'],
      providerLocation: widget.schedule['location'] as GeoPoint,
      scheduledTime: DateTime(
        _currentMonth.year,
        _currentMonth.month,
        _selectedDate!,
        _startIsAm ? _startHour % 12 : (_startHour % 12) + 12,
        _startMinute,
      ),
    );
    try {
      await _repository.createSchedule(schedule);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Schedule booked successfully!',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
                    const SizedBox(height: 20),
                    _buildSectionLabel('Preferred Time'),
                    const SizedBox(height: 10),
                    _buildTimePickerCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildScheduleButton(),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

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

  // ── Mechanic Profile ────────────────────────────────────────────────────────

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
                      style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Calendar ────────────────────────────────────────────────────────────────

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
          const SizedBox(height: 10),
          _buildDayLabels(),
          const SizedBox(height: 6),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    const monthNames = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
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

  Widget _buildDayLabels() {
    const days = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days
          .map((d) => SizedBox(
        width: 34,
        child: Center(
          child: Text(d,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade400)),
        ),
      ))
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startOffset = firstDay.weekday % 7;
    final prevLast = DateTime(_currentMonth.year, _currentMonth.month, 0).day;

    final cells = <Widget>[
      for (int i = startOffset - 1; i >= 0; i--)
        _buildDayCell(prevLast - i, isOtherMonth: true),
      for (int d = 1; d <= lastDay.day; d++)
        _buildDayCell(d, isOtherMonth: false),
    ];

    final rem = 7 - (cells.length % 7);
    if (rem < 7) {
      for (int i = 1; i <= rem; i++) {
        cells.add(_buildDayCell(i, isOtherMonth: true));
      }
    }

    return Column(
      children: [
        for (int i = 0; i < cells.length; i += 7) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: cells.sublist(i, (i + 7).clamp(0, cells.length)),
          ),
          const SizedBox(height: 2),
        ],
      ],
    );
  }

  Widget _buildDayCell(int day, {required bool isOtherMonth}) {
    if (isOtherMonth) {
      return SizedBox(
        width: 34,
        height: 34,
        child: Center(
          child: Text('$day',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade300)),
        ),
      );
    }

    final isSelected = _selectedDate == day;
    final now = DateTime.now();
    final isToday = day == now.day &&
        _currentMonth.month == now.month &&
        _currentMonth.year == now.year;

    return GestureDetector(
      onTap: () => setState(() => _selectedDate = isSelected ? null : day),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? _primary : Colors.transparent,
          border: isToday && !isSelected
              ? Border.all(color: _accent, width: 1.5)
              : null,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 13,
              fontWeight:
              isSelected || isToday ? FontWeight.w700 : FontWeight.w400,
              color: isSelected
                  ? Colors.white
                  : isToday
                  ? _accent
                  : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // ── Time Picker ─────────────────────────────────────────────────────────────

  Widget _buildTimePickerCard() {
    return GestureDetector(
      onTap: _showTimePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.access_time, color: _primary, size: 20),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Appointment Time',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(
                  '${_startHour.toString().padLeft(2, '0')} : '
                      '${_startMinute.toString().padLeft(2, '0')}  '
                      '${_startIsAm ? 'AM' : 'PM'}',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                      letterSpacing: 0.5),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _showTimePicker() {
    int h = _startHour, m = _startMinute;
    bool am = _startIsAm;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (_, setModal) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              const Text('Select Time',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _spinnerColumn(
                      value: h,
                      min: 1,
                      max: 12,
                      onChanged: (v) => setModal(() => h = v)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(':',
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold)),
                  ),
                  _spinnerColumn(
                      value: m,
                      min: 0,
                      max: 59,
                      onChanged: (v) => setModal(() => m = v)),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      _amPmButton(
                          label: 'AM',
                          active: am,
                          onTap: () => setModal(() => am = true)),
                      const SizedBox(height: 8),
                      _amPmButton(
                          label: 'PM',
                          active: !am,
                          onTap: () => setModal(() => am = false)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _startHour = h;
                      _startMinute = m;
                      _startIsAm = am;
                    });
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Confirm',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _amPmButton({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? _primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
                color: active ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _spinnerColumn({
    required int value,
    required int min,
    required int max,
    required void Function(int) onChanged,
  }) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up),
          onPressed: () => onChanged(value < max ? value + 1 : min),
        ),
        Text(value.toString().padLeft(2, '0'),
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => onChanged(value > min ? value - 1 : max),
        ),
      ],
    );
  }

  // ── Schedule Button ─────────────────────────────────────────────────────────

  Widget _buildScheduleButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -3)),
        ],
      ),
      child: ElevatedButton(
        onPressed: (_selectedDate != null && !_isLoading) ? _scheduleNow : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        )
            : Text(
          _selectedDate == null
              ? 'Pick a Date to Continue'
              : 'Schedule Now',
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3),
        ),
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