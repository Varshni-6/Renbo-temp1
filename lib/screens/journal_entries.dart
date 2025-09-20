import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/journal_storage.dart';

class JournalEntriesPage extends StatefulWidget {
  @override
  _JournalEntriesPageState createState() => _JournalEntriesPageState();
}

class _JournalEntriesPageState extends State<JournalEntriesPage> {
  late Future<List<JournalEntry>> _entries;

  @override
  void initState() {
    super.initState();
    _entries = JournalStorage.getEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Journal Entries')),
      body: FutureBuilder<List<JournalEntry>>(
        future: _entries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No journal entries available.'));
          } else {
            final entries = snapshot.data!;

            return ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];

                return ListTile(
                  key: Key(entry.getId), // Use the unique ID as the key
                  title: Text(entry.content),
                  subtitle: Text(entry.timestamp.toString()),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await JournalStorage.deleteEntry(entry.getId);  // Use the getter getId here
                      setState(() {
                        _entries = JournalStorage.getEntries();
                      });
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
