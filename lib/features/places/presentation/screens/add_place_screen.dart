import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nostalgia/core/services/location_service.dart';
import 'package:nostalgia/features/places/data/providers/places_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _titleController = TextEditingController();
  List<File> _pickedImages = [];
  bool _isSubmitting = false;
  Position? _locationData;
  GoogleMapController? _mapController;

  final LocationService _locationService = LocationService();

  Future<void> _pickImageFromCamera() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );
    if (pickedImage != null) {
      setState(() {
        _pickedImages.add(File(pickedImage.path));
      });
    }
  }

  Future<void> _pickImagesFromFile() async {
    final pickedImageFiles = await ImagePicker().pickMultiImage(
      maxWidth: 600,
    );
    if (pickedImageFiles != null) {
      setState(() {
        _pickedImages
            .addAll(pickedImageFiles.map((file) => File(file.path)).toList());
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await _locationService.getCurrentLocation();
      String locationTitle = await _locationService.getLocationTitle(position);
      print('Location Name: $locationTitle');

      setState(() {
        _locationData = position;
      });

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
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _savePlace() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });

    final scaffoldMsg = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    if (_titleController.text.isEmpty ||
        _pickedImages.isEmpty ||
        _locationData == null) {
      return;
    }

    try {
      await Provider.of<PlacesProvider>(context, listen: false).savePlace(
        _titleController.text,
        _pickedImages.map((file) => file.path).toList(),
        _locationData!.latitude,
        _locationData!.longitude,
      );
      scaffoldMsg.showSnackBar(
        const SnackBar(
          content: Text('Item added successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
      setState(() {
        _isSubmitting = false;
      });
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
                      _pickedImages.isEmpty
                          ? Text(
                              'No Images Chosen',
                              style: GoogleFonts.acme(
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              itemCount: _pickedImages.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 4.0,
                                mainAxisSpacing: 4.0,
                              ),
                              itemBuilder: (ctx, index) {
                                return Image.file(
                                  _pickedImages[index],
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.camera,
                              color: HexColor('ff6608'),
                            ),
                            onPressed: _pickImageFromCamera,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.photo,
                              color: HexColor('ff6608'),
                            ),
                            onPressed: _pickImagesFromFile,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _locationData == null
                          ? ElevatedButton(
                              onPressed: _getCurrentLocation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: HexColor('ff6608'),
                              ),
                              child: Text(
                                'Select Current Location',
                                style: GoogleFonts.acme(
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                Container(
                                  height: 200,
                                  width: double.infinity,
                                  child: GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(
                                        _locationData!.latitude,
                                        _locationData!.longitude,
                                      ),
                                      zoom: 15,
                                    ),
                                    mapType: MapType.terrain,
                                    markers: {
                                      Marker(
                                        markerId: const MarkerId('m1'),
                                        position: LatLng(
                                          _locationData!.latitude,
                                          _locationData!.longitude,
                                        ),
                                      ),
                                    },
                                    onMapCreated: (controller) {
                                      _mapController = controller;
                                    },
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _savePlace,
                        icon: const Icon(Icons.add),
                        label: _isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Add Place',
                                style: GoogleFonts.acme(
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HexColor('ff6608'),
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
