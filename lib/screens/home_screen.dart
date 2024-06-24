import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nostalgia/screens/places_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/desktop-wallpaper-forever-love-by-emelievarenhed-forever-love.jpg'), // Change to your image path
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.05,
            ),
            Text(
              "Nostalgia",
              style: GoogleFonts.acme(
                textStyle: const TextStyle(
                    fontSize: 87,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            Center(
              child: Text(
                'Only photograph what you love',
                style: GoogleFonts.acme(
                  textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.02,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PlacesListScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor('ff6608'),
                  minimumSize: const Size(0, 50), // Set the desired height here
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  textStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                child: Text(
                  'Make memories',
                  style: GoogleFonts.acme(
                    textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
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
