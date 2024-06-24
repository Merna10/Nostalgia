import 'dart:convert';

class Place {
  final String id;
  final String title;
  final List<int> image;
  final double latitude;
  final double longitude;
  final DateTime takenAt;

  Place({
    required this.id,
    required this.title,
    required this.image,
    required this.latitude,
    required this.longitude,
    required this.takenAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'latitude': latitude,
      'longitude': longitude,
      'takenAt': takenAt.toIso8601String(),
    };
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      title: json['title'],
      image: List<int>.from(json['image']),
      latitude: json['latitude'],
      longitude: json['longitude'],
      takenAt: DateTime.parse(json['takenAt']),
    );
  }
}
