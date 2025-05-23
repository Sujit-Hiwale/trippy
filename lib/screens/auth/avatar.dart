import 'package:flutter/material.dart';

class AvatarSelectionScreen extends StatelessWidget {
  final void Function(String) onAvatarSelected;

  AvatarSelectionScreen({required this.onAvatarSelected, Key? key}) : super(key: key);

  // Example avatar image asset paths
  final List<String> avatars = [
    'assets/avatars/maleCasual.png',
    'assets/avatars/femaleCasual.png',
    'assets/avatars/maleFormal.png',
    'assets/avatars/femaleFormal.png',
    'assets/avatars/maleSport.png',
    'assets/avatars/femaleSport.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Avatar'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: avatars.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3 avatars per row
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final avatarPath = avatars[index];
          return GestureDetector(
            onTap: () {
              onAvatarSelected(avatarPath);
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
