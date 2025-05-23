import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isGoogleSignup;

  const ProfileSetupScreen({Key? key, required this.isGoogleSignup}) : super(key: key);

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? _profilePicUrl;
  bool _loading = false;

  Future<void> _saveProfile() async {
    setState(() => _loading = true);
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      if (widget.isGoogleSignup) {
        await user.updatePassword(_passwordController.text.trim());
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'bio': _bioController.text.trim(),
        'profilePic': _profilePicUrl ?? "",
      });

      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _uploadProfilePicture() async {
    String? imageUrl = await _firebaseService.uploadProfilePicture(_auth.currentUser!.uid);
    if (imageUrl != null) {
      setState(() => _profilePicUrl = imageUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF21CBF3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 350),
              child: Card(
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Set Up Your Profile',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      if (widget.isGoogleSignup) ...[
                        TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Set Password',
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 8),
                      ],

                      TextField(
                        controller: _bioController,
                        decoration: const InputDecoration(
                          labelText: 'Your Bio',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Profile Picture Preview
                      if (_profilePicUrl != null)
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(_profilePicUrl!),
                        ),
                      const SizedBox(height: 8),

                      ElevatedButton(
                        onPressed: _uploadProfilePicture,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Upload Profile Picture'),
                      ),
                      const SizedBox(height: 16),

                      _loading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: const Text('Save & Continue'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
