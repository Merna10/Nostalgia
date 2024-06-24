import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import '../models/place.dart';

class ItemDetailsScreen extends StatefulWidget {
  final Place place;

  const ItemDetailsScreen({required this.place});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  String _placeName = 'Loading...';
  Uint8List? _imageBytes;
  late CameraPosition _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    _fetchPlaceName();
    _loadImage();
    _initialCameraPosition = CameraPosition(
      target: LatLng(widget.place.latitude, widget.place.longitude),
      zoom: 14,
    );
  }

  Future<void> _fetchPlaceName() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        widget.place.latitude,
        widget.place.longitude,
      );

      String locationName = placemarks.first.name ?? 'Unknown Location';
      setState(() {
        _placeName = locationName;
      });
    } catch (e) {
      print('Error fetching place name: $e');
      setState(() {
        _placeName = 'Error';
      });
    }
  }

  final monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  Future<void> _loadImage() async {
    try {
      setState(() {
        _imageBytes = Uint8List.fromList(widget.place.image);
      });
    } catch (e) {
      print('Error loading image: $e');
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
              HexColor('8AC6D1'),
              HexColor('E8F6EF'),
            ],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                widget.place.title,
                style: GoogleFonts.acme(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _imageBytes != null
                      ? Image.memory(
                          _imageBytes!,
                          height: 260,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : const SizedBox(
                          height: 250,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      widget.place.title,
                      style: GoogleFonts.acme(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'In $_placeName',
                      style: GoogleFonts.acme(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      SizedBox(
                        width: 180,
                        height: 200,
                        child: Column(
                          children: [
                            Container(
                              color: HexColor('FFB6B9'),
                              width: double.infinity,
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  '${widget.place.takenAt.year}',
                                  style: GoogleFonts.lobster(
                                    textStyle: const TextStyle(
                                      fontSize: 30,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              color: Colors.white,
                              width: double.infinity,
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    monthNames[widget.place.takenAt.month - 1],
                                    style: GoogleFonts.lobster(
                                      textStyle: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: HexColor('8AC6D1'),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    '${widget.place.takenAt.day}',
                                    style: GoogleFonts.lobster(
                                      textStyle: TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: HexColor('8AC6D1'),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5.0),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10), // Add space between boxes
                      Container(
                        width: 180,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: GoogleMap(
                          mapType: MapType.terrain,
                          initialCameraPosition: _initialCameraPosition,
                          markers: {
                            Marker(
                              markerId: const MarkerId(
                                'place_marker',
                              ),
                              position: LatLng(widget.place.latitude,
                                  widget.place.longitude),
                            ),
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
