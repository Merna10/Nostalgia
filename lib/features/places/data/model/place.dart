import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  Place({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.takenAt,
  });

  String id;
  String title;
  List<String> imageUrl;
  double latitude;
  double longitude;
  DateTime takenAt;

  factory Place.fromMap(Map<String, dynamic> json) => Place(
        id: json["id"] ?? '',
        title: json["title"] ?? 'Untitled',
        imageUrl: json["imageUrl"] ?? '',
        latitude: (json["latitude"] ?? 0.0).toDouble(),
        longitude: (json["longitude"] ?? 0.0).toDouble(),
        takenAt: DateTime.tryParse(json["takenAt"] ?? '') ?? DateTime.now(),
      );

  factory Place.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Place(
      id: snapshot.id,
      title: data['title'] ?? 'Untitled',
      imageUrl: List<String>.from(data['imageUrl'] ?? []),
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      takenAt: DateTime.tryParse(data['takenAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "imageUrl": imageUrl,
        "latitude": latitude,
        "longitude": longitude,
        "takenAt": takenAt.toIso8601String(),
      };
}
