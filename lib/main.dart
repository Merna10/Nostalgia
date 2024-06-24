import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:nostalgia/screens/home_screen.dart';
import 'package:nostalgia/screens/places_screen.dart';
import 'package:provider/provider.dart';
import 'providers/places_provider.dart';
import 'models/place.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PlacesProvider()),
        StreamProvider<List<Place>>(
          create: (context) => context.read<PlacesProvider>().placesStream,
          initialData: [],
        ),
      ],
      child: CalendarControllerProvider(
        controller: EventController(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Places App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: HomePage(),
        ),
      ),
    );
  }
}
