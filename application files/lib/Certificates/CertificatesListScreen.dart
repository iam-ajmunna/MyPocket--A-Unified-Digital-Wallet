import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Certificate {
  final String id;
  final String name;
  final String date;

  Certificate({required this.id, required this.name, required this.date});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'date': date};
  }

  factory Certificate.fromMap(Map<String, dynamic> map) {
    return Certificate(
      id: map['id'],
      name: map['name'],
      date: map['date'],
    );
  }
}

class CertificatesListScreen extends StatefulWidget {
  @override
  _CertificatesListScreenState createState() => _CertificatesListScreenState();
}

class _CertificatesListScreenState extends State<CertificatesListScreen> with SingleTickerProviderStateMixin {
  List<Certificate> certificates = [];
  final ImagePicker _picker = ImagePicker();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _loadCertificates();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCertificates() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? certStrings = prefs.getStringList('certificates');
    if (certStrings != null) {
      setState(() {
        certificates = certStrings.map((cert) => Certificate.fromMap(json.decode(cert))).toList();
      });
    }
  }

  // Upload from device (gallery)
  Future<void> _uploadFromDevice() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        final cert = Certificate(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'New Certificate',
          date: DateTime.now().toString(),
        );
        certificates.add(cert); // Adding the uploaded certificate
      });

      final prefs = await SharedPreferences.getInstance();
      final updatedList = certificates.map((c) => json.encode(c.toMap())).toList();
      await prefs.setStringList('certificates', updatedList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Certificates List',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
          ),
        ),
        backgroundColor: Colors.purple[800],
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple[800]!, Colors.purple[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white, // Changed background color to white
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Certificates",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Changed text color to black
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    "All your documents in one place",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600], // Kept a grey color
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _uploadFromDevice,
                    child: Text("Upload Certificate", style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[600], // Use backgroundColor instead of primary
                      foregroundColor: Colors.white, // Text color for button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: certificates.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "No certificates added yet",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Scan or upload to get started!",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                        : ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: certificates.length,
                      itemBuilder: (context, index) {
                        final cert = certificates[index];
                        return _buildCertificateCard(cert, index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCertificateCard(Certificate cert, int index) {
    return Dismissible(
      key: Key(cert.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.red[400]!, Colors.red[600]!]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      onDismissed: (direction) async {
        setState(() {
          certificates.removeAt(index);
        });
        final prefs = await SharedPreferences.getInstance();
        final updatedList = certificates.map((c) => json.encode(c.toMap())).toList();
        await prefs.setStringList('certificates', updatedList);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${cert.name} removed"),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100], // Light grey card background
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[100], // Light blue icon background
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.description, color: Colors.blue[400], size: 34),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cert.name,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87, // Dark text for card
                    ),
                  ),
                  Text(
                    "Date: ${cert.date}",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_circle_right, color: Colors.grey[600], size: 28),
          ],
        ),
      ),
    );
  }
}