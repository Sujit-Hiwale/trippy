import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/trip_model.dart';
import '../services/trip_service.dart';
import '../services/location_service.dart';
import 'package:intl/intl.dart';

import 'trip_review.dart';

class TripCreationScreen extends StatefulWidget {
  const TripCreationScreen({super.key});

  @override
  _TripCreationScreenState createState() => _TripCreationScreenState();
}

class _TripCreationScreenState extends State<TripCreationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  String durationUnit = 'Days';
  List<String> locationSuggestions = [];

  void _fetchLocationSuggestions(String query) async {
    if (query.isEmpty) return;
    List<String> suggestions = await LocationService.getSuggestions(query);
    setState(() {
      locationSuggestions = suggestions.take(5).toList(); // Limit suggestions
    });
  }

  void _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _saveTrip() async {
    if (nameController.text.isEmpty ||
        destinationController.text.isEmpty ||
        dateController.text.isEmpty ||
        durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    String organizerEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    
    Trip trip = Trip(
      id: DateTime.now().toString(),
      name: nameController.text,
      destination: destinationController.text,
      imageUrl: '', // To be fetched later
      dateOfGoing: DateTime.parse(dateController.text),
      location: destinationController.text,
      organizerId: FirebaseAuth.instance.currentUser?.uid ?? '',
      duration: int.parse(durationController.text),
      organizerEmail: organizerEmail,
      durationUnit: durationUnit,
      teamMembers: [organizerEmail],
    );

    // Navigate to the Trip Review Screen before saving
    final confirmed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripReviewScreen(trip: trip),
      ),
    );

    // Only save if user confirms
    if (confirmed == true) {
      await TripService.addTrip(trip);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip successfully created!')),
      );
      Navigator.pop(context, trip); // Go back after saving
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Trip')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Trip Name'),
              ),
              TextField(
                controller: destinationController,
                decoration: const InputDecoration(labelText: 'Destination'),
                onChanged: _fetchLocationSuggestions,
              ),
              if (locationSuggestions.isNotEmpty)
                SizedBox(
                  height: 200, // Prevent overflow
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: locationSuggestions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(locationSuggestions[index]),
                        onTap: () {
                          setState(() {
                            destinationController.text = locationSuggestions[index];
                            locationSuggestions.clear();
                          });
                        },
                      );
                    },
                  ),
                ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Date of Going',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _selectDate,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: durationController,
                      decoration: const InputDecoration(labelText: 'Duration'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: durationUnit,
                    items: ['Days', 'Hours'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        durationUnit = newValue!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveTrip,
                child: const Text('Create Trip'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}