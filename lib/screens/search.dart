import 'package:flutter/material.dart';
import 'package:trippy/screens/models/trip_model.dart';
import 'cities/cityDetails.dart';
import 'models/city.dart';
import 'package:trippy/screens/services/trip_service.dart';
import 'services/city_service.dart';
import 'package:trippy/screens/trips/trip_detail.dart';

class TripSearchScreen extends StatefulWidget {
  const TripSearchScreen({super.key});

  @override
  State<TripSearchScreen> createState() => _TripSearchScreenState();
}

class _TripSearchScreenState extends State<TripSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Trip> _allTrips = [];
  List<Trip> _filteredTrips = [];

  List<City> _allCities = [];
  List<City> _filteredCities = [];

  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadData() async {
    final trips = await TripService.fetchTrips();
    final cities = await CityService.fetchAllCities();

    setState(() {
      _allTrips = trips;
      _filteredTrips = trips;
      _allCities = cities;
      _filteredCities = [];
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredTrips = _allTrips;
        _filteredCities = [];
        _isSearching = false;
      });
    } else {
      setState(() {
        _isSearching = true;
        _filteredTrips = _allTrips.where((trip) {
          return trip.name.toLowerCase().contains(query) ||
              trip.destination.toLowerCase().contains(query);
        }).toList();

        _filteredCities = _allCities.where((city) {
          return city.name.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hasResults = _filteredTrips.isNotEmpty || _filteredCities.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Trips'),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by trip or city...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : !_isSearching
                  ? _buildTripList()
                  : hasResults
                  ? _buildSearchResults()
                  : Center(
                child: Text(
                  'No results found.',
                  style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripList() {
    return ListView.separated(
      itemCount: _filteredTrips.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final trip = _filteredTrips[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              trip.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(trip.name),
          subtitle: Text(trip.destination),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TripDetailScreen(trip: trip),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchResults() {
    final tripWidgets = _filteredTrips.map(_buildTripTile).toList();
    final cityWidgets = _filteredCities.map(_buildCityTile).toList();

    return ListView(
      children: [
        if (tripWidgets.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: Text(
              'Trips',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...tripWidgets,
        ],
        if (cityWidgets.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: Text(
              'Cities',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...cityWidgets,
        ],
      ],
    );
  }

  Widget _buildTripTile(Trip trip) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          trip.imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(trip.name),
      subtitle: Text(trip.destination),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TripDetailScreen(trip: trip)),
        );
      },
    );
  }

  Widget _buildCityTile(City city) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          city.imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(city.name),
      subtitle: const Text('City'),
      trailing: const Icon(Icons.location_city),
      onTap: () {
        // Navigate to city details page on tap
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CityDetailsPage(city: city),
          ),
        );
      },
    );
  }
}
