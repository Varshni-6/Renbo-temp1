import 'dart:math';
import 'package:flutter/material.dart';
import 'package:renbo/models/gratitude.dart';
import 'package:renbo/services/gratitude_storage.dart';
import 'package:renbo/utils/theme.dart';
import 'package:renbo/widgets/gratitude_bubbles_widget.dart';

class GratitudeBubblesScreen extends StatefulWidget {
  const GratitudeBubblesScreen({super.key});

  @override
  State<GratitudeBubblesScreen> createState() => _GratitudeBubblesScreenState();
}

class _GratitudeBubblesScreenState extends State<GratitudeBubblesScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  List<Gratitude> _gratitudes = [];
  late final AnimationController _animationController;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _loadGratitudes();
    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _loadGratitudes() {
    setState(() {
      _gratitudes = GratitudeStorage.gratitudes;
    });
  }

  void _addGratitude() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      final gratitude = Gratitude(text: text, timestamp: DateTime.now());
      GratitudeStorage.addGratitude(gratitude);
      _controller.clear();
      _loadGratitudes();
    }
  }

  void _showAddGratitudeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add a Gratitude',
            style: TextStyle(color: AppTheme.darkGray)),
        content: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'What are you grateful for today?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: AppTheme.mediumGray),
            ),
          ),
          onSubmitted: (_) {
            _addGratitude();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.mediumGray)),
          ),
          ElevatedButton(
            onPressed: () {
              _addGratitude();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Gratitude Bubbles',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGratitudeDialog,
        backgroundColor: const Color.fromARGB(255, 129, 167, 199),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Stack(
        children: [
          if (_gratitudes.isEmpty)
            const Center(
              child: Text(
                'No gratitudes yet. Add one to see it float!',
                style: TextStyle(fontSize: 16, color: AppTheme.mediumGray),
                textAlign: TextAlign.center,
              ),
            ),
          ..._gratitudes.map((gratitude) {
            final double size = 60.0 + gratitude.text.length * 1.5;
            final double xOffset = _random.nextDouble() * 200 - 100;
            final double yOffset = _random.nextDouble() * 200 - 100;

            return GratitudeBubble(
              gratitude: gratitude,
              bubbleSize: size,
              animation: _animationController,
              xOffset: xOffset,
              yOffset: yOffset,
            );
          }).toList(),
        ],
      ),
    );
  }
}
