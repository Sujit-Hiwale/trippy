import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'editProfile.dart';
import 'connections.dart';

class ProfileScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<Map<String, dynamic>?> getUserDetails() async {
    if (user == null) return null;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    return doc.exists ? doc.data() as Map<String, dynamic> : null;
  }

  Future<List<Map<String, dynamic>>> getFavouriteTrips(List<dynamic> favourites) async {
    if (favourites.isEmpty) return [];

    final citiesCollection = FirebaseFirestore.instance.collection('cities');
    final futures = favourites.map((cityId) => citiesCollection.doc(cityId).get());
    final cityDocs = await Future.wait(futures);

    for (var doc in cityDocs) {
      if (!doc.exists) {
        print('City with ID ${doc.id} does not exist');
      } else {
        print('Found city: ${doc.id}');
      }
    }

    return cityDocs.where((doc) => doc.exists).map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }


  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _goToEditProfile(BuildContext context, Map<String, dynamic> userData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(userData: userData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        elevation: 4,
        actions: [
          FutureBuilder<Map<String, dynamic>?>(
            future: getUserDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Profile',
                  onPressed: () => _goToEditProfile(context, snapshot.data!),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("User not found"));
          }

          final userData = snapshot.data!;
          final List<dynamic> connections = userData['connections'] ?? [];
          final List<dynamic> favourites = userData['favourites'] ?? [];

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: userData['profilePic'] != null && userData['profilePic'] != ""
                      ? AssetImage(userData['profilePic'])
                      : const AssetImage("assets/default_profile.png") as ImageProvider,
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(height: 24),
                Text(
                  userData['username'] ?? "No Username",
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  userData['bio'] ?? "No bio available",
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/connections');
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people, color: theme.colorScheme.primary, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          "${connections.length} Connections",
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Favourite Trips Section
                if (favourites.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Favourite Trips',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
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
                                color: theme.colorScheme.surfaceVariant,
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
                                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ],

                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
