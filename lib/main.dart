import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:she_fit_app/firebase_options.dart';
import 'package:she_fit_app/homepage/homepage.dart'; // Import the HomePage widget

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'She-Fit',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
     initialRoute: '/home', // Set the initial route to login
      routes: {
        '/home': (context) => HomePage(),
      },
    );
  }
}