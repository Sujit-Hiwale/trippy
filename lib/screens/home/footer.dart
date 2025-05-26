import 'package:flutter/material.dart';
import 'package:trippy/screens/home.dart';
import 'package:trippy/screens/trips/trip_listing.dart';
import 'package:trippy/screens/events.dart';
import 'package:trippy/screens/search.dart';
import '../cities/cityListing.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;

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

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
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
