import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../services/journal_storage.dart';
import '../models/journal_entry.dart';
import '../models/sticker.dart';
import 'journal_entries.dart';

class JournalEditScreen extends StatefulWidget {
  final JournalEntry entry;

  const JournalEditScreen({Key? key, required this.entry}) : super(key: key);

  @override
  State<JournalEditScreen> createState() => _JournalEditScreenState();
}

class _JournalEditScreenState extends State<JournalEditScreen> {
  late TextEditingController _controller;
  File? pickedImage;
  String? recordedAudioPath;
  bool isRecording = false;
  final AudioRecorder _audioRecorder = AudioRecorder();
  List<Sticker> stickers = [];

  final List<String> availableStickers = [
    'assets/stickers/happy.png',
    'assets/stickers/sad.png',
    'assets/stickers/angry.png',
    'assets/stickers/star.png',
    'assets/stickers/happy-panda.png',
    'assets/stickers/happy-cat.png',
    'assets/stickers/astonished.png',
    'assets/stickers/calm.png',
    'assets/stickers/celeb.png',
    'assets/stickers/cozy.png',
    'assets/stickers/dancing.png',
    'assets/stickers/heart-cat.png',
    'assets/stickers/hi.png',
    'assets/stickers/sad-cat.png',
    'assets/stickers/sleepy.png',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.entry.content);
    pickedImage =
        widget.entry.imagePath != null ? File(widget.entry.imagePath!) : null;
    recordedAudioPath = widget.entry.audioPath;
    stickers = List<Sticker>.from(widget.entry.stickers ?? []);
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _saveEntry() async {
    final text = _controller.text.trim();
    if (text.isEmpty &&
        pickedImage == null &&
        recordedAudioPath == null &&
        stickers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please write, record, add an image, or add a sticker before saving.'),
        ),
      );
      return;
    }

    // This is the corrected part. 'existingId' has been changed to 'id'.
    final updatedEntry = JournalEntry(
      id: widget.entry.id, // Pass existing ID to update
      content: text,
      timestamp: widget.entry.timestamp, // Keep original timestamp
      emotion: widget.entry.emotion,
      imagePath: pickedImage?.path,
      audioPath: recordedAudioPath,
      stickers: stickers,
    );

    await JournalStorage.updateEntry(updatedEntry);

    Navigator.of(context).pop();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => pickedImage = File(image.path));
  }

  Future<void> _startStopRecording() async {
    if (await _audioRecorder.isRecording()) {
      final path = await _audioRecorder.stop();
      setState(() {
        isRecording = false;
        recordedAudioPath = path;
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Recording stopped')));
      }
    } else {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final path =
            '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);

        setState(() => isRecording = true);
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Recording started')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Permission denied')));
        }
      }
    }
  }

  void _addSticker(String path) {
    setState(() {
      stickers.add(Sticker(imagePath: path, dx: 50, dy: 50));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F2),
      appBar: AppBar(
        title: const Text("Edit Journal Entry",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF568F87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  TextField(
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Edit your entry...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  if (pickedImage != null)
                    Positioned.fill(
                        child: Image.file(pickedImage!, fit: BoxFit.cover)),
                  ...stickers.map((sticker) {
                    return Positioned(
                      left: sticker.dx,
                      top: sticker.dy,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            sticker.dx += details.delta.dx;
                            sticker.dy += details.delta.dy;
                          });
                        },
                        child: Image.asset(sticker.imagePath,
                            width: 60, height: 60),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: availableStickers.map((s) {
                  return IconButton(
                    iconSize: 60,
                    icon: Image.asset(s),
                    onPressed: () => _addSticker(s),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _startStopRecording,
                  icon: Icon(isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white),
                  label: Text(isRecording ? 'Stop' : 'Record Audio',
                      style: const TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isRecording ? Colors.red : const Color(0xFF568F87),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image, color: Colors.white),
                  label: const Text('Change Image',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF568F87)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF568F87),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: _saveEntry,
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
