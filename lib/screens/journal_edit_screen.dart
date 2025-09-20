import 'package:flutter/material.dart';
import '../services/journal_storage.dart';
import '../models/journal_entry.dart';

class JournalEditScreen extends StatefulWidget {
  final JournalEntry entry;

  // Constructor now only requires the entry object
  const JournalEditScreen({required this.entry, Key? key}) : super(key: key);

  @override
  State<JournalEditScreen> createState() => _JournalEditScreenState();
}

class _JournalEditScreenState extends State<JournalEditScreen> {
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.entry.content);
  }

  void _saveEntry() {
    // Update the content from the controller
    widget.entry.content = _contentController.text;
    // Call the updated storage method
    JournalStorage.updateEntry(widget.entry);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Entry")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: "Edit your thoughts...",
                  border: InputBorder.none,
                ),
              ),
            ),
            ElevatedButton(onPressed: _saveEntry, child: const Text("Save Changes"))
          ],
        ),
      ),
    );
  }
}
