import 'package:flutter/material.dart';
import '../models/city.dart';
import '../trips/trip_creation.dart';

class CityDetailsPage extends StatefulWidget {
  final City city;

  const CityDetailsPage({super.key, required this.city});

  @override
  State<CityDetailsPage> createState() => _CityDetailsPageState();
}

class _CityDetailsPageState extends State<CityDetailsPage> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final cardColor = Colors.white.withOpacity(0.1);

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: Image.network(
              widget.city.imageUrl,
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.2),
              colorBlendMode: BlendMode.darken,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.broken_image, size: 100, color: Colors.redAccent),
                );
              },
            ),
          ),

          // Foreground content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.city.name,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 8,
                                color: Colors.black87,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          iconSize: 32,
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.white,
                          ),
                          onPressed: () {
                            setState(() => isFavorite = !isFavorite);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isFavorite
                                    ? 'Added to favorites!'
                                    : 'Removed from favorites'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          splashRadius: 24,
                          tooltip: 'Save',
                        ),
                      ),
                    ],
                  ),
                ),

                // Country chip
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      label: Text(widget.city.country,
                          style: const TextStyle(color: Colors.white)),
                      backgroundColor: Colors.deepPurple.withOpacity(0.8),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            widget.city.description,
                            style: const TextStyle(fontSize: 16, height: 1.4),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Unified Info Cards
                        Row(
                          children: [
                            Expanded(
                              child: _UnifiedInfoCard(
                                icon: Icons.calendar_today,
                                title: 'Best Season',
                                content: widget.city.bestTravelSeason,
                                backgroundColor: cardColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _UnifiedInfoCard(
                                icon: Icons.access_time,
                                title: 'Time Zone',
                                content: widget.city.timeZone,
                                backgroundColor: cardColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _UnifiedInfoCard(
                                icon: Icons.star,
                                title: 'Travel Score',
                                content: widget.city.travelScore.toStringAsFixed(1),
                                backgroundColor: cardColor,
                                isRating: true,
                                rating: widget.city.travelScore,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Popular Attractions
                        Text(
                          'Popular Attractions',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                blurRadius: 5,
                                offset: Offset(0, 1),
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        ...widget.city.popularAttractions.map(
                              (attr) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.place, color: Colors.deepPurple),
                                const SizedBox(width: 8),
                                Text(attr, style: const TextStyle(fontSize: 15)),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                // Bottom Action Buttons
                Container(
                  color: Colors.black.withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/create',
                              arguments: {
                                'initialName': 'Trip to ${widget.city.name}',
                                'initialDestination': '${widget.city.name}, ${widget.city.country}',
                                'initialImageUrl': widget.city.imageUrl,
                                'initialDescription': widget.city.description,
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('🧭', style: TextStyle(fontSize: 20)),
                              SizedBox(width: 8),
                              Text('Plan'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/create',
                              arguments: {
                                'initialName': 'Trip to ${widget.city.name}',
                                'initialDestination': '${widget.city.name}, ${widget.city.country}',
                                'initialImageUrl': widget.city.imageUrl,
                                'initialDescription': widget.city.description,
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('🎫', style: TextStyle(fontSize: 20)),
                              SizedBox(width: 8),
                              Text('Book'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Unified card widget for info or rating
class _UnifiedInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final bool isRating;
  final double? rating;
  final Color backgroundColor;

  const _UnifiedInfoCard({
    required this.icon,
    required this.title,
    required this.content,
    this.isRating = false,
    this.rating,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final double clampedRating = (rating ?? 0).clamp(0.0, 5.0);
    final int fullStars = clampedRating.floor();
    final bool hasHalf = (clampedRating - fullStars) >= 0.5;
    final int emptyStars = 5 - fullStars - (hasHalf ? 1 : 0);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      constraints: const BoxConstraints(minHeight: 120),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Colors.deepPurple),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          if (isRating && rating != null)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < fullStars; i++)
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                    if (hasHalf)
                      const Icon(Icons.star_half, color: Colors.amber, size: 18),
                    for (int i = 0; i < emptyStars; i++)
                      const Icon(Icons.star_border, color: Colors.amber, size: 18),
                  ],
                ),
                Text(clampedRating.toStringAsFixed(1), style: const TextStyle(fontSize: 14)),
              ],
            )
          else
            Text(content, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
