import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class ScanCertificatesScreen extends StatefulWidget {
  @override
  _ScanCertificatesScreenState createState() => _ScanCertificatesScreenState();
}

class _ScanCertificatesScreenState extends State<ScanCertificatesScreen> with SingleTickerProviderStateMixin {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isCameraReady = false;
  bool _flashOn = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _initializeCamera();
    _animationController.forward();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _controller = CameraController(cameras[0], ResolutionPreset.high);
      _initializeControllerFuture = _controller.initialize();
      await _initializeControllerFuture;
      setState(() {
        _isCameraReady = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera initialization failed: $e')),
      );
    }
  }

  Future<void> _saveCertificate(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final cert = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'date': DateTime.now().toString().split('.')[0],
    };
    final List<String> certStrings = prefs.getStringList('certificates') ?? [];
    certStrings.add(json.encode(cert));
    await prefs.setStringList('certificates', certStrings);
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan Certificates',
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF2A2A4E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _isCameraReady
                      ? FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: CameraPreview(_controller),
                            ),
                            _buildOverlay(),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Camera Error",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              color: Colors.red[400],
                            ),
                          ),
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[400]!),
                          ),
                        );
                      }
                    },
                  )
                      : Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[400]!),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: Icons.camera_alt,
                        label: "Scan",
                        gradient: LinearGradient(colors: [Colors.green[600]!, Colors.green[300]!]),
                        onPressed: _scanCertificate,
                      ),
                      _buildActionButton(
                        icon: _flashOn ? Icons.flash_on : Icons.flash_off,
                        label: "Flash",
                        gradient: LinearGradient(colors: [Colors.yellow[600]!, Colors.yellow[300]!]),
                        onPressed: _toggleFlash,
                      ),
                      _buildActionButton(
                        icon: Icons.flip_camera_android,
                        label: "Switch",
                        gradient: LinearGradient(colors: [Colors.blue[600]!, Colors.blue[300]!]),
                        onPressed: _switchCamera,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.greenAccent, width: 2),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Color(0x4C000000), // Replaced Colors.black.withOpacity(0.3)
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.document_scanner, color: Colors.white70, size: 50),
            const SizedBox(height: 10),
            Text(
              "Align certificate within frame",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.black45,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ).copyWith(
        overlayColor: WidgetStateProperty.all(Color(0x1AFFFFFF)), // Replaced Colors.white.withOpacity(0.1)
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanCertificate() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      await _saveCertificate("Scanned Certificate - ${DateTime.now().toString().split('.')[0]}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Certificate scanned and saved!',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e', style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _toggleFlash() async {
    try {
      await _initializeControllerFuture;
      setState(() {
        _flashOn = !_flashOn;
      });
      _controller.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Flash error: $e', style: GoogleFonts.poppins(color: Colors.white))),
      );
    }
  }

  Future<void> _switchCamera() async {
    try {
      final cameras = await availableCameras();
      final currentCamera = _controller.description;
      final newCamera = cameras.firstWhere(
            (camera) => camera.lensDirection != currentCamera.lensDirection,
        orElse: () => cameras[0],
      );
      await _controller.dispose();
      _controller = CameraController(newCamera, ResolutionPreset.high);
      _initializeControllerFuture = _controller.initialize();
      setState(() {
        _isCameraReady = false;
      });
      await _initializeControllerFuture;
      setState(() {
        _isCameraReady = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Switch camera error: $e', style: GoogleFonts.poppins(color: Colors.white))),
      );
    }
  }
}

void main() {
  runApp(MaterialApp(home: ScanCertificatesScreen()));
}