// In: lib/documents/nid_card_widget.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:qr_flutter/qr_flutter.dart'; // Import QR code package

class NIDCardWidget extends StatefulWidget {
  @override
  _NIDCardWidgetState createState() => _NIDCardWidgetState();
}

class _NIDCardWidgetState extends State<NIDCardWidget> {
  Map<String, String> nidData = {};
  bool _isTapped = false;

  @override
  void initState() {
    super.initState();
    _loadNIDData();
  }

  Future<void> _loadNIDData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('NID_data');
    if (savedData != null) {
      setState(() {
        nidData = Map<String, String>.from(jsonDecode(savedData));
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
              Text(nidData['rename'] ?? 'NID Card', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Icon(Icons.credit_card, size: 30, color: Colors.grey[600]), // Added icon
            ],
          ),
          Divider(),
          Text('Name: ${nidData['nid_name'] ?? 'Not Added'}'),
          Text('NID Number: ${nidData['nid_number'] ?? 'Not Added'}'),
          Text('Date of Birth: ${nidData['nid_dob'] ?? 'Not Added'}'),
          SizedBox(height: 12),
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(Icons.memory, size: 24, color: Colors.orange[400]),// Added chip-like icon
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
                Text(nidData['rename'] ?? 'NID Card - Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
            Text('Full Name: ${nidData['nid_name'] ?? 'Not Added'}'),
            Text('NID Number: ${nidData['nid_number'] ?? 'Not Added'}'),
            Text('Date of Birth: ${nidData['nid_dob'] ?? 'Not Added'}'),
            Text('Full Address: ${nidData['nid_address'] ?? 'Not Added'}'),
            Text('Place of Birth: ${nidData['nid_pob'] ?? 'Not Added'}'),
            SizedBox(height: 20),
            Center(
              child: QrImageView(
                data: jsonEncode(nidData), // Encode all NID data into QR code
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
      ..rotateY(0.02 * math.pi) // Subtle Y-axis rotation
      ..rotateX(0.01 * math.pi); // Subtle X-axis rotation

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
          elevation: 4, // Increased elevation for better visual
          color: Colors.grey[200],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: _isTapped ? _buildDetailedInfo() : _buildCardContent(),
          ),
        ),
      ),
    );
  }
}