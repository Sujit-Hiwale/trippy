import 'package:flutter/material.dart';
import '../models/city.dart';
import 'top_cities.dart';

class CityHome extends StatelessWidget {
  const CityHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top Cities')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TopCitiesScrollView(),
      ),
    );
  }
}
