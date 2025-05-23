import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TripChatScreen extends StatefulWidget {
  final String tripName; // Name of the trip = collection name

  TripChatScreen({required this.tripName});

  @override
  _TripChatScreenState createState() => _TripChatScreenState();
}

class _TripChatScreenState extends State<TripChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late Map<String, String?> userProfilePics = {}; // Store profile pictures
  late Map<String, String?> userNames = {}; // Store usernames

  @override
  void initState() {
    super.initState();
    _fetchUserProfilePics(); // Fetch profile pictures and usernames when screen is initialized
  }

  // Fetch profile pictures and usernames for each user who sent a message
  Future<void> _fetchUserProfilePics() async {
    final chatMessagesSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.tripName)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .get();

    final Set<String> userEmails = {};
    for (var doc in chatMessagesSnapshot.docs) {
      final messageData = doc.data();
      userEmails.add(messageData['sender']); // Add sender email to the set
    }

    for (var email in userEmails) {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        String? profilePic = snapshot.docs.first.get('profilePic');
        String? username = snapshot.docs.first.get('username');
        setState(() {
          userProfilePics[email] = profilePic; // Store profile picture URLs
          userNames[email] = username; // Store usernames
        });
      }
    }
  }

  void sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.tripName)
        .collection('messages')
        .add({
      'text': _messageController.text.trim(),
      'sender': FirebaseAuth.instance.currentUser!.email,
      'timestamp': FieldValue.serverTimestamp(),
      'mediaPath': null,
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.tripName} Chat")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.tripName)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final messages = snapshot.data!.docs;

                return ListView(
                  padding: EdgeInsets.all(8),
                  children: messages.map((msg) {
                    final data = msg.data() as Map<String, dynamic>;
                    final senderEmail = data['sender'];
                    final profilePic = userProfilePics[senderEmail];
                    final username = userNames[senderEmail];

                    return Align(
                      alignment: senderEmail == FirebaseAuth.instance.currentUser!.email
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: senderEmail == FirebaseAuth.instance.currentUser!.email
                              ? Colors.blue[100]
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: senderEmail == FirebaseAuth.instance.currentUser!.email
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (senderEmail != FirebaseAuth.instance.currentUser!.email)
                              CircleAvatar(
                                backgroundImage: profilePic != null && profilePic.isNotEmpty
                                    ? AssetImage(profilePic)
                                    : AssetImage("assets/avatars/noAvatar.png") as ImageProvider,
                              ),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: senderEmail == FirebaseAuth.instance.currentUser!.email
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  username ?? senderEmail, // Fallback to email if username is not found
                                  style: TextStyle(
                                    fontWeight: senderEmail == FirebaseAuth.instance.currentUser!.email
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: Colors.black54
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  data['text'] ?? "[Media]",
                                  style: TextStyle(
                                    color: Colors.black, // Theme-based text color
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: 'Type your message...'),
                  ),
                ),
                IconButton(icon: Icon(Icons.send), onPressed: sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}