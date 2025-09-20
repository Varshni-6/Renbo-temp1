import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/journal_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../models/journal_entry.dart';

class JournalEditScreen extends StatefulWidget {
  final JournalEntry entry;
  final int index;

  const JournalEditScreen({required this.entry, required this.index, Key? key})
      : super(key: key);

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
    widget.entry.content = _contentController.text;
    JournalStorage.updateEntry(widget.index, widget.entry);
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
            TextField(controller: _contentController),
            ElevatedButton(onPressed: _saveEntry, child: const Text("Save"))
          ],
        ),
      ),
    );
  }
}