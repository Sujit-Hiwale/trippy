import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trippy/screens/auth/login.dart';
import 'package:trippy/screens/trips/trip_creation.dart';
import 'screens/auth/profile.dart';
import 'screens/auth/signup.dart';
import 'screens/home.dart';
import 'firebase_options.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trippy',
      //theme: ThemeData(primarySwatch: Colors.blue),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/create' : (context) => TripCreationScreen(),
        '/profile': (context) => ProfileScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          return MaterialPageRoute(builder: (context) => const HomeScreen());
        }
        return null;
      },
    );
  }
}