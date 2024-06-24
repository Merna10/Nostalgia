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
          id: placeMap['id'] ?? '', // Add null check and default value
          title: placeMap['title'] ?? '', // Add null check and default value
          image: base64Decode(
              placeMap['image'] ?? ''), // Add null check and default value
          latitude:
              placeMap['latitude'] ?? 0.0, // Add null check and default value
          longitude:
              placeMap['longitude'] ?? 0.0, // Add null check and default value
          takenAt: placeMap['takenAt'] != null
              ? DateTime.parse(placeMap['takenAt'])
              : DateTime.now(), // Handle null or invalid dates
        );
      }).toList();
      _placesStreamController.add(_places);
    }
  }

  Future<void> savePlace(
      String title, List<int> image, double latitude, double longitude) async {
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

      // Add the new place to the list
      _places.add(newPlace);
      List<String> placesStringList = _places.map((place) {
        return jsonEncode({
          'id': place.id,
          'title': place.title,
          'image': base64Encode(place.image),
          'latitude': place.latitude,
          'longitude': place.longitude,
          'takenAt': place.takenAt.toString(), // Convert DateTime to String
        });
      }).toList();

      await prefs.setStringList('places', placesStringList);

      // Notify listeners after the update is successful
      _placesStreamController.add(_places);
      _loadPlaces();
      notifyListeners();
    } catch (e) {
      // Handle any exceptions or errors here
      print('Error saving place: $e');
      // Optionally show a snackbar or alert dialog to inform the user about the error
    }
  }

  void deletePlace(String placeId) {
    _places.removeWhere((place) => place.id == placeId);
    _placesStreamController.add(_places);
    notifyListeners();
    _loadPlaces();
  }
}
