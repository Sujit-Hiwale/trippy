import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/trip_model.dart';
import '../trips/trip_review.dart';

class TripCreationScreen extends StatefulWidget {
  final String? initialName;
  final String? initialDestination;
  final String? initialImageUrl;
  final String? initialDescription;

  const TripCreationScreen({
    super.key,
    this.initialName,
    this.initialDestination,
    this.initialImageUrl,
    this.initialDescription,
  });

  @override
  _TripCreationScreenState createState() => _TripCreationScreenState();
}

class _TripCreationScreenState extends State<TripCreationScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController destinationController;
  late TextEditingController dateController;
  late TextEditingController durationController;
  late TextEditingController imageUrlController;
  late TextEditingController descriptionController;

  String durationUnit = 'Days';
  String? selectedType;

  final String defaultImageUrl =
      'https://static.vecteezy.com/system/resources/thumbnails/025/871/495/small/travel-destination-background-and-template-design-with-travel-destinations-and-famous-landmarks-and-attractions-for-tourism-let-s-go-travel-illustration-vector.jpg';

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName ?? '');
    destinationController = TextEditingController(text: widget.initialDestination ?? '');
    dateController = TextEditingController();
    durationController = TextEditingController();
    imageUrlController = TextEditingController(text: widget.initialImageUrl ?? '');
    descriptionController = TextEditingController(text: widget.initialDescription ?? '');
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

  bool _isValidImageUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.isAbsolute) return false;

    final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];

    final path = uri.path.toLowerCase();
    return validExtensions.any((ext) => path.endsWith('.$ext'));
  }


  void _saveTrip() async {
    if (_formKey.currentState!.validate()) {
      String organizerEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      String imageUrl = imageUrlController.text.trim().isEmpty
          ? defaultImageUrl
          : imageUrlController.text.trim();

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
        description: descriptionController.text.trim(),
        type: selectedType!,
      );

      final confirmed = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TripReviewScreen(trip: trip)),
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
    final theme = Theme.of(context);
    const inputSpacing = SizedBox(height: 16);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background/init.jpg', fit: BoxFit.cover),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        "Plan Your Trip ✈️",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Name
                      TextFormField(
                        controller: nameController,
                        decoration: _inputDecoration("Trip Name", Icons.card_travel),
                        validator: (value) =>
                        (value == null || value.isEmpty) ? 'Enter trip name' : null,
                      ),
                      inputSpacing,

                      // Destination
                      TextFormField(
                        controller: destinationController,
                        decoration: _inputDecoration("Destination", Icons.location_on),
                        validator: (value) =>
                        (value == null || value.isEmpty) ? 'Enter destination' : null,
                      ),
                      inputSpacing,

                      // Date
                      TextFormField(
                        controller: dateController,
                        readOnly: true,
                        onTap: _selectDate,
                        decoration: _inputDecoration("Date of Going", Icons.date_range),
                        validator: (value) =>
                        (value == null || value.isEmpty) ? 'Select a date' : null,
                      ),
                      inputSpacing,

                      // Duration + Unit
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: durationController,
                              decoration: _inputDecoration("Duration", Icons.timelapse),
                              keyboardType: TextInputType.number,
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
                            style: const TextStyle(color: Colors.teal),
                            borderRadius: BorderRadius.circular(12),
                            dropdownColor: Colors.white,
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

                      // Description
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 4,
                        decoration: _inputDecoration("Description", Icons.description),
                        validator: (value) =>
                        (value == null || value.isEmpty) ? 'Enter description' : null,
                      ),
                      inputSpacing,

                      // Type
                      DropdownButtonFormField<String>(
                        decoration: _inputDecoration("Select Trip Type", Icons.category),
                        value: selectedType,
                        items: ['Adventure', 'Fun', 'Cultural', 'Business', 'Leisure']
                            .map((type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedType = value;
                          });
                        },
                        validator: (value) => value == null ? 'Select a trip type' : null,
                      ),
                      inputSpacing,

                      // Image URL
                      TextFormField(
                        controller: imageUrlController,
                        decoration: _inputDecoration(
                          "Image URL (optional)",
                          Icons.image,
                        ),
                        keyboardType: TextInputType.url,
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          if (!_isValidImageUrl(value)) return 'Enter a valid image URL';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text(
                            "Create Trip",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _saveTrip,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.teal.shade700),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.teal.shade700),
      ),
    );
  }
}
