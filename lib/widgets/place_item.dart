import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nostalgia/providers/places_provider.dart';
import 'package:nostalgia/screens/places_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/place.dart';

class PlaceItem extends StatefulWidget {
  final Place place;

  const PlaceItem({required this.place});

  @override
  _PlaceItemState createState() => _PlaceItemState();
}

class _PlaceItemState extends State<PlaceItem> {
  String _placeName = 'Loading...';
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _deleteImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Remove the place from the list
    Provider.of<PlacesProvider>(context, listen: false)
        .deletePlace(widget.place.id);

    // Save the updated list to SharedPreferences
    List<Place> updatedPlaces =
        Provider.of<PlacesProvider>(context, listen: false).places;
    List<String> placesStringList = updatedPlaces.map((place) {
      return jsonEncode({
        'title': place.title,
        'image': base64Encode(place.image),
        'latitude': place.latitude,
        'longitude': place.longitude,
      });
    }).toList();
    await prefs.setStringList('places', placesStringList);

    setState(() {
      _imageBytes = null;
    });
  }

  Future<void> _loadImage() async {
    try {
      setState(() {
        _imageBytes = Uint8List.fromList(widget.place.image);
      });
    } catch (e) {
      print('Error loading image: $e');
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteImage();
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailsScreen(place: widget.place),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _imageBytes != null
              ? GestureDetector(
                  onLongPress: _showDeleteConfirmationDialog,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                            20.0), // Adjust the value for more or less roundness
                        child: Image.memory(
                          _imageBytes!,
                          width: double.infinity,
                          height: 190,
                          fit: BoxFit.cover,
                          
                        ),
                      ),
                      Positioned(
                        top: 80,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            widget.place.title,
                            style: GoogleFonts.acme(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const Placeholder(),
        ],
      ),
    );
  }
}