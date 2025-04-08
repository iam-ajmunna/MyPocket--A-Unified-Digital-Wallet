import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class Certificate {
  final String id;
  final String name;
  final String date;
  final String? filePath; // Path to stored file

  Certificate({
    required this.id,
    required this.name,
    required this.date,
    this.filePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'filePath': filePath,
    };
  }

  factory Certificate.fromMap(Map<String, dynamic> map) {
    return Certificate(
      id: map['id'],
      name: map['name'],
      date: map['date'],
      filePath: map['filePath'],
    );
  }
}

class CertificatesListScreen extends StatefulWidget {
  @override
  _CertificatesListScreenState createState() => _CertificatesListScreenState();
}

class _CertificatesListScreenState extends State<CertificatesListScreen> with SingleTickerProviderStateMixin {
  List<Certificate> certificates = [];
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker(); // Instance of ImagePicker

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
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final List<String>? certStrings = prefs.getStringList('certificates');
    if (certStrings != null) {
      setState(() {
        certificates = certStrings.map((cert) => Certificate.fromMap(json.decode(cert))).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _isLoading = true;
        });

        File sourceFile = File(pickedFile.path);
        final fileName = path.basename(sourceFile.path);

        final appDir = await getApplicationDocumentsDirectory();
        final targetPath = path.join(appDir.path, 'certificates', fileName);
        final targetDir = Directory(path.dirname(targetPath));
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }
        await sourceFile.copy(targetPath);

        final newCert = Certificate(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: fileName,
          date: DateTime.now().toString().substring(0, 10),
          filePath: targetPath,
        );

        setState(() {
          certificates.add(newCert);
        });
        await _saveCertificates();

        setState(() {
          _isLoading = false;
        });
        _showSnackBar(context, "Image certificate added successfully", Colors.green);
      } else {
        setState(() {
          _isLoading = false;
        });
        // User cancelled image picking
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar(context, "Error uploading image: ${e.toString()}", Colors.red);
      print("Image upload error: $e");
    }
  }

  Future<void> _saveCertificates() async {
    final prefs = await SharedPreferences.getInstance();
    final updatedList = certificates.map((c) => json.encode(c.toMap())).toList();
    await prefs.setStringList('certificates', updatedList);
  }

  Future<void> _openCertificate(Certificate cert) async {
    if (cert.filePath != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Open Certificate"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("File: ${cert.name}"),
              SizedBox(height: 8),
              Text("Path: ${cert.filePath}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        ),
      );
    } else {
      _showSnackBar(context, "No file associated with this certificate", Colors.orange);
    }
  }

  void _showSnackBar(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
        color: Colors.white,
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
                      color: Colors.black,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    "All your documents in one place",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: _isLoading
                        ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[800]!),
                      ),
                    )
                        : certificates.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 80,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "No image certificates added yet",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Tap the '+' button to upload images!",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[700],
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
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndUploadImage, // Call the image-specific upload function
        backgroundColor: Colors.purple[700],
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Upload Image Certificate',
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
          color: Colors.red[600],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      onDismissed: (direction) async {
        if (cert.filePath != null) {
          try {
            final file = File(cert.filePath!);
            if (await file.exists()) {
              await file.delete();
            }
          } catch (e) {
            print("Error deleting file: $e");
            _showSnackBar(context, "Error deleting image", Colors.red);
          }
        }

        setState(() {
          certificates.removeAt(index);
        });

        await _saveCertificates();
        _showSnackBar(context, "${cert.name} removed", Colors.red[400]!);
      },
      child: GestureDetector(
        onTap: () => _openCertificate(cert),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(cert.name),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.image_outlined, color: _getIconColor(cert.name), size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cert.name,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Date: ${cert.date}",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (cert.filePath != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(Icons.attach_file, size: 12, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Text(
                              "File attached",
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.arrow_circle_right, color: Colors.grey[600], size: 26),
            ],
          ),
        ),
      ),
    );
  }

  Color _getIconColor(String fileName) {
    return Colors.blue[700]!;
  }

  Color _getIconBackgroundColor(String fileName) {
    return Colors.blue[50]!;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    home: CertificatesListScreen(),
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