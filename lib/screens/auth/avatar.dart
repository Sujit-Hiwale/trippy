import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class AvatarSelectionScreen extends StatefulWidget {
  final void Function(String) onAvatarSelected;

  const AvatarSelectionScreen({required this.onAvatarSelected, Key? key}) : super(key: key);

  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  List<String> avatars = [];

  @override
  void initState() {
    super.initState();
    _loadAvatars();
  }

  Future<void> _loadAvatars() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final avatarPaths = manifestMap.keys
        .where((String key) => key.startsWith('assets/avatars/') && (key.endsWith('.png') || key.endsWith('.jpg')))
        .toList();

    setState(() {
      avatars = avatarPaths;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Avatar'),
      ),
      body: avatars.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: avatars.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final avatarPath = avatars[index];
          return GestureDetector(
            onTap: () {
              widget.onAvatarSelected(avatarPath);
              Navigator.pop(context);
            },
            child: CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(avatarPath),
              backgroundColor: Colors.transparent,
            ),
          );
        },
      ),
    );
  }
}
