import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
//import 'package:firebase_auth/firebase_auth.dart';

class UploadToDriveScreen extends StatefulWidget {
  @override
  _UploadToDriveScreenState createState() => _UploadToDriveScreenState();
}

class _UploadToDriveScreenState extends State<UploadToDriveScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [drive.DriveApi.driveFileScope]);
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _uploadToDrive() async {
    if (_currentUser == null) {
      _currentUser = await _googleSignIn.signIn();
    }
    if (_currentUser != null) {
      final authHeaders = await _currentUser!.authHeaders;
      final client = GoogleHttpClient(authHeaders);
      final driveApi = drive.DriveApi(client);

      final file = drive.File();
      file.name = "Certificate_${DateTime.now().millisecondsSinceEpoch}.txt";
      file.mimeType = "text/plain";

      try {
        final result = await driveApi.files.create(file, uploadMedia: drive.Media(Stream.value(utf8.encode("Sample Certificate")), 16));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Uploaded to Drive: ${result.name}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading to Drive: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not signed in to Google.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload to Drive', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey[200],
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        color: Colors.white,
        child: Center(
          child: ElevatedButton(
            onPressed: _uploadToDrive,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purpleAccent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              "Upload to Google Drive",
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ),
        ),
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