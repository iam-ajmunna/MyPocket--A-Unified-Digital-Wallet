import 'package:flutter/material.dart';
import 'package:mypocket/Auth/LoginScreen.dart';
import 'package:mypocket/Home/WalletScreen.dart';

void main() {
  runApp(MyApp());
}

// Note For Me
/* Calling MyApp and Returning Material app for widgets
   Calling Log In Screen
 */

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.purple,
          scaffoldBackgroundColor: const Color.fromARGB(255, 248, 248, 248)),
        home: LoginScreen(),
    );
  }
}
