import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:lottie/lottie.dart'; // Add Lottie animation package

class UploadToDriveScreen extends StatefulWidget {
  @override
  _UploadToDriveScreenState createState() => _UploadToDriveScreenState();
}

class _UploadToDriveScreenState extends State<UploadToDriveScreen> with SingleTickerProviderStateMixin {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [drive.DriveApi.driveFileScope]);
  GoogleSignInAccount? _currentUser;
  File? _selectedLocalFile;
  String? _selectedFileName;
  bool _isUploading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickLocalFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedLocalFile = File(result.files.single.path!);
          _selectedFileName = path.basename(_selectedLocalFile!.path);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No document selected.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> _navigateToGoogleDrive() async {
    const String googleDriveUrl = 'https://drive.google.com/';

    if (await canLaunchUrl(Uri.parse(googleDriveUrl))) {
      await launchUrl(Uri.parse(googleDriveUrl));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open Google Drive.')),
      );
    }
  }

  Future<void> _uploadSelectedFileToDrive() async {
    if (_selectedLocalFile == null || _isUploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a file first.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    if (_currentUser == null) {
      _currentUser = await _googleSignIn.signIn();
      if (_currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign in to Google Drive.')),
        );
        setState(() {
          _isUploading = false;
        });
        return;
      }
    }

    final authHeaders = await _currentUser!.authHeaders;
    final client = GoogleHttpClient(authHeaders);
    final driveApi = drive.DriveApi(client);

    final driveFile = drive.File();
    driveFile.name = _selectedFileName;

    try {
      final uploadResult = await driveApi.files.create(
        driveFile,
        uploadMedia: drive.Media(_selectedLocalFile!.openRead(), _selectedLocalFile!.lengthSync()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploaded to Drive: ${uploadResult.name}')),
      );
      setState(() {
        _selectedLocalFile = null;
        _selectedFileName = null;
        _isUploading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading to Drive: $e')),
      );
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload to Drive',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.purple),
        elevation: 1,
      ),
      body: Stack(
        children: [
          // Subtle Background Pattern (Optional)
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Lottie.asset(
                'assets/animations/subtle_dots.json', // Replace with your Lottie asset path
                repeat: true,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Animated Illustration
                  Lottie.asset(
                    'assets/animations/upload_cloud.json', // Replace with your Lottie asset path
                    height: screenHeight * 0.25,
                    controller: _animationController,
                  ),
                  SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple[400]!, Colors.purple[700]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.4),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _pickLocalFile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 22),
                        textStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.file_upload, color: Colors.white, size: 30),
                          SizedBox(width: 15),
                          Text("Select Document", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (_selectedFileName != null)
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Selected: $_selectedFileName', style: TextStyle(fontSize: 16, color: Colors.black87)),
                      ),
                    ),
                  SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.blue[700]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.4),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _navigateToGoogleDrive,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 22),
                        textStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_upload, color: Colors.white, size: 30),
                          SizedBox(width: 15),
                          Text("DriveUp", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Click "DriveUp" to go to the Google Drive website to log in and manage your files.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GoogleHttpClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleHttpClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}