import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user profile image (placeholder, replace with actual logic if needed)
  static String getUserProfileImage(String email) {
    return 'https://api.dicebear.com/7.x/initials/svg?seed=$email';
  }

  // Fetch users who are not friends
  static Future<List<String>> getNonFriendUsers(String currentUserEmail) async {
    if (currentUserEmail.isEmpty) return [];

    try {
      QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      List<String> allUsers = usersSnapshot.docs.map((doc) => doc['email'] as String).toList();

      // Fetch friends of the current user
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUserEmail).get();
      List<String> friends = userDoc.exists ? List<String>.from(userDoc['friends'] ?? []) : [];

      // Return users who are not friends and not the current user
      return allUsers.where((email) => email != currentUserEmail && !friends.contains(email)).toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  // Add a friend
  static Future<void> addFriend(String currentUserEmail, String friendEmail) async {
    if (currentUserEmail.isEmpty || friendEmail.isEmpty) return;

    try {
      await _firestore.collection('users').doc(currentUserEmail).update({
        'friends': FieldValue.arrayUnion([friendEmail]),
      });

      await _firestore.collection('users').doc(friendEmail).update({
        'friends': FieldValue.arrayUnion([currentUserEmail]),
      });
    } catch (e) {
      print('Error adding friend: $e');
    }
  }
}
