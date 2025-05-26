import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PublicProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const PublicProfileScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  bool isConnected = false;
  bool requestSent = false;
  bool requestReceived = false;

  @override
  void initState() {
    super.initState();
    checkRelationshipStatus();
  }

  Future<void> checkRelationshipStatus() async {
    final currentUserDoc =
    await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
    final otherUserId = widget.userData['uid'];

    final connections = List<String>.from(currentUserDoc.data()?['connections'] ?? []);
    final sent = List<String>.from(currentUserDoc.data()?['requestsSent'] ?? []);
    final received = List<String>.from(currentUserDoc.data()?['requestsReceived'] ?? []);

    setState(() {
      isConnected = connections.contains(otherUserId);
      requestSent = sent.contains(otherUserId);
      requestReceived = received.contains(otherUserId);
    });
  }

  Future<List<Map<String, dynamic>>> getFavouriteTrips(List<dynamic> favourites) async {
    if (favourites.isEmpty) return [];

    final citiesCollection = FirebaseFirestore.instance.collection('cities');
    final futures = favourites.map((cityId) => citiesCollection.doc(cityId).get());
    final cityDocs = await Future.wait(futures);

    return cityDocs.where((doc) => doc.exists).map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> sendRequest() async {
    await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
      'requestsSent': FieldValue.arrayUnion([widget.userData['uid']]),
    });

    await FirebaseFirestore.instance.collection('users').doc(widget.userData['uid']).update({
      'requestsReceived': FieldValue.arrayUnion([currentUser!.uid]),
    });

    checkRelationshipStatus();
  }

  Future<void> cancelRequest() async {
    await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
      'requestsSent': FieldValue.arrayRemove([widget.userData['uid']]),
    });

    await FirebaseFirestore.instance.collection('users').doc(widget.userData['uid']).update({
      'requestsReceived': FieldValue.arrayRemove([currentUser!.uid]),
    });

    checkRelationshipStatus();
  }

  Future<void> removeConnection() async {
    await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
      'connections': FieldValue.arrayRemove([widget.userData['uid']]),
    });

    await FirebaseFirestore.instance.collection('users').doc(widget.userData['uid']).update({
      'connections': FieldValue.arrayRemove([currentUser!.uid]),
    });

    checkRelationshipStatus();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.userData;
    final favourites = user['favourites'] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(user['username'] ?? "Profile")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: user['profilePic'] != null && user['profilePic'] != ""
                  ? AssetImage(user['profilePic'])
                  : const AssetImage("assets/default_profile.png"),
            ),
            const SizedBox(height: 16),
            Text(user['username'] ?? "", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(user['bio'] ?? "No bio"),
            const SizedBox(height: 20),
            if (isConnected)
              ElevatedButton.icon(
                icon: const Icon(Icons.link_off),
                label: const Text("Remove Connection"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: removeConnection,
              )
            else if (requestSent)
              ElevatedButton.icon(
                icon: const Icon(Icons.cancel),
                label: const Text("Cancel Request"),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  backgroundColor: Colors.transparent,
                ),
                onPressed: cancelRequest,
              )
            else
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text("Send Request"),
                onPressed: sendRequest,
              ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Favourite Trips',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            if (favourites.isNotEmpty) ...[
              const SizedBox(height: 16),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: getFavouriteTrips(favourites),
                builder: (context, tripSnapshot) {
                  if (tripSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!tripSnapshot.hasData || tripSnapshot.data!.isEmpty) {
                    return const Text('No favourite trips found.');
                  }

                  final trips = tripSnapshot.data!;
                  final screenWidth = MediaQuery.of(context).size.width;
                  final screenHeight = MediaQuery.of(context).size.height;

                  return SizedBox(
                    height: screenHeight * 0.3,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: trips.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final trip = trips[index];
                        return Container(
                          width: screenWidth * 0.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: trip['imageUrl'] != null && trip['imageUrl'] != ""
                                      ? Image.network(
                                    trip['imageUrl'],
                                    fit: BoxFit.cover,
                                  )
                                      : Image.asset(
                                    'assets/default_trip.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  trip['name'] ?? 'Unnamed Trip',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ] else ...[
              const SizedBox(height: 16),
              Text(
                'No favourite trips added.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
