import 'dart:io';
import 'package:flutter/material.dart';
import '../services/journal_storage.dart';
import 'journal_detail.dart';
import 'journal_edit_screen.dart';
import '../models/journal_entry.dart';

class JournalEntriesScreen extends StatefulWidget {
  const JournalEntriesScreen({Key? key}) : super(key: key);

  @override
  State<JournalEntriesScreen> createState() => _JournalEntriesScreenState();
}

class _JournalEntriesScreenState extends State<JournalEntriesScreen> {
  late Future<List<JournalEntry>> _journalEntriesFuture;

  @override
  void initState() {
    super.initState();
    _journalEntriesFuture = JournalStorage.getEntries();
  }

  void _refreshEntries() {
    setState(() {
      _journalEntriesFuture = JournalStorage.getEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF568F87),
        title: const Text("Journal Entries",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<JournalEntry>>(
        future: _journalEntriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No journal entries yet."));
          }

          final entries = snapshot.data!;
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final formattedDate =
                  "${entry.timestamp.day}/${entry.timestamp.month}/${entry.timestamp.year} "
                  "${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}";

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: entry.imagePath != null &&
                          File(entry.imagePath!).existsSync()
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(entry.imagePath!),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.book, color: Color(0xFF568F87)),
                  title: Text(
                    entry.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(formattedDate),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JournalDetailScreen(entry: entry),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF568F87)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              JournalEditScreen(entry: entry, index: index),
                        ),
                      ).then((_) => _refreshEntries());
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
