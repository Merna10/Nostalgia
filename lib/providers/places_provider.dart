import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/place.dart';

class PlacesProvider with ChangeNotifier {
  List<Place> _places = [];
  bool _isLoading = false;

  List<Place> get places => _places;
  bool get isLoading => _isLoading;

  Stream<List<Place>> get placesStream {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('memories')
          .orderBy('takenAt', descending: true)
          .snapshots()
          .map((snapshot) {
        _places = snapshot.docs.map((doc) {
          Map<String, dynamic> placeMap = doc.data() as Map<String, dynamic>;
          return Place.fromJson(placeMap);
        }).toList();
        notifyListeners();
        return _places;
      });
    } else {
      _places = [];
      notifyListeners();
      return Stream.value(_places);
    }
  }

  Future<void> savePlace(
    String title,
    String imagePath,
    double latitude,
    double longitude,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String imageId = const Uuid().v4();
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('users/${user.uid}/memories/$imageId');
        UploadTask uploadTask = storageRef.putFile(File(imagePath));

        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        CollectionReference memoriesCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('memories');

        Place newPlace = Place(
          id: const Uuid().v4(),
          title: title,
          imageUrl: downloadUrl,
          latitude: latitude,
          longitude: longitude,
          takenAt: DateTime.now(),
        );

        await memoriesCollection.doc(newPlace.id).set(newPlace.toJson());

        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error saving place: $e');
    }
  }

  Future<void> deletePlaces(List<String> ids) async {
    try {
      _isLoading = true;
      notifyListeners();

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        CollectionReference memoriesCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('memories');

        for (String id in ids) {
          await memoriesCollection.doc(id).delete();
        }

        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error deleting places: $e');
    }
  }
}
