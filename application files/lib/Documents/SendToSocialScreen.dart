import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SendToSocialScreen extends StatelessWidget {
  Future<void> _shareContent() async {
    await Share.share('Check out my certificate: [Link or Text]');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send to WhatsApp/Messenger', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey[200], // Light grey for better contrast
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        color: Colors.white,
        child: Center(
          child: ElevatedButton(
            onPressed: _shareContent,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purpleAccent, // A slightly lighter purple
              foregroundColor: Colors.white, // Ensure text is white
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Add some padding
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Slightly rounded corners
            ),
            child: Text(
              "Share via WhatsApp/Messenger",
              style: GoogleFonts.poppins(fontSize: 16), // Slightly larger font
            ),
          ),
        ),
      ),
    );
  }
}