import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/place.dart';
import '../screens/places_details_screen.dart';

class PlaceItem extends StatefulWidget {
  final Place place;
  final Function(Place) onSelected;
  final bool isSelected;
  final bool isSelectionMode;

  const PlaceItem({
    required this.place,
    required this.onSelected,
    required this.isSelected,
    required this.isSelectionMode,
  });

  @override
  _PlaceItemState createState() => _PlaceItemState();
}

class _PlaceItemState extends State<PlaceItem> {
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _loadImage();
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.isSelectionMode) {
          widget.onSelected(widget.place);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDetailsScreen(place: widget.place),
            ),
          );
        }
      },
      onLongPress: () {
        widget.onSelected(widget.place);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _imageBytes != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.memory(
                        _imageBytes!,
                        width: double.infinity,
                        height: MediaQuery.sizeOf(context).height * 0.22,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (widget.isSelected)
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 30,
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
                )
              : const Placeholder(),
        ],
      ),
    );
  }
}
