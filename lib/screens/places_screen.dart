import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import '../models/place.dart';
import 'add_place_screen.dart';
import '../widgets/place_item.dart';

class PlacesListScreen extends StatelessWidget {
  const PlacesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Place> places = Provider.of<List<Place>>(context);

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
              title: Center(
                child: Text(
                  "Nostalgia",
                  style: GoogleFonts.acme(
                    textStyle:
                        const TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddPlaceScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: places.isEmpty
                    ? Center(
                        child: Text(
                          'Got no places yet, start adding some!',
                          style: GoogleFonts.acme(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 7.0,
                          mainAxisSpacing: 5.0,
                        ),
                        itemCount: places.length,
                        itemBuilder: (ctx, i) => PlaceItem(place: places[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
