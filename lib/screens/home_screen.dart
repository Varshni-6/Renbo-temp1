import 'package:flutter/material.dart';
import 'package:renbo/api/gemini_service.dart'; // Make sure to import your service
import 'package:renbo/utils/theme.dart';
import 'package:renbo/utils/constants.dart';
import 'package:renbo/screens/chat_screen.dart';
import 'package:renbo/screens/meditation_screen.dart';
import 'package:renbo/screens/emotion_tracker.dart';
import 'package:renbo/screens/hotlines_screen.dart';
import 'package:renbo/screens/gratitude_bubbles_screen.dart'; // Import the new screen
import 'package:renbo/widgets/mood_card.dart';
import 'package:renbo/screens/stress_tap_game.dart';

// 1. CONVERTED TO A STATEFUL WIDGET
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 2. STATE VARIABLES TO HOLD THE THOUGHT AND LOADING STATE
  final GeminiService _geminiService = GeminiService();
  String _thoughtOfTheDay = "Loading a fresh thought for you...";
  bool _isLoadingThought = true;

  // 3. FETCH THE THOUGHT WHEN THE SCREEN IS FIRST BUILT
  @override
  void initState() {
    super.initState();
    _fetchThought();
  }

  void _fetchThought() async {
    try {
      final thought = await _geminiService.generateThoughtOfTheDay();
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          _thoughtOfTheDay = thought;
          _isLoadingThought = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _thoughtOfTheDay =
              "Kindness is a gift everyone can afford to give."; // Fallback
          _isLoadingThought = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            color: AppTheme.darkGray,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good Afternoon, ${AppConstants.initialUsername}!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGray,
                ),
              ),
              const SizedBox(height: 16),
              // 4. UPDATED MOODCARD TO USE THE STATE VARIABLE
              // Note: We remove 'const' because the content is now dynamic
              MoodCard(
                title: 'Thought of the day',
                content: _thoughtOfTheDay,
                image: 'assets/lottie/axolotl.json',
              ),
              const SizedBox(height: 16),
              _buildMainButtons(context),
              const SizedBox(height: 16),
              _buildWellnessPond(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildButton(
              context,
              icon: Icons.edit_note,
              label: 'Journal',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EmotionTrackerScreen()),
              ),
            ),
            const SizedBox(width: 16),
            _buildButton(
              context,
              icon: Icons.chat_bubble_outline,
              label: 'Chat with Ren',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              ),
            ),
            const SizedBox(width: 16),
            _buildButton(
              context,
              icon: Icons.headphones_outlined,
              label: 'Meditation',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MeditationScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildButton(
              context,
              icon: Icons.phone_in_talk,
              label: 'Hotlines',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HotlinesScreen()),
              ),
            ),
            const SizedBox(width: 16),
            _buildButton(
              context,
              icon: Icons.videogame_asset_outlined,
              label: 'Game',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RelaxGame()),
              ),
            ),
            const SizedBox(width: 16),
            _buildButton(
              context,
              icon: Icons.favorite_border,
              label: 'Gratitudes',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const GratitudeBubblesScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                Icon(icon, size: 40, color: AppTheme.primaryColor),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWellnessPond() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.secondaryColor),
      ),
      child: const Row(
        children: [
          Icon(Icons.spa, size: 40, color: AppTheme.secondaryColor),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wellness Pond',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                Text(
                  'You\'re not alone! See what others are doing.',
                  style: TextStyle(color: AppTheme.darkGray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
