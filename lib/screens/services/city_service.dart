import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/city.dart'; // Adjust this import path if needed

class CityService {
  static final _citiesRef = FirebaseFirestore.instance.collection('cities');

  // Fetch all cities
  static Future<List<City>> fetchAllCities() async {
    try {
      final snapshot = await _citiesRef.get();
      return snapshot.docs.map((doc) {
        return City.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching cities: $e');
      return [];
    }
  }

  // Search cities by name
  static Future<List<City>> searchCitiesByName(String query) async {
    try {
      final snapshot = await _citiesRef.get();
      return snapshot.docs
          .map((doc) => City.fromFirestore(doc.data(), doc.id))
          .where((city) =>
          city.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      print('Error searching cities: $e');
      return [];
    }
  }

  // Fetch cities sorted by travel score (descending)
  static Future<List<City>> fetchCitiesByTravelScore() async {
    try {
      final snapshot = await _citiesRef.orderBy('travelScore', descending: true).get();
      return snapshot.docs.map((doc) {
        return City.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Error fetching sorted cities: $e');
      return [];
    }
  }
}
