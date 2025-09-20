import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../services/journal_storage.dart';
import '../models/journal_entry.dart';
import '../models/sticker.dart';
import 'journal_entries.dart';

class JournalScreen extends StatefulWidget {
  final String emotion;
  const JournalScreen({Key? key, required this.emotion}) : super(key: key);

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _controller = TextEditingController();
  final AudioRecorder _audioRecorder = AudioRecorder(); // Use AudioRecorder

  File? pickedImage;
  String? recordedAudioPath;
  bool isRecording = false;

  final SpeechToText _speechTotext = SpeechToText();
  bool _isListening = false;
  final FlutterTts _flutterTts = FlutterTts();

  // Stickers
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
  void dispose() {
    _controller.dispose();
    _flutterTts.stop();
    _audioRecorder.dispose(); // Dispose the recorder instance
    super.dispose();
  }

  // Save journal entry
  void _saveEntry() {
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

    final entry = JournalEntry(
      content: text,
      timestamp: DateTime.now(),
      emotion: widget.emotion,
      imagePath: pickedImage?.path,
      audioPath: recordedAudioPath,
      stickers: stickers
          .map((s) => Sticker(imagePath: s.imagePath, dx: s.dx, dy: s.dy))
          .toList(),
    );

    JournalStorage.addEntry(entry);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => JournalEntriesPage()),
    );
  }

  // Pick image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => pickedImage = File(image.path));
    }
  }

  // Audio recording - UPDATED
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

  // Speech-to-text
  Future<void> _startListening() async {
    bool available = await _speechTotext.initialize(
      onStatus: (status) {
        if (mounted) {
          setState(() => _isListening = status == 'listening');
        }
      },
    );
    if (available) {
      _speechTotext.listen(onResult: (result) {
        if (mounted) {
          _controller.text = result.recognizedWords;
        }
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Speech recognition not available.")),
        );
      }
    }
  }

  Future<void> _stopListening() async {
    await _speechTotext.stop();
    if (mounted) {
      setState(() => _isListening = false);
    }
  }

  // Text-to-speech
  Future<void> _speakText() async {
    if (_controller.text.isNotEmpty) {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.speak(_controller.text);
    }
  }

  // Add sticker
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
        backgroundColor: const Color(0xFF568F87),
        title: Text("Journaling - ${widget.emotion}",
            style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            const Text(
              "Write down your thoughts:",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF064232)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Stack(
                children: [
                  // TextField
                  TextField(
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Start writing here...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  // Image
                  if (pickedImage != null)
                    Positioned.fill(
                        child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Image.file(pickedImage!, fit: BoxFit.cover),
                    )),
                  // Stickers
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
            // Sticker picker
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
                  label: Text(isRecording ? 'Stop Recording' : 'Voice Journal',
                      style: const TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isRecording ? Colors.red : const Color(0xFF568F87),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image, color: Colors.white),
                  label: const Text('Add Image',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF568F87)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isListening ? _stopListening : _startListening,
                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic,
                      color: Colors.white),
                  label: Text(_isListening ? 'Stop STT' : 'Start STT',
                      style: const TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _isListening
                          ? Colors.blue
                          : const Color(0xFF568F87)),
                ),
                ElevatedButton.icon(
                  onPressed: _speakText,
                  icon: const Icon(Icons.volume_up, color: Colors.white),
                  label: const Text('Read Aloud',
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
              child: const Text("Save Entry"),
            ),
          ],
        ),
      ),
    );
  }
}