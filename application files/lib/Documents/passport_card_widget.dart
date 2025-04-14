// In: lib/documents/passport_card_widget.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:qr_flutter/qr_flutter.dart'; // Import QR code package

class PassportCardWidget extends StatefulWidget {
  @override
  _PassportCardWidgetState createState() => _PassportCardWidgetState();
}

class _PassportCardWidgetState extends State<PassportCardWidget> {
  Map<String, String> passportData = {};
  bool _isTapped = false;

  @override
  void initState() {
    super.initState();
    _loadPassportData();
  }

  Future<void> _loadPassportData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('Passport_data');
    if (savedData != null) {
      setState(() {
        passportData = Map<String, String>.from(jsonDecode(savedData));
      });
    }
  }

  Widget _buildCardContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(passportData['rename'] ?? 'Passport', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              Icon(Icons.flight, size: 30, color: Colors.white70), // Added flight icon
            ],
          ),
          Divider(color: Colors.white54),
          Text('Name: ${passportData['passport_name'] ?? 'Not Added'}', style: TextStyle(color: Colors.white)),
          Text('Passport No: ${passportData['passport_number'] ?? 'Not Added'}', style: TextStyle(color: Colors.white)),
          Text('Expiry: ${passportData['passport_expiry'] ?? 'Not Added'}', style: TextStyle(color: Colors.white)),
          SizedBox(height: 12),
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(Icons.security, size: 24, color: Colors.white70), // Added security icon
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(passportData['rename'] ?? 'Passport - Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _isTapped = false;
                    });
                  },
                ),
              ],
            ),
            Divider(),
            Text('Full Name: ${passportData['passport_name'] ?? 'Not Added'}'),
            Text('Passport Number: ${passportData['passport_number'] ?? 'Not Added'}'),
            Text('Expiry Date: ${passportData['passport_expiry'] ?? 'Not Added'}'),
            Text('Place of Birth: ${passportData['passport_pob'] ?? 'Not Added'}'), // Example extra field
            Text('Issuing Authority: ${passportData['passport_issuer'] ?? 'Not Added'}'), // Example extra field
            SizedBox(height: 20),
            Center(
              child: QrImageView(
                data: jsonEncode(passportData), // Encode all passport data
                version: QrVersions.auto,
                size: 100.0,
                embeddedImageStyle: QrEmbeddedImageStyle(
                  size: Size(20, 20),
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(child: Text('Scan to Share', style: TextStyle(fontSize: 12))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Matrix4 transform = _isTapped
        ? Matrix4.identity()
        : Matrix4.identity()
      ..setEntry(3, 2, 0.001) // Perspective
      ..rotateY(-0.02 * math.pi) // Subtle Y-axis rotation (opposite direction for variation)
      ..rotateX(-0.01 * math.pi); // Subtle X-axis rotation (opposite direction for variation)

    return GestureDetector(
      onTap: () {
        setState(() {
          _isTapped = !_isTapped;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        transform: transform,
        child: Card(
          elevation: 4,
          color: Colors.blue[300], // Different base color for passport
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: _isTapped ? _buildDetailedInfo() : _buildCardContent(),
          ),
        ),
      ),
    );
  }
}