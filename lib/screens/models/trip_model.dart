import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String id;
  final String name;
  final String destination;
  final String imageUrl;
  final DateTime dateOfGoing;
  final String location;
  final String organizerId;
  final String organizerEmail;
  final int duration;
  final String durationUnit;
  String? description;
  final String type;
  List<String> teamMembers;

  Trip({
    required this.id,
    required this.name,
    required this.destination,
    required this.imageUrl,
    required this.dateOfGoing,
    required this.location,
    required this.organizerId,
    required this.organizerEmail,
    required this.duration,
    required this.durationUnit,
    required this.teamMembers,
    this.description,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'destination': destination,
      'imageUrl': imageUrl,
      'dateOfGoing': Timestamp.fromDate(dateOfGoing),
      'location': location,
      'organizerId': organizerId,
      'organizerEmail': organizerEmail,
      'duration': duration,
      'durationUnit': durationUnit,
      'teamMembers': teamMembers,
      'description': description,
      'type': type,
    };
  }
}
