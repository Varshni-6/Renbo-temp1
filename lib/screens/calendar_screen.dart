import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/journal_entry.dart';
import '../services/journal_storage.dart';
import 'journal_screen.dart';
import 'journal_entries.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Map<DateTime, List<String>> _events;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<String, String> _moodEmojis = {
    'Happy': '😄',
    'Sad': '😢',
    'Angry': '😠',
    'Confused': '🤔',
    'Excited': '🥳',
    'Calm': '😌',
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _events = {};
    _loadEntriesForCalendar();
  }

  /// Fetches entries from storage and groups them by date for the calendar
  void _loadEntriesForCalendar() async {
    final allEntries = await JournalStorage.getEntries();
    final Map<DateTime, List<String>> events = {};
    for (var entry in allEntries) {
      final date = DateTime.utc(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );
      if (entry.emotion != null) {
        events.putIfAbsent(date, () => []);
        events[date]!.add(entry.emotion!);
      }
    }
    if (mounted) {
      setState(() {
        _events = events;
      });
    }
  }

  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _showMoodSelector(context, selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'View All Entries',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JournalEntriesPage(), // ✅ FIXED
                ),
              ).then((_) => _loadEntriesForCalendar());
            },
          ),
        ],
      ),
      body: TableCalendar<String>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: _onDaySelected,
        eventLoader: _getEventsForDay,
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              return Positioned(
                right: 1,
                bottom: 1,
                child: Text(
                  events
                      .toSet()
                      .take(4)
                      .map((mood) => _moodEmojis[mood] ?? '📝')
                      .join(),
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  /// Shows a dialog to let the user pick their mood for the selected day
  void _showMoodSelector(BuildContext context, DateTime selectedDate) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('How are you feeling?'),
          content: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            alignment: WrapAlignment.center,
            children: _moodEmojis.entries.map((entry) {
              return ElevatedButton.icon(
                icon: Text(entry.value, style: const TextStyle(fontSize: 20)),
                label: Text(entry.key),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JournalScreen(emotion: entry.key),
                    ),
                  ).then((_) {
                    _loadEntriesForCalendar();
                  });
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
