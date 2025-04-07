import 'package:flutter/material.dart';
import 'package:mypocket/Auth/LoginScreen.dart';
import 'package:mypocket/Home/WalletScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import the generated file


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
    //home: WalletScreen(),
    );
  }
}