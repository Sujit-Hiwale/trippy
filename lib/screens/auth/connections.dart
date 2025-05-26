import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'public_profile.dart'; // you'll create this next
import 'connection_requests.dart'; // optional, for requests screen

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({Key? key}) : super(key: key);

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> _connections = [];
  List<Map<String, dynamic>> _searchResults = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchConnections();
  }

  Future<void> _fetchConnections() async {
    if (currentUser == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
    final List<dynamic> connectionIds = userDoc.data()?['connections'] ?? [];

    final futures = connectionIds.map((uid) => FirebaseFirestore.instance.collection('users').doc(uid).get());
    final results = await Future.wait(futures);

    final users = results
        .where((doc) => doc.exists)
        .map((doc) => {'uid': doc.id, ...doc.data()!})
        .toList();

    setState(() {
      _connections = users;
    });
  }

  Future<void> _searchUsers(String query) async {
    setState(() {
      _searchQuery = query;
    });

    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    final users = result.docs
        .where((doc) => doc.id != currentUser!.uid) // Exclude self
        .map((doc) => {'uid': doc.id, ...doc.data()!})
        .toList();

    setState(() {
      _searchResults = users;
    });
  }

  void _openPublicProfile(Map<String, dynamic> userData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublicProfileScreen(userData: userData),
      ),
    );
  }

  void _goToRequests() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConnectionRequestsScreen(), // optional screen
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mail_outline),
            tooltip: 'Requests',
            onPressed: _goToRequests,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: _searchUsers,
              decoration: InputDecoration(
                hintText: "Search users...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            if (_searchQuery.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Search Results", style: theme.textTheme.titleMedium),
              ),
              const SizedBox(height: 8),
              _buildUserList(_searchResults),
            ] else ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Your Connections", style: theme.textTheme.titleMedium),
              ),
              const SizedBox(height: 8),
              _buildUserList(_connections),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(List<Map<String, dynamic>> users) {
    if (users.isEmpty) {
      return const Center(child: Text("No users found."));
    }

    return Expanded(
      child: ListView.separated(
        itemCount: users.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: user['profilePic'] != null && user['profilePic'] != ""
                  ? AssetImage(user['profilePic'])
                  : const AssetImage("assets/default_profile.png"),
            ),
            title: Text(user['username'] ?? 'Unknown'),
            subtitle: Text(user['bio'] ?? ''),
            onTap: () => _openPublicProfile(user),
          );
        },
      ),
    );
  }
}
