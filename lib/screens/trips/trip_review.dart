import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/trip_model.dart';
import '../services/trip_service.dart';

class TripReviewScreen extends StatefulWidget {
  final Trip trip;

  const TripReviewScreen({super.key, required this.trip});

  @override
  _TripReviewScreenState createState() => _TripReviewScreenState();
}

class _TripReviewScreenState extends State<TripReviewScreen> {
  void _confirmTrip() async {
    await TripService.addTrip(widget.trip);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trip successfully added!')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Trip')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trip Name: ${widget.trip.name}', style: const TextStyle(fontSize: 18)),
            Text('Destination: ${widget.trip.destination}', style: const TextStyle(fontSize: 18)),
            Text('Date of Going: ${DateFormat('yyyy-MM-dd').format(widget.trip.dateOfGoing)}',
                style: const TextStyle(fontSize: 18)),
            Text('Duration: ${widget.trip.duration} ${widget.trip.durationUnit}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Edit'),
                ),
                ElevatedButton(
                  onPressed: _confirmTrip,
                  child: const Text('Confirm & Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
