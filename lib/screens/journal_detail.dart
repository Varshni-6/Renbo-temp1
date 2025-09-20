import 'package:flutter/material.dart';
import '../models/journal_entry.dart';

class JournalDetailScreen extends StatelessWidget {
  final JournalEntry entry;

  const JournalDetailScreen({required this.entry, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Journal Detail")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.content),
            const SizedBox(height: 8),
            Text(entry.emotion ?? "No mood"),
            Text(entry.timestamp.toString()),
          ],
        ),
      ),
    );
  }
}
