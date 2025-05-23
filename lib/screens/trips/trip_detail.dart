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
    _fetchUserProfilePics(); // Fetch profile pictures on init
  }

  // Fetch profile pictures and usernames for all team members
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

  // User joining trip confirmation
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

  // User canceling trip confirmation
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

  // Reusable confirmation dialog
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
      appBar: AppBar(
        title: Text(trip.name),
        actions: isUserInTrip
            ? [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TripChatScreen(tripName: trip.name),
                ),
              );
            },
          )
        ]
            : [],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip image
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  trip.imageUrl,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Trip details and actions
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(trip.destination, style: const TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 20),

                  // Join/Cancel Button
                  if (!isUserInTrip)
                    ElevatedButton(
                      onPressed: () => _confirmJoinTrip(context),
                      style: AppTheme.detailButtonStyle,
                      child: const Text('Go'),
                    ),
                  if (isUserInTrip)
                    ElevatedButton(
                      onPressed: () => _confirmCancelTrip(context),
                      style: AppTheme.detailButtonStyle.copyWith(
                        foregroundColor: WidgetStateProperty.all(Colors.red),
                      ),
                      child: const Text('Cancel'),
                    ),

                  const SizedBox(height: 20),
                  const Text('Team Members:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                  // Team member list
                  Column(
                    children: trip.teamMembers.map((member) {
                      final bool isCurrentUser = member == currentUserEmail;
                      String? profilePic = userProfilePics[member];
                      String? username = usernames[member];
                      bool isAdmin = trip.organizerEmail == member;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: profilePic != null && profilePic.isNotEmpty
                              ? NetworkImage(profilePic)
                              : const AssetImage("assets/avatars/noAvatar.png") as ImageProvider,
                        ),
                        title: Text(
                          isCurrentUser
                              ? "${username ?? member} (Me)"
                              : isAdmin
                              ? "${username ?? member} (Admin)"
                              : username ?? member,
                          style: TextStyle(
                            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                            fontStyle: isAdmin ? FontStyle.italic : FontStyle.normal,
                          ),
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
