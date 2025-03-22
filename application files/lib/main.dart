import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'welcomescreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFF0F0F10),
      ),
      home: WelcomeScreen(),
    );
  }
}