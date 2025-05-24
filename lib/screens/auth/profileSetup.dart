import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'avatar.dart'; // Your avatar selection screen

class ProfileSetupScreen extends StatefulWidget {
  final bool isGoogleSignup;
  final User user;

  const ProfileSetupScreen({Key? key, required this.isGoogleSignup, required this.user}) : super(key: key);

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String? _selectedAvatar;
  bool _loading = false;

  void _selectAvatarFromScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AvatarSelectionScreen(
          onAvatarSelected: (selectedAvatar) {
            setState(() {
              _selectedAvatar = selectedAvatar;
            });
          },
        ),
      ),
    );
  }

  Future<void> _createUserDocIfNotExists() async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.user.uid);
    final docSnapshot = await userDoc.get();
    if (!docSnapshot.exists) {
      await userDoc.set({
        'email': widget.user.email ?? '',
        'username': '',
        'bio': '',
        'profilePic': '',
      });
    }
  }

  Future<void> _saveFullProfile() async {
    setState(() => _loading = true);

    try {
      if (widget.isGoogleSignup) {
        final password = _passwordController.text.trim();
        if (password.isEmpty) {
          throw Exception("Password is required for Google sign-up.");
        }
        await widget.user.updatePassword(password);
      }

      await _createUserDocIfNotExists();

      await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).update({
        'username': _usernameController.text.trim(),
        'bio': _bioController.text.trim(),
        'profilePic': _selectedAvatar ?? 'assets/avatars/default.png',
      });

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        color: colorScheme.background,
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Set Up Your Profile',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onBackground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Avatar',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),

                      GestureDetector(
                        onTap: _selectAvatarFromScreen,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: _selectedAvatar != null
                              ? AssetImage(_selectedAvatar!)
                              : const AssetImage('assets/avatars/default.png'),
                          backgroundColor: Colors.grey[300],
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextButton.icon(
                        onPressed: _selectAvatarFromScreen,
                        icon: const Icon(Icons.edit),
                        label: const Text('Choose Avatar'),
                      ),

                      const SizedBox(height: 24),

                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 8),

                      if (widget.isGoogleSignup) ...[
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Set Password',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      TextField(
                        controller: _bioController,
                        decoration: const InputDecoration(
                          labelText: 'Your Bio',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      _loading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveFullProfile,
                          child: const Text('Save & Continue'),
                        ),
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
