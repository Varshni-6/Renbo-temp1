import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart'; // Add this
import 'package:firebase_auth/firebase_auth.dart'; // Add this
import 'utils/theme.dart';
import 'app.dart';
import 'providers/mood_provider.dart';
import 'models/journal_entry.dart';
import 'package:flutter/services.dart';
import 'screens/emotion_tracker.dart';
import 'screens/home_screen.dart';
import 'screens/journal_entries.dart';
import 'screens/journal_screen.dart';
import 'firebase_options.dart'; // Add this
import 'screens/auth_page.dart'; // Add this

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await dotenv.load(fileName: ".env");

  // Initialize Firebase first
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  Hive.registerAdapter(JournalEntryAdapter());
  await Hive.openBox<JournalEntry>('journalEntries');

  runApp(
    ChangeNotifierProvider(
      create: (context) => MoodProvider(),
      child: const AuthWrapper(),
    ),
  );
}

// A new widget to handle the authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Renbo',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      // Use a StreamBuilder to listen for auth state changes
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            if (user == null) {
              // User is not signed in, show the AuthPage
              return const AuthPage();
            }
            // User is signed in, show the HomeScreen
            return const HomeScreen();
          }
          // Show a loading indicator while checking the auth state
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}