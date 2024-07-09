import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nostalgia/features/places/data/model/place.dart';
import 'package:nostalgia/features/places/presentation/widgets/add_another%20item.dart';
import 'package:nostalgia/features/places/presentation/widgets/image_grid.dart';
import 'package:nostalgia/features/places/presentation/widgets/image_viewer.dart';

class ItemDetailsScreen extends StatefulWidget {
  final Place place;

  const ItemDetailsScreen({super.key, required this.place});

  @override
  State<ItemDetailsScreen>  createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  String _placeName = 'Loading...';
  late CameraPosition _initialCameraPosition;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchPlaceName();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
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
          child: Column(children: [
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
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageViewer(
                        imageUrls: widget.place.imageUrl,
                        initialIndex: _currentImageIndex,
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  height: 300,
                  child: PageView.builder(
                    itemCount: widget.place.imageUrl.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return ImageGrid(
                        imageUrls: widget.place.imageUrl,
                        initialIndex: index,
                      );
                    },
                  ),
                ),
              ),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.45,
                  height: 200,
                  child: Column(
                    children: [
                      Container(
                        color: HexColor('ff6608'),
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
                                  color: HexColor('7a9fa7'),
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
                                  color: HexColor('7a9fa7'),
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
                const SizedBox(width: 10),
                Container(
                  width: MediaQuery.sizeOf(context).width * 0.43,
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
                        position: LatLng(
                            widget.place.latitude, widget.place.longitude),
                      ),
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
             AddImage(place:widget. place,),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }
}
