import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/place.dart';

class PlacesProvider with ChangeNotifier {
  List<Place> _places = [];

  PlacesProvider() {
    _loadPlaces();
  }

  List<Place> get places => _places;

  Future<void> _loadPlaces() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      CollectionReference memoriesCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('memories');

      QuerySnapshot querySnapshot = await memoriesCollection.get();

      _places = querySnapshot.docs.map((doc) {
        Map<String, dynamic> placeMap = doc.data() as Map<String, dynamic>;
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

      notifyListeners();
    }
  }

  Future<void> savePlace(
    String title,
    List<int> image,
    double latitude,
    double longitude,
  ) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        CollectionReference memoriesCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('memories');

        Place newPlace = Place(
          id: const Uuid().v4(),
          title: title,
          image: image,
          latitude: latitude,
          longitude: longitude,
          takenAt: DateTime.now(),
        );

        await memoriesCollection.doc(newPlace.id).set({
          'id': newPlace.id,
          'title': newPlace.title,
          'image': base64Encode(newPlace.image),
          'latitude': newPlace.latitude,
          'longitude': newPlace.longitude,
          'takenAt': newPlace.takenAt.toIso8601String(),
        });

        _places.add(newPlace);
        notifyListeners();
      }
    } catch (e) {
      print('Error saving place: $e');
    }
  }

  Future<void> deletePlaces(List<String> ids) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      CollectionReference memoriesCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('memories');

      for (String id in ids) {
        await memoriesCollection.doc(id).delete();
      }

      _places.removeWhere((place) => ids.contains(place.id));
      await _loadPlaces(); // Reload the list of places after deletion
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
