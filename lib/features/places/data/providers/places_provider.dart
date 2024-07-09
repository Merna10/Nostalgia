import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:nostalgia/features/places/data/model/place.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/scheduler.dart';

class PlacesProvider with ChangeNotifier {
  List<Place> _places = [];
  bool _isLoading = false;

  List<Place> get places => _places;
  bool get isLoading => _isLoading;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchPlaces() async {
    _setLoading(true);
    User? user = FirebaseAuth.instance.currentUser;

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(user?.uid)
          .collection('memories')
          .orderBy('takenAt', descending: true)
          .get();
      _places = snapshot.docs.map((doc) => Place.fromSnapshot(doc)).toList();
      _setLoading(false);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (error) {
      print('Error fetching places: $error');

      _setLoading(false);
    }
  }

  Future<void> savePlace(
    String title,
    List<String> imagePaths,
    double latitude,
    double longitude,
  ) async {
    _setLoading(true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      List<String> imageUrls = [];
      for (String imagePath in imagePaths) {
        String imageId = const Uuid().v4();
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('users/${user.uid}/memories/$imageId');
        UploadTask uploadTask = storageRef.putFile(File(imagePath));

        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      Place newPlace = Place(
        id: const Uuid().v4(),
        title: title,
        imageUrl: imageUrls,
        latitude: latitude,
        longitude: longitude,
        takenAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('memories')
          .doc(newPlace.id)
          .set(newPlace.toMap());

      _places.add(newPlace);
    } catch (e) {
      print('Error saving place: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deletePlaces(List<String> ids) async {
    _setLoading(true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      for (String id in ids) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('memories')
            .doc(id)
            .delete();
      }

      _places.removeWhere((place) => ids.contains(place.id));
    } catch (e) {
      print('Error deleting places: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
