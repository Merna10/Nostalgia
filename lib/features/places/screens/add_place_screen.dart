import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nostalgia/features/places/data/providers/places_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart'; // Import Geocoding package

class AddPlaceScreen extends StatefulWidget {
  @override
  _AddPlaceScreenState createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _titleController = TextEditingController();
  File? _pickedImage;
  Position? _locationData;
  GoogleMapController? _mapController;

  Future<void> _pickImage() async {
    final pickedImageFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );
    if (pickedImageFile != null) {
      setState(() {
        _pickedImage = File(pickedImageFile.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final pickedImageFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );
    if (pickedImageFile != null) {
      setState(() {
        _pickedImage = File(pickedImageFile.path);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    if (permission == LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _locationData = position;
      });

      // Get location name using Geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _locationData!.latitude,
        _locationData!.longitude,
      );

      String locationTitle = placemarks.first.name ?? 'Unknown Location';
      print('Location Name: $locationTitle');

      if (_locationData != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                _locationData!.latitude,
                _locationData!.longitude,
              ),
              zoom: 15,
            ),
          ),
        );
      }
    }
  }

  void _savePlace() async {
    if (_titleController.text.isEmpty ||
        _pickedImage == null ||
        _locationData == null) {
      return;
    }

    try {
      await Provider.of<PlacesProvider>(context, listen: false).savePlace(
        _titleController.text,
        _pickedImage!.path, // Pass the image path correctly
        _locationData!.latitude,
        _locationData!.longitude,
      );

      Navigator.of(context).pop();
    } catch (e) {
      print('Error saving place: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              HexColor('1f2022'),
              HexColor('1f2c32'),
              HexColor('0e626d'),
              HexColor('358491'),
              HexColor('e1e2e4'),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                'Add a New Memory',
                style: GoogleFonts.acme(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: GoogleFonts.acme(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        controller: _titleController,
                        style: GoogleFonts.acme(
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _pickedImage == null
                                ? Text(
                                    'No Image Chosen',
                                    style: GoogleFonts.acme(
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : Image.file(
                                    _pickedImage!,
                                    fit: BoxFit.fill,
                                    width: double.infinity,
                                    height: 150,
                                  ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.camera,
                                  color: HexColor('ff6608'),
                                ),
                                onPressed: _takePhoto,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.folder,
                                  color: HexColor('ff6608'),
                                ),
                                onPressed: _pickImage,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _locationData == null
                              ? Text(
                                  'No Location Chosen',
                                  style: GoogleFonts.acme(
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Lat: ${_locationData!.latitude}, Long: ${_locationData!.longitude}',
                                  style: GoogleFonts.acme(
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              Icons.location_on,
                              color: HexColor('ff6608'),
                            ),
                            onPressed: () async {
                              await _getCurrentLocation();
                              if (_locationData != null &&
                                  _mapController != null) {
                                _mapController!.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: LatLng(
                                        _locationData!.latitude,
                                        _locationData!.longitude,
                                      ),
                                      zoom: 15,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        child: GoogleMap(
                          onMapCreated: (controller) {
                            setState(() {
                              _mapController = controller;
                            });
                          },
                          mapType: MapType.terrain,
                          initialCameraPosition: _locationData != null
                              ? CameraPosition(
                                  target: LatLng(
                                    _locationData!.latitude,
                                    _locationData!.longitude,
                                  ),
                                  zoom: 15,
                                )
                              : const CameraPosition(
                                  target: LatLng(24.126702, 28.843031),
                                  zoom: 12,
                                ),
                          markers: _locationData != null
                              ? {
                                  Marker(
                                    markerId: MarkerId('currentLocation'),
                                    position: LatLng(
                                      _locationData!.latitude,
                                      _locationData!.longitude,
                                    ),
                                  ),
                                }
                              : {},
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _getCurrentLocation().then((_) {
                            _savePlace();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: HexColor('ff6608'),
                          elevation: 0,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Add Memory',
                          style: GoogleFonts.acme(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}