import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Added Firebase Core
import 'firebase_options.dart';
import 'welcome_screen.dart';

void main() async {
  // Required to initialize Firebase before the app runs
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const TeaPlusApp());
}

class TeaPlusApp extends StatelessWidget {
  const TeaPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeaPlus',
      debugShowCheckedModeBanner: false,

      // Defining the theme based on the UI design
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF2D5A27), // Deep Tea Green
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D5A27),
          primary: const Color(0xFF2D5A27),
        ),

        // Customizing the text fields to look like the UI design
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2D5A27), width: 2),
          ),
          labelStyle: const TextStyle(color: Colors.grey),
          // Added error styles for the validation messages you requested
          errorStyle: const TextStyle(color: Colors.red),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),

        // Styling buttons to match the "Get Started" and "Login" buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D5A27),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      // Starting Page
      home: const WelcomeScreen(),
    );
  }
}