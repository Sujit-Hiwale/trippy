class User {
  final String uid;
  final String email;
  final String username;
  final String? bio;
  final String? profileImageUrl;
  final List<String> favourites;

  User({
    required this.uid,
    required this.email,
    required this.username,
    this.bio,
    this.profileImageUrl,
    this.favourites = const [],
  });

  // Convert AppUser to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'favourites': favourites,
    };
  }

  // Create AppUser from Firestore document
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      bio: map['bio'],
      profileImageUrl: map['profileImageUrl'],
      favourites: List<String>.from(map['favourites'] ?? []),
    );
  }
}
