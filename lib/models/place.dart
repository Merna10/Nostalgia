class Place {
  final String id;
  final String title;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final DateTime takenAt;

  Place({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.takenAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'takenAt': takenAt.toIso8601String(),
    };
  }

  static Place fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled',
      imageUrl: json['imageUrl'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      takenAt: DateTime.tryParse(json['takenAt'] ?? '') ?? DateTime.now(),
    );
  }
}
