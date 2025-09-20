import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/journal_storage.dart';
import 'journal_entries.dart';
import '../models/journal_entry.dart';

class JournalScreen extends StatefulWidget {
  final String emotion;
  const JournalScreen({Key? key, required this.emotion}) : super(key: key);

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _controller = TextEditingController();
  File? pickedImage;
  String? recordedAudioPath;
  bool isRecording = false;
  final _audioRecorder = AudioRecorder();
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void dispose() {
    _controller.dispose();
    _audioRecorder.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _saveEntry() {
    final text = _controller.text.trim();
    if (text.isEmpty && pickedImage == null && recordedAudioPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please write, record, or add an image before saving.')),
      );
      return;
    }

    // Correct instantiation using the constructor with named parameters.
    final entry = JournalEntry(
      content: text,
      timestamp: DateTime.now(),
      emotion: widget.emotion,
      imagePath: pickedImage?.path,
      audioPath: recordedAudioPath,
    );

    JournalStorage.addEntry(entry);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const JournalEntriesScreen()),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        pickedImage = File(image.path);
      });
    }
  }

  Future<void> _startStopRecording() async {
    if (isRecording) {
      final path = await _audioRecorder.stop();
      setState(() {
        isRecording = false;
        if (path != null) {
          recordedAudioPath = path;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio recording stopped and saved.')),
      );
    } else {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/${DateTime.now().toIso8601String()}.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );

        setState(() {
          isRecording = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording started...')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Permission to record audio not granted.')),
        );
      }
    }
  }

  Future<void> _startListening() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'listening') {
          setState(() => _isListening = true);
        } else {
          setState(() => _isListening = false);
        }
      },
    );
    if (available) {
      _speechToText.listen(
        onResult: (result) {
          _controller.text = result.recognizedWords;
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Speech recognition not available."),
        ),
      );
    }
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  Future<void> _speakText() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.speak(_controller.text);
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
                color: Color(0xFF064232),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
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
            ),
            if (pickedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Image.file(
                  pickedImage!,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            if (recordedAudioPath != null)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Audio recorded.',
                    style: TextStyle(color: Colors.green)),
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
                    backgroundColor: const Color(0xFF568F87),
                  ),
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
                    backgroundColor:
                        _isListening ? Colors.blue : const Color(0xFF568F87),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _speakText,
                  icon: const Icon(Icons.volume_up, color: Colors.white),
                  label: const Text('Read Aloud',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF568F87),
                  ),
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
                  borderRadius: BorderRadius.circular(18),
                ),
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
