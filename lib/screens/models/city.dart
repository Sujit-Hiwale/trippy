class City {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String country;
  final String bestTravelSeason;
  final String timeZone;
  final double travelScore;
  final List<String> popularAttractions;

  City({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.country,
    required this.bestTravelSeason,
    required this.timeZone,
    required this.travelScore,
    required this.popularAttractions,
  });

  factory City.fromFirestore(Map<String, dynamic> data, String id) {
    return City(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      country: data['country'] ?? '',
      bestTravelSeason: data['bestTravelSeason'] ?? '',
      timeZone: data['timeZone'] ?? '',
      travelScore: (data['travelScore'] ?? 0).toDouble(),
      popularAttractions: List<String>.from(data['popularAttractions'] ?? []),
    );
  }
}
