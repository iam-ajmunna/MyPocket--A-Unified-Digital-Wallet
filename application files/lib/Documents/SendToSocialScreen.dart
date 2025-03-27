import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

class SendToSocialScreen extends StatelessWidget {
  Future<void> _shareContent() async {
    await Share.share('Check out my certificate: [Link or Text]');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send to WhatsApp/Messenger'),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ElevatedButton(
            onPressed: _shareContent,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: Text("Share via WhatsApp/Messenger", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}