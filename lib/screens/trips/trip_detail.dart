import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/trip_model.dart';
import '../services/trip_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_button.dart';

class TripDetailScreen extends StatefulWidget {
  final Trip trip;
  const TripDetailScreen({super.key, required this.trip});

  @override
  _TripDetailScreenState createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late Trip trip;

  @override
  void initState() {
    super.initState();
    trip = widget.trip;
  }

  Future<void> _confirmJoinTrip(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    bool confirmed = await _showJoinDialog(context, "Do you want to join this trip?");
    if (confirmed) {
      if (!trip.teamMembers.contains(user.email)) {
        setState(() {
          trip.teamMembers.add(user.email!);
        });
        await TripService.updateTripMembers(trip.id, trip.teamMembers);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have successfully joined the trip!')),
        );
      }
    }
  }

  Future<void> _confirmCancelTrip(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    bool confirmed = await _showJoinDialog(context, "Do you want to cancel your participation?");
    if (confirmed) {
      setState(() {
        trip.teamMembers.remove(user.email);
      });
      await TripService.updateTripMembers(trip.id, trip.teamMembers);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have left the trip.')),
        );
      }
    }
  }

  Future<bool> _showJoinDialog(BuildContext context, String message) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Action'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final currentUserEmail = user?.email;
    final bool isUserInTrip = user != null && trip.teamMembers.contains(user.email);

    return Scaffold(
      appBar: AppBar(title: Text(trip.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  trip.imageUrl,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(trip.destination, style: const TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 20),

                  if (!isUserInTrip)
                    CustomButton(text: 'Go', onPressed: () => _confirmJoinTrip(context), textColor: Colors.blue,),

                  if (isUserInTrip)
                    CustomButton(text: 'Cancel', onPressed: () => _confirmCancelTrip(context), textColor: Colors.red),

                  const SizedBox(height: 20),
                  const Text('Team Members:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                  Column(
                    children: trip.teamMembers.map((member) {
                      final bool isCurrentUser = member == currentUserEmail;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(UserService.getUserProfileImage(member)),
                          child: member == trip.organizerEmail ? const Icon(Icons.star, color: Colors.yellow) : null,
                        ),
                        title: Text(
                          isCurrentUser ? "$member (Me)" : member,
                          style: TextStyle(fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
