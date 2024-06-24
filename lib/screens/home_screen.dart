import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                'assets/images/view-camera-with-blossoming-spring-flowers_23-2150890420.jpg'), // Change to your image path
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.15,
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
            const Center(
              child: Text(
                'Only photograph what you love',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.4,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PlacesListScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 50), // Set the desired height here
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  textStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                child: const Text(
                  'Make memories',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
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
