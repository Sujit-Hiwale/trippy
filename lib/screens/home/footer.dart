import 'package:flutter/material.dart';
import 'package:trippy/screens/home.dart';
import 'package:trippy/screens/trips/trip_listing.dart';
import 'package:trippy/screens/events.dart';
import 'package:trippy/screens/search.dart';
import '../cities/cityListing.dart';

class NavigationScreen extends StatefulWidget {
  final int initialIndex;

  const NavigationScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  late int _selectedIndex;

  final List<Widget> _pages = [
    const CityListingPage(),
    const TripSearchScreen(),
    const EventScreen(),
    const HomeScreen(),
  ];

  final List<String> _titles = [
    'Home',
    'Search',
    'Events',
    'Trips',
  ];

  final List<IconData> _icons = [
    Icons.home,
    Icons.search,
    Icons.event,
    Icons.card_travel,
  ];

  final List<String> _routes = [
    '/cities',
    '/search',
    '/events',
    '/trips',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onTap(int index) {
    if (_selectedIndex != index) {
      Navigator.pushReplacementNamed(context, _routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        items: List.generate(_pages.length, (index) {
          return BottomNavigationBarItem(
            icon: Icon(_icons[index]),
            label: _titles[index],
          );
        }),
      ),
    );
  }
}
