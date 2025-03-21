import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip_model.dart';

class TripService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch Wikipedia image based on the trip name.
  static Future<String> fetchTripImage(String tripName) async {
    final Uri url = Uri.parse(
      'https://cors-anywhere.herokuapp.com/https://en.wikipedia.org/w/api.php?action=query&prop=pageimages&format=json&pithumbsize=500&titles=$tripName',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      var pages = data['query']['pages'];
      if (pages.isNotEmpty) {
        var firstPage = pages.values.first;
        if (firstPage.containsKey('thumbnail')) {
          return firstPage['thumbnail']['source'];
        }
      }
    }
    return 'https://upload.wikimedia.org/wikipedia/commons/6/65/No-Image-Placeholder.svg';
  }

  // Add trip to Firestore with all details.
  static Future<void> addTrip(Trip trip) async {
    // Fetch the image from Wikipedia using the trip name.
    String imageUrl = await fetchTripImage(trip.name);

    await _db.collection('trips').doc(trip.id).set({
      'name': trip.name,
      'destination': trip.destination,
      'imageUrl': imageUrl,
      // Store the date as a Firestore Timestamp.
      'dateOfGoing': Timestamp.fromDate(trip.dateOfGoing),
      'location': trip.location,
      'organizerId': trip.organizerId,
      'organizerEmail': trip.organizerEmail,
      'duration': trip.duration,
      'durationUnit': trip.durationUnit,
      'teamMembers': trip.teamMembers,
    });

    print("Trip added: ${trip.name}, Destination: ${trip.destination}");
  }

  // Fetch trips from Firestore including the new fields.
  static Future<List<Trip>> fetchTrips() async {
    QuerySnapshot snapshot = await _db.collection('trips').get();

    for (var doc in snapshot.docs) {
      print("Document ID: ${doc.id}, Data: ${doc.data()}");
    }

    return snapshot.docs.map((doc) {
      var data = doc.data();

      if (data is! Map<String, dynamic>) {
        print("Error: Document ${doc.id} contains invalid data: $data");
        return null; // Skip invalid documents
      }

      try {
        return Trip(
          id: doc.id,
          name: data['name'] ?? '',
          destination: data['destination'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          dateOfGoing: data['dateOfGoing'] != null
              ? (data['dateOfGoing'] as Timestamp).toDate()
              : DateTime.now(), // Default date if missing
          location: data['location'] ?? '',
          organizerId: data['organizerId'] ?? '',
          organizerEmail: data['organizerEmail'] ?? '',
          duration: data['duration'] is int ? data['duration'] : 0,
          durationUnit: data['durationUnit'] ?? 'Days',
          teamMembers: (data['teamMembers'] is List)
              ? List<String>.from(data['teamMembers'])
              : [],
        );
      } catch (e, stacktrace) {
        print("Error parsing trip document ${doc.id}: $e");
        print(stacktrace);
        return null; // Skip problematic documents
      }
    }).whereType<Trip>().toList(); // Remove null values
  }

  static Future<void> updateTripMembers(String tripId, List<String> teamMembers) async {
    try {
      await _db.collection('trips').doc(tripId).update({
        'teamMembers': teamMembers,
      });
      print("Trip members updated successfully for trip ID: $tripId");
    } catch (e) {
      print("Error updating trip members: $e");
    }
  }
}