import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'trips/trip_listing.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  void _logout() async {
    await _auth.signOut();
    setState(() {
      _user = null;
    });
    Navigator.pushReplacementNamed(context, '/');
  }

  void _handleProfileAction() {
    if (_user == null) {
      Navigator.pushNamed(context, '/login');
    } else {
      Navigator.pushNamed(context, '/profile');
    }
  }

  void _handleCreateTrip() {
    if (_user == null) {
      // Redirect to Login if not logged in
      Navigator.pushNamed(context, '/login');
    } else {
      // Redirect to Trip Creation if logged in
      Navigator.pushNamed(context, '/create');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Explore Trips"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _handleProfileAction,
          ),
          if (_user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
        ],
      ),
      body: const TripListingScreen(),
    );
  }
}
