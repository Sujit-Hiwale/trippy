import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  static Future<List<String>> getSuggestions(String query) async {
    final Uri url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=$query');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((place) => place['display_name'].toString()).toList();
    } else {
      return [];
    }
  }
}