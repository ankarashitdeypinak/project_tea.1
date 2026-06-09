import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth ইমপোর্ট করা হলো
import 'firebase_options.dart';
import 'welcome_screen.dart';
import 'home_page.dart'; // HomePage ইমপোর্ট করা হলো

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

      // starting page হিসেবে AuthWrapper সেট করা হলো যা সেশন চেক করবে
      home: const AuthWrapper(),
    );
  }
}

// লগইন সেশন অটো-চেক করার জন্য রিয়েল-টাইম র্যাপার উইজেট
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // ইউজারের লগইন স্টেট পর্যবেক্ষণ করে
      builder: (context, snapshot) {
        // ফায়ারবেস ডেটা কানেক্ট বা লোড হতে সময় নিলে প্রোগ্রেস বার দেখাবে
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D5A27)),
              ),
            ),
          );
        }

        // ইউজার যদি লগইন করা থাকে এবং তার ইমেইল ভেরিফাইড থাকে, তবে সরাসরি HomePage
        if (snapshot.hasData && snapshot.data!.emailVerified) {
          return const HomePage();
        }

        // ইউজার লগইন না থাকলে অথবা নতুন হলে WelcomeScreen দেখাবে
        return const WelcomeScreen();
      },
    );
  }
}