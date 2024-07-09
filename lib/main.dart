import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nostalgia/core/widgets/restart_widget.dart';
import 'package:nostalgia/features/auth/presentation/screens/auth.dart';
import 'package:nostalgia/features/home/presentation/screens/home_screen.dart';
import 'package:nostalgia/features/places/data/model/place.dart';
import 'package:nostalgia/features/places/data/providers/places_provider.dart';
import 'package:nostalgia/features/auth/data/providers/auth_provider.dart' as custom_auth;
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const RestartWidget(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => custom_auth.AuthProvider()), 
        ChangeNotifierProvider(create: (_) => PlacesProvider()),
        
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