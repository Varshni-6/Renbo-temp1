import 'package:hive_flutter/hive_flutter.dart';
import '../models/journal_entry.dart';

class JournalStorage {
  static const String _boxName = 'journalEntries';
  static late Box<JournalEntry> _box;

  static Future<List<JournalEntry>> getEntries() async {
    return _box.values.toList();
  }

  // Method to initialize Hive and open the box
  static Future<void> init() async {
    _box = await Hive.openBox<JournalEntry>(_boxName);
  }

  // Add a new entry to the box
  static void addEntry(JournalEntry entry) {
    _box.add(entry);
  }

  // Update an existing entry
  static void updateEntry(int index, JournalEntry entry) {
    if (index >= 0 && index < _box.length) {
      _box.putAt(index, entry);
    }
  }

  // Delete an entry
  static Future<void> deleteEntry(int index) async {
    if (index >= 0 && index < _box.length) {
      await _box.deleteAt(index);
    }
  }

  // Get all entries
  static List<JournalEntry> get entries => _box.values.toList();
}
