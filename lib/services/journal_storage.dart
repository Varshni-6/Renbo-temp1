import 'package:hive_flutter/hive_flutter.dart';
import '../models/journal_entry.dart';

class JournalStorage {
  static const String _boxName = 'journalEntries';
  static late Box<JournalEntry> _box;

  /// Initializes Hive and opens the journal entries box.
  /// This should be called once when the app starts.
  static Future<void> init() async {
    // The key for the box will now be the entry's unique ID (String),
    // and the value will be the JournalEntry object itself.
    _box = await Hive.openBox<JournalEntry>(_boxName);
  }

  /// Adds a new entry to the box.
  /// The entry's own unique `id` is used as the key.
  static Future<void> addEntry(JournalEntry entry) async {
    // Using put() with the entry's ID as the key.
    // This also works for updating if an entry with the same ID already exists.
    await _box.put(entry.getId, entry);  // Use the getter getId here
  }

  /// Updates an existing entry.
  /// It finds the entry by its ID and overwrites it.
  static Future<void> updateEntry(JournalEntry entry) async {
    // Hive's put() method automatically handles updates.
    // It will overwrite the existing entry that has the same key (entry.id).
    await _box.put(entry.getId, entry);  // Use the getter getId here
  }

  /// Deletes an entry from the box using its unique ID.
  static Future<void> deleteEntry(String id) async {
    await _box.delete(id);
  }

  /// Gets all entries from the box.
  /// The order might not be guaranteed, so we sort by timestamp.
  static Future<List<JournalEntry>> getEntries() async {
    var entries = _box.values.toList();
    // Sort entries so the most recent ones appear first.
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }
}
