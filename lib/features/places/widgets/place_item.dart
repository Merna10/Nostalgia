import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nostalgia/features/places/data/model/place.dart';

import '../screens/places_details_screen.dart';

class PlaceItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isSelectionMode) {
          onSelected(place);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDetailsScreen(place: place),
            ),
          );
        }
      },
      onLongPress: () {
        onSelected(place);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.network(
                  place.imageUrl,
                  width: double.infinity,
                  height: MediaQuery.sizeOf(context).height * 0.22,
                  fit: BoxFit.cover,
                ),
              ),
              if (isSelected)
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
                    place.title,
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
        ],
      ),
    );
  }
}