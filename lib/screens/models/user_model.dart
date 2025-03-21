// lib/models/user_model.dart
class UserModel {
  final String uid;
  final String email;
  final String username;
  final String? bio;
  final String? profilePic;
  final String? lastLogin;
  final int? phoneNumber;
  final List<String>? connections;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.bio,
    this.profilePic,
    this.lastLogin,
    this.phoneNumber,
    this.connections,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      bio: data['bio'] ?? '',
      profilePic: data['profilePic'] ?? '',
      lastLogin: data['lastLogin'] ?? '',
      phoneNumber: data['phoneNumber'] != null ? data['phoneNumber'] as int : null,
      connections: data['connections'] != null ? List<String>.from(data['connections']) : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'bio': bio,
      'profilePic': profilePic,
      'lastLogin': lastLogin,
      'phoneNumber': phoneNumber,
      'connections': connections,
    };
  }
}
