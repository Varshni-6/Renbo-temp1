import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'providers/mood_provider.dart';
import 'models/journal_entry.dart';
import 'models/gratitude.dart'; // 👈 import Gratitude model
import 'package:flutter/services.dart';
import 'screens/emotion_tracker.dart';
import 'screens/journal_entries.dart';
import 'screens/journal_screen.dart';
import 'services/journal_storage.dart';
import 'services/gratitude_storage.dart'; // 👈 import GratitudeStorage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await dotenv.load(fileName: ".env");

  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(JournalEntryAdapter());
  Hive.registerAdapter(GratitudeAdapter()); // 👈 register Gratitude

  // Initialize Storages
  await JournalStorage.init();
  await GratitudeStorage.init(); // 👈 initialize GratitudeStorage

  runApp(
    ChangeNotifierProvider(
      create: (context) => MoodProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Renbo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFFFF5F2),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF568F87),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
