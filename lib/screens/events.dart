import 'package:flutter/material.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({super.key});

  final List<Map<String, String>> dummyEvents = const [
    {
      'title': 'Mountain Music Festival',
      'date': 'June 15, 2025',
      'location': 'Shimla, India',
      'image': 'assets/background/mountainMusicFestival.png',
      'description': 'A weekend of folk music and nature under the stars.'
    },
    {
      'title': 'Desert Art Carnival',
      'date': 'July 10, 2025',
      'location': 'Jaisalmer, India',
      'image': 'assets/background/desertArtCarnival.png',
      'description': 'Experience vibrant art and culture in the golden desert.'
    },
    {
      'title': 'River Yoga Retreat',
      'date': 'August 1, 2025',
      'location': 'Rishikesh, India',
      'image': 'assets/background/riverYogaRetreat.png',
      'description': 'Join us for yoga sessions by the river with expert guides.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trippy'),
        backgroundColor: theme.colorScheme.primaryContainer,
        foregroundColor: theme.colorScheme.onPrimaryContainer,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dummyEvents.length,
        itemBuilder: (context, index) {
          final event = dummyEvents[index];
          return EventCard(
            title: event['title']!,
            date: event['date']!,
            location: event['location']!,
            imageUrl: event['image']!,
            description: event['description']!,
          );
        },
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String location;
  final String imageUrl;
  final String description;

  const EventCard({
    super.key,
    required this.title,
    required this.date,
    required this.location,
    required this.imageUrl,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 5,
            child: Image(
              image: AssetImage(imageUrl),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported, size: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary)),
                const SizedBox(height: 4),
                Text('$date · $location',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: theme.textTheme.bodyLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
