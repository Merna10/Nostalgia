import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/place.dart';

class PlacesProvider with ChangeNotifier {
  List<Place> _places = [];
  final StreamController<List<Place>> _placesStreamController =
      StreamController.broadcast();

  PlacesProvider() {
    _loadPlaces();
  }

  Stream<List<Place>> get placesStream => _placesStreamController.stream;
  List<Place> get places => _places;

 Future<void> _loadPlaces() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? placesStringList = prefs.getStringList('places');
  if (placesStringList != null) {
    _places = placesStringList.map((placeString) {
      Map<String, dynamic> placeMap = jsonDecode(placeString);
      return Place(
        id: placeMap['id'] ?? '',
        title: placeMap['title'] ?? '',
        image: base64Decode(placeMap['image'] ?? ''),
        latitude: placeMap['latitude'] ?? 0.0,
        longitude: placeMap['longitude'] ?? 0.0,
        takenAt: placeMap['takenAt'] != null
            ? DateTime.parse(placeMap['takenAt'])
            : DateTime.now(),
      );
    }).toList();
  }
  _placesStreamController.add(_places); // Notify listeners regardless of data existence
}

  Future<void> savePlace(
    String title,
    List<int> image,
    double latitude,
    double longitude,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      Place newPlace = Place(
        id: const Uuid().v4(),
        title: title,
        image: image,
        latitude: latitude,
        longitude: longitude,
        takenAt: DateTime.now(),
      );

      _places.add(newPlace);
      List<String> placesStringList = _places.map((place) {
        return jsonEncode({
          'id': place.id,
          'title': place.title,
          'image': base64Encode(place.image),
          'latitude': place.latitude,
          'longitude': place.longitude,
          'takenAt': place.takenAt.toString(),
        });
      }).toList();

      await prefs.setStringList('places', placesStringList);

      _placesStreamController.add(_places);
      notifyListeners();
    } catch (e) {
      print('Error saving place: $e');
    }
  }

  void deletePlaces(List<String> ids) {
    _places.removeWhere((place) => ids.contains(place.id));
    notifyListeners();
  }

  void dispose() {
    _placesStreamController.close();
    super.dispose();
  }
}
