import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'avatar.dart'; // Your avatar selection screen

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  EditProfileScreen({required this.userData});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser;

  late String _username;
  late String _bio;
  late String _avatar;

  @override
  void initState() {
    super.initState();
    _username = widget.userData['username'] ?? '';
    _bio = widget.userData['bio'] ?? '';
    _avatar = widget.userData['profilePic'] ?? 'assets/avatars/maleCasual.png';
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'username': _username,
      'bio': _bio,
      'profilePic': _avatar,
    });

    Navigator.pop(context); // Go back to profile screen
  }

  void _selectAvatar() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AvatarSelectionScreen(
          onAvatarSelected: (selectedAvatar) {
            setState(() {
              _avatar = selectedAvatar;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        elevation: 4,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar with border & shadow
              GestureDetector(
                onTap: _selectAvatar,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundImage: AssetImage(_avatar),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _selectAvatar,
                icon: const Icon(Icons.edit, size: 20),
                label: const Text(
                  "Change Avatar",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                ),
              ),
              const SizedBox(height: 30),

              // Username field with icon
              TextFormField(
                initialValue: _username,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) =>
                value == null || value.trim().isEmpty
                    ? 'Username cannot be empty'
                    : null,
                onChanged: (value) => _username = value,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 24),

              // Bio field with icon
              TextFormField(
                initialValue: _bio,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  prefixIcon: const Icon(Icons.info_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 4,
                onChanged: (value) => _bio = value,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 40),

              // Save Changes button, full width, elevated with padding
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
