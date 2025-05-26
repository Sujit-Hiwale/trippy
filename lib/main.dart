import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trippy/screens/auth/login.dart';
import 'package:trippy/screens/cities/cityListing.dart';
import 'package:trippy/screens/trips/trip_creation.dart';
import 'screens/auth/profile.dart';
import 'screens/auth/signup.dart';
import 'screens/home.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'screens/home/start.dart';
import 'screens/cities/cityListing.dart';
import 'screens/cities/home.dart';
import 'screens/home/footer.dart';
import 'screens/auth/connections.dart';

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
      initialRoute: '/init',
      routes: {
        '/': (context) => const NavigationScreen(),
        '/trips': (context) => const HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/init': (context) => StartPage(),
        '/cities': (context) => const CityListingPage(),
        '/connections': (context) => const ConnectionsScreen(),
      },
      onGenerateRoute: (settings) {
        final user = FirebaseAuth.instance.currentUser;
        if (settings.name == '/create' || settings.name == '/profile') {
          if (user == null) {
            return MaterialPageRoute(builder: (context) => LoginScreen());
          }
        }
        if (settings.name == '/create') {
          final args = settings.arguments as Map<String, dynamic>?;

          return MaterialPageRoute(
            builder: (context) => TripCreationScreen(
              initialName: args?['initialName'] ?? '',
              initialDestination: args?['initialDestination'] ?? '',
              initialImageUrl: args?['initialImageUrl'] ?? '',
              initialDescription: args?['initialDescription'] ?? '',
            ),
          );
        }
        if (settings.name == '/profile') {
          return MaterialPageRoute(builder: (context) => ProfileScreen());
        }
        if (settings.name == '/home') {
          return MaterialPageRoute(builder: (context) => const HomeScreen());
        }
        return null;
      },
    );
  }
}