import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'CertificatesListScreen.dart';

class ScanCertificatesScreen extends StatefulWidget {
  @override
  _ScanCertificatesScreenState createState() => _ScanCertificatesScreenState();
}

class _ScanCertificatesScreenState extends State<ScanCertificatesScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isCameraReady = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
    setState(() {
      _isCameraReady = true;
    });
  }

  Future<void> _saveCertificate(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final cert = Certificate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      date: DateTime.now().toString(),
    );
    final List<String> certStrings = prefs.getStringList('certificates') ?? [];
    certStrings.add(json.encode(cert.toMap()));
    await prefs.setStringList('certificates', certStrings);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Certificates'),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _isCameraReady
                  ? FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CameraPreview(_controller);
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              )
                  : Center(child: CircularProgressIndicator()),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await _initializeControllerFuture;
                    final image = await _controller.takePicture();
                    await _saveCertificate("Scanned Certificate");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Certificate scanned and saved!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: Text("Scan", style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}