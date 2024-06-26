import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'screens/auth.dart';
import 'models/place.dart';
import 'providers/auth_provider.dart' as custom_auth;
import 'providers/places_provider.dart';
import 'screens/home_screen.dart';
import 'widgets/restart_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const RestartWidget(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => custom_auth.AuthProvider()), 
        ChangeNotifierProvider(create: (_) => PlacesProvider()),
        StreamProvider<List<Place>>(
          create: (context) => context.read<PlacesProvider>().placesStream,
          initialData: const [],
        ),
      ],
      child: MaterialApp(
        title: 'Nostalgia',
        debugShowCheckedModeBanner: false,
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              final user = snapshot.data;
              if (user != null && user.emailVerified) {
                return const HomePage();
              } else {
                return const AuthScreen();
              }
            } else {
              return const AuthScreen();
            }
          },
        ),
      ),
    );
  }
}
