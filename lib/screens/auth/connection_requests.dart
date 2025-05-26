import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ConnectionRequestsScreen extends StatefulWidget {
  const ConnectionRequestsScreen({Key? key}) : super(key: key);

  @override
  State<ConnectionRequestsScreen> createState() => _ConnectionRequestsScreenState();
}

class _ConnectionRequestsScreenState extends State<ConnectionRequestsScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> received = [];
  List<Map<String, dynamic>> sent = [];

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
    final receivedIds = List<String>.from(userDoc.data()?['requestsReceived'] ?? []);
    final sentIds = List<String>.from(userDoc.data()?['requestsSent'] ?? []);

    final receivedUsers = await Future.wait(
      receivedIds.map((id) => FirebaseFirestore.instance.collection('users').doc(id).get()),
    );

    final sentUsers = await Future.wait(
      sentIds.map((id) => FirebaseFirestore.instance.collection('users').doc(id).get()),
    );

    setState(() {
      received = receivedUsers.where((doc) => doc.exists).map((doc) => {'uid': doc.id, ...doc.data()!}).toList();
      sent = sentUsers.where((doc) => doc.exists).map((doc) => {'uid': doc.id, ...doc.data()!}).toList();
    });
  }

  Future<void> acceptRequest(String requesterId) async {
    final batch = FirebaseFirestore.instance.batch();

    final currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);
    final requesterRef = FirebaseFirestore.instance.collection('users').doc(requesterId);

    batch.update(currentUserRef, {
      'requestsReceived': FieldValue.arrayRemove([requesterId]),
      'connections': FieldValue.arrayUnion([requesterId]),
    });

    batch.update(requesterRef, {
      'requestsSent': FieldValue.arrayRemove([currentUser!.uid]),
      'connections': FieldValue.arrayUnion([currentUser!.uid]),
    });

    await batch.commit();
    fetchRequests();
  }

  Future<void> rejectRequest(String requesterId) async {
    await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
      'requestsReceived': FieldValue.arrayRemove([requesterId]),
    });

    await FirebaseFirestore.instance.collection('users').doc(requesterId).update({
      'requestsSent': FieldValue.arrayRemove([currentUser!.uid]),
    });

    fetchRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connection Requests")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Received Requests", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(child: _buildRequestList(received, isReceived: true)),
            const SizedBox(height: 16),
            const Text("Sent Requests", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(child: _buildRequestList(sent, isReceived: false)),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestList(List<Map<String, dynamic>> users, {required bool isReceived}) {
    if (users.isEmpty) {
      return const Center(child: Text("No requests."));
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: user['profilePic'] != null && user['profilePic'] != ""
                ? AssetImage(user['profilePic'])
                : const AssetImage("assets/default_profile.png"),
          ),
          title: Text(user['username'] ?? ''),
          subtitle: Text(user['bio'] ?? ''),
          trailing: isReceived
              ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: () => acceptRequest(user['uid']),
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: () => rejectRequest(user['uid']),
              ),
            ],
          )
              : const Text("Pending"),
        );
      },
    );
  }
}
