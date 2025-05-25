import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trippy/theme.dart';

import '../models/trip_model.dart';
import '../services/trip_service.dart';
import '../services/user_service.dart';
import '../chat/chat.dart';

class TripDetailScreen extends StatefulWidget {
  final Trip trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  _TripDetailScreenState createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late Trip trip;
  late Map<String, String?> userProfilePics = {};
  late Map<String, String?> usernames = {};

  @override
  void initState() {
    super.initState();
    trip = widget.trip;
    _fetchUserProfilePics();
  }

  Future<void> _fetchUserProfilePics() async {
    for (var member in trip.teamMembers) {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: member)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        String? profilePic = snapshot.docs.first.get('profilePic');
        String? username = snapshot.docs.first.get('username');
        setState(() {
          userProfilePics[member] = profilePic;
          usernames[member] = username;
        });
      }
    }
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

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You have successfully joined the trip!')),
          );
        }
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
    final isUserInTrip = trip.teamMembers.contains(currentUserEmail);

    return Scaffold(
      body: Stack(
        children: [
          // Bigger image section
          SizedBox(
            height: 400,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(trip.imageUrl, fit: BoxFit.cover),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  left: 20,
                  bottom: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.name,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white, size: 22),
                          const SizedBox(width: 4),
                          Text(
                            trip.destination,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              shadows: [Shadow(color: Colors.black45, blurRadius: 3)],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.62,
            minChildSize: 0.62,
            maxChildSize: 1.0,
            builder: (_, controller) => Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: controller,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.calendar_today, size: 18),
                        label: Text('Date: ${trip.dateOfGoing.toLocal().toString().split(' ')[0]}',
                            style: const TextStyle(fontSize: 13)),
                      ),
                      Chip(
                        avatar: const Icon(Icons.timelapse, size: 18),
                        label: Text('Duration: ${trip.duration} ${trip.durationUnit}',
                            style: const TextStyle(fontSize: 13)),
                      ),
                      Chip(
                        avatar: const Icon(Icons.category, size: 18),
                        label: Text('Type: ${trip.type ?? 'Adventure'}',
                            style: const TextStyle(fontSize: 13)),
                      ),

                    ],
                  ),

                  const SizedBox(height: 20),
                  Text(trip.description ?? "No description provided.",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 15)),

                  const SizedBox(height: 20),
                  isUserInTrip
                      ? ElevatedButton.icon(
                    onPressed: () => _confirmCancelTrip(context),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text("Cancel Trip"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  )
                      : ElevatedButton.icon(
                    onPressed: () => _confirmJoinTrip(context),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text("Join Trip"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text("Team Members", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  ...trip.teamMembers.map((member) {
                    final profilePic = userProfilePics[member];
                    final username = usernames[member];
                    final isCurrentUser = member == currentUserEmail;
                    final isAdmin = trip.organizerEmail == member;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: profilePic != null && profilePic.isNotEmpty
                              ? NetworkImage(profilePic)
                              : const AssetImage("assets/avatars/noAvatar.png") as ImageProvider,
                        ),
                        title: Text(
                          isCurrentUser
                              ? "${username ?? member} (You)"
                              : isAdmin
                              ? "${username ?? member} (Admin)"
                              : username ?? member,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}