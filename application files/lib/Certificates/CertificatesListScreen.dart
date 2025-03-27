import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

class _CertificatesListScreenState extends State<CertificatesListScreen> {
  List<Certificate> certificates = [];

  @override
  void initState() {
    super.initState();
    _loadCertificates();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Certificates List'),
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
        child: certificates.isEmpty
            ? Center(
          child: Text(
            'No certificates added yet.',
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 18),
          ),
        )
            : ListView.builder(
          itemCount: certificates.length,
          itemBuilder: (context, index) {
            final cert = certificates[index];
            return Card(
              color: Colors.grey[900],
              margin: EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: Text(
                  cert.name,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
                ),
                subtitle: Text(
                  'Date: ${cert.date}',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}