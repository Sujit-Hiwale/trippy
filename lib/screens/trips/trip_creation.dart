import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/trip_model.dart';
import '../services/trip_service.dart';
import '../services/location_service.dart';
import '../trips/trip_review.dart';

class TripCreationScreen extends StatefulWidget {
  const TripCreationScreen({super.key});

  @override
  _TripCreationScreenState createState() => _TripCreationScreenState();
}

class _TripCreationScreenState extends State<TripCreationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  String durationUnit = 'Days';

  // Default image URL if user leaves the field empty
  final String defaultImageUrl =
      'https://static.vecteezy.com/system/resources/thumbnails/025/871/495/small/travel-destination-background-and-template-design-with-travel-destinations-and-famous-landmarks-and-attractions-for-tourism-let-s-go-travel-illustration-vector.jpg'; // <-- replace with your actual default image URL

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

  bool _isValidImageUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isAbsolute)) return false;
    final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return validExtensions.any((ext) => url.toLowerCase().endsWith('.$ext'));
  }

  void _saveTrip() async {
    if (_formKey.currentState!.validate()) {
      String organizerEmail = FirebaseAuth.instance.currentUser?.email ?? '';

      String imageUrl = imageUrlController.text.trim();
      if (imageUrl.isEmpty) {
        imageUrl = defaultImageUrl;
      }

      Trip trip = Trip(
        id: DateTime.now().toString(),
        name: nameController.text.trim(),
        destination: destinationController.text.trim(),
        imageUrl: imageUrl,
        dateOfGoing: DateTime.parse(dateController.text),
        location: destinationController.text.trim(),
        organizerId: FirebaseAuth.instance.currentUser?.uid ?? '',
        duration: int.parse(durationController.text),
        organizerEmail: organizerEmail,
        durationUnit: durationUnit,
        teamMembers: [organizerEmail],
      );

      // Navigate to TripReviewScreen
      final confirmed = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TripReviewScreen(trip: trip),
        ),
      );

      if (confirmed == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip successfully created!')),
        );
        Navigator.pop(context, trip);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputSpacing = const SizedBox(height: 16);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Trip')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Trip Name',
                  prefixIcon: Icon(Icons.card_travel_outlined),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) =>
                (value == null || value.isEmpty) ? 'Enter trip name' : null,
              ),
              inputSpacing,
              TextFormField(
                controller: destinationController,
                decoration: const InputDecoration(
                  labelText: 'Destination',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) =>
                (value == null || value.isEmpty) ? 'Enter destination' : null,
              ),
              inputSpacing,
              TextFormField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: 'Date of Going',
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.date_range),
                    onPressed: _selectDate,
                    tooltip: 'Pick Date',
                  ),
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (value) =>
                (value == null || value.isEmpty) ? 'Select a date' : null,
              ),
              inputSpacing,
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                        prefixIcon: Icon(Icons.timelapse_outlined),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter duration';
                        }
                        final n = int.tryParse(value);
                        if (n == null || n <= 0) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
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
              inputSpacing,
              TextFormField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  prefixIcon: Icon(Icons.image_outlined),
                  hintText: 'Enter a valid image URL (e.g. .jpg, .png) or leave empty',
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    // It's optional, so no error here
                    return null;
                  }
                  if (!_isValidImageUrl(value)) {
                    return 'Enter a valid image URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: Icon(
                    Icons.check_circle_outline,
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9), // slightly less transparent
                  ),
                  label: Text(
                    'Create Trip',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                    ),
                  ),
                  onPressed: _saveTrip,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}