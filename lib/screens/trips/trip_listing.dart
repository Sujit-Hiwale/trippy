import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../services/trip_service.dart';
import '../widgets/trip_card.dart';
import 'trip_creation.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class TripListingScreen extends StatefulWidget {
  const TripListingScreen({super.key});

  @override
  _TripListingScreenState createState() => _TripListingScreenState();
}

class _TripListingScreenState extends State<TripListingScreen> {
  List<Trip> trips = [];
  List<Trip> filteredTrips = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTrips();
    searchController.addListener(_filterTrips);
  }

  Future<void> _loadTrips() async {
    List<Trip> fetchedTrips = await TripService.fetchTrips();
    setState(() {
      trips = fetchedTrips;
      filteredTrips = fetchedTrips;
      isLoading = false;
    });
  }

  void _filterTrips() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredTrips = trips
          .where((trip) =>
      trip.name.toLowerCase().contains(query) ||
          trip.destination.toLowerCase().contains(query))
          .toList();
    });
  }

  void _navigateToCreateTrip() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Redirect to login if user is not signed in
      Navigator.pushNamed(context, '/login');
    } else {
      // Redirect to trip creation if user is signed in
      Navigator.pushNamed(context, '/create');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Trips',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTrips.isEmpty
                ? const Center(child: Text('No trips found'))
                : LayoutBuilder(
              builder: (context, constraints) {
                const double maxCardSize = 300; // Good for web and desktop
                int crossAxisCount = (constraints.maxWidth / maxCardSize).floor();
                if (crossAxisCount < 1) crossAxisCount = 1;

                double cardSize = constraints.maxWidth / crossAxisCount;

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1, // Ensures square card (width = height)
                  ),
                  itemCount: filteredTrips.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: cardSize,
                      height: cardSize,
                      child: TripCard(trip: filteredTrips[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateTrip,
        child: const Icon(Icons.add),
      ),
    );
  }
}
