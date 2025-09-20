import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';

// Models
import 'models/journal_entry.dart';
import 'models/gratitude.dart';
import 'models/sticker.dart';

// Storages
import 'services/journal_storage.dart';
import 'services/gratitude_storage.dart';

// Providers
import 'providers/mood_provider.dart';

// Screens
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Hive
  await Hive.initFlutter();

try {
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(JournalEntryAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(GratitudeAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(StickerAdapter());
} catch (e) {
  print("Hive adapter registration failed: $e");
}

  await JournalStorage.init();
  await GratitudeStorage.init();

  // Run the app with Provider
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
      debugShowCheckedModeBanner: false,
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
