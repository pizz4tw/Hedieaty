import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider package
import 'splash_screen.dart';
import 'views/login.dart'; // Import the login page
import 'views/home_page.dart'; // Import the home page
import 'viewmodels/profile_view_model.dart'; // Import ProfileViewModel

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully!');
  } catch (e, stackTrace) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('Stack trace: $stackTrace');
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileViewModel()), // Add ProfileViewModel
      ],
      child: HedieatyApp(),
    ),
  );
}

class HedieatyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) => SplashScreen(), // Initial screen
        '/login': (context) => LoginScreen(), // Register the login route
        '/home': (context) => HomePage(), // Register the home route
      },
    );
  }
}
