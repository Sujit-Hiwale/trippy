import 'package:flutter/material.dart';
import '../models/trip_model.dart';
import '../services/trip_service.dart';
import '../widgets/trip_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TripListingScreen extends StatefulWidget {
  const TripListingScreen({super.key});

  @override
  _TripListingScreenState createState() => _TripListingScreenState();
}

class _TripListingScreenState extends State<TripListingScreen> {
  List<Trip> trips = [];
  Map<String, List<Trip>> groupedTrips = {};
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
      _groupTrips();
      isLoading = false;
    });
  }

  void _groupTrips() {
    groupedTrips.clear();
    String query = searchController.text.toLowerCase();

    for (var trip in trips) {
      // Filter trips by search query
      if (query.isNotEmpty &&
          !trip.name.toLowerCase().contains(query) &&
          !trip.destination.toLowerCase().contains(query)) {
        continue;
      }

      // Group by trip typer
      groupedTrips.putIfAbsent(trip.type, () => []);
      groupedTrips[trip.type]!.add(trip);
    }
  }

  void _filterTrips() {
    setState(() {
      _groupTrips();
    });
  }

  void _navigateToCreateTrip() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.pushNamed(context, '/login');
    } else {
      Navigator.pushNamed(context, '/create');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar
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
          // Trip List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : groupedTrips.isEmpty
                ? const Center(child: Text('No trips found'))
                : ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: groupedTrips.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Text(
                        entry.key, // Trip type
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Horizontal Scroll Row
                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: entry.value.length,
                        itemBuilder: (context, index) {
                          final trip = entry.value[index];
                          return Container(
                            width: 200,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: TripCard(trip: trip),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
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
