import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nostalgia/screens/auth.dart';
import 'package:provider/provider.dart';
import '../models/place.dart';
import '../providers/places_provider.dart';
import 'add_place_screen.dart';
import '../widgets/place_item.dart';
class PlacesListScreen extends StatefulWidget {
  const PlacesListScreen({Key? key}) : super(key: key);

  @override
  _PlacesListScreenState createState() => _PlacesListScreenState();
}

class _PlacesListScreenState extends State<PlacesListScreen> {
  List<Place> selectedPlaces = [];
  bool isSelectionMode = false;

  void _onPlaceSelected(Place place) {
    setState(() {
      if (selectedPlaces.contains(place)) {
        selectedPlaces.remove(place);
      } else {
        selectedPlaces.add(place);
      }

      isSelectionMode = selectedPlaces.isNotEmpty;
    });
  }

  Future<void> _deleteSelectedPlaces() async {
    bool confirm = await _showConfirmationDialog();
    if (!confirm) return;

    await Provider.of<PlacesProvider>(context, listen: false)
        .deletePlaces(selectedPlaces.map((e) => e.id).toList());

    setState(() {
      selectedPlaces.clear();
      isSelectionMode = false;
    });
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content: const Text(
                  'Are you sure you want to delete the selected images?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PlacesProvider>(
        builder: (context, placesProvider, _) {
          List<Place> places = placesProvider.places;
          bool isLoading = placesProvider.isLoading;

          return Container(
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
                    Row(
                      children: [
                        if (selectedPlaces.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Color.fromARGB(255, 207, 11, 11)),
                            onPressed: _deleteSelectedPlaces,
                          ),
                        IconButton(
                          icon: Icon(
                            Icons.add,
                            size: 32.0,
                            color: HexColor('ff6608'),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AddPlaceScreen(),
                              ),
                            );
                          },
                        ),
                        IconButton(
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => const AuthScreen()),
                              );
                            },
                            icon: const Icon(
                              Icons.logout_outlined,
                              color: Colors.white,
                            ))
                      ],
                    )
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.white,))
                        : places.isEmpty
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
                                itemBuilder: (ctx, i) => PlaceItem(
                                  place: places[i],
                                  isSelected:
                                      selectedPlaces.contains(places[i]),
                                  onSelected: _onPlaceSelected,
                                  isSelectionMode: isSelectionMode,
                                ),
                              ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
