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
  CameraController? _controller; // Make _controller nullable
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
      _initializeControllerFuture = _controller!.initialize(); // Use the null-assertion operator
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
    if (_controller != null && _controller!.value.isInitialized) { // Use null check and access value's property
      _controller!.dispose(); // Use null-assertion operator here as well
    }
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
            color: Colors.black87, // Dark text for light background
            shadows: [Shadow(color: Colors.grey.withOpacity(0.2), blurRadius: 2, offset: Offset(0, 1))],
          ),
        ),
        backgroundColor: Colors.grey[200], // Light background for app bar
        elevation: 1, // Subtle shadow
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87), // Dark icons
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200], // Consistent light background
          ),
        ),
      ),
      body: Container(
        color: Colors.white, // White background for the body
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
                            Padding(
                              padding: const EdgeInsets.all(16.0), // Add some padding around the preview
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: AspectRatio(
                                  aspectRatio: 1 / _controller!.value.aspectRatio, // Use null-assertion operator
                                  child: CameraPreview(_controller!), // Use null-assertion operator
                                ),
                              ),
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
                        backgroundColor: Colors.green[500]!, // Solid color button
                        foregroundColor: Colors.white,
                        onPressed: _scanCertificate,
                      ),
                      _buildActionButton(
                        icon: _flashOn ? Icons.flash_on : Icons.flash_off,
                        label: "Flash",
                        backgroundColor: Colors.amber[500]!, // Solid color button
                        foregroundColor: Colors.white,
                        onPressed: _toggleFlash,
                      ),
                      _buildActionButton(
                        icon: Icons.flip_camera_android,
                        label: "Switch",
                        backgroundColor: Colors.blue[500]!, // Solid color button
                        foregroundColor: Colors.white,
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
        width: MediaQuery.of(context).size.width * 0.7, // Slightly smaller overlay
        height: MediaQuery.of(context).size.height * 0.4, // Slightly smaller overlay
        decoration: BoxDecoration(
          border: Border.all(color: Colors.greenAccent, width: 2),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Subtle shadow
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.document_scanner_outlined, color: Colors.black54, size: 40), // Outlined icon
            const SizedBox(height: 10),
            Text(
              "Align certificate within frame",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.black54,
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
    required Color backgroundColor,
    required Color foregroundColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shadowColor: Colors.black26,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foregroundColor, size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanCertificate() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture(); // Use null-assertion operator
      await _saveCertificate("Scanned Certificate - ${DateTime.now().toString().split('.')[0]}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Certificate scanned and saved!',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.green[500],
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
          backgroundColor: Colors.red[500],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    try {
      await _initializeControllerFuture;
      setState(() {
        _flashOn = !_flashOn;
      });
      await _controller!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off); // Use null-assertion operator
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Flash error: $e', style: GoogleFonts.poppins(color: Colors.white))),
      );
    }
  }

  Future<void> _switchCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final currentCamera = _controller?.description;
      CameraDescription newCamera = cameras.first;
      if (currentCamera != null) {
        newCamera = cameras.firstWhere(
              (camera) => camera.lensDirection != currentCamera.lensDirection,
          orElse: () => cameras[0],
        );
      }

      if (_controller != null) {
        await _controller!.dispose(); // Use null-assertion operator
      }
      _controller = CameraController(newCamera, ResolutionPreset.high);
      _initializeControllerFuture = _controller!.initialize(); // Use null-assertion operator
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MaterialApp(
    home: ScanCertificatesScreen(),
    theme: ThemeData(
      primarySwatch: Colors.purple,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[200],
        titleTextStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: Colors.black87,
        ),
        iconTheme: IconThemeData(color: Colors.black87),
        elevation: 1,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.grey[800],
        contentTextStyle: GoogleFonts.poppins(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.purpleAccent),
      textTheme: GoogleFonts.poppinsTextTheme(),
    ),
  ));
}