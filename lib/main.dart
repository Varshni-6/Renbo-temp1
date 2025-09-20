import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';

import 'models/journal_entry.dart';
import 'providers/mood_provider.dart';
import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';
import 'services/journal_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();

  Hive.registerAdapter(JournalEntryAdapter());

  await JournalStorage.init();

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
