import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

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

      final result = await driveApi.files.create(file, uploadMedia: drive.Media(Stream.value(utf8.encode("Sample Certificate")), 16));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploaded to Drive: ${result.name}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload to Drive'),
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
        child: Center(
          child: ElevatedButton(
            onPressed: _uploadToDrive,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: Text("Upload to Google Drive", style: GoogleFonts.poppins(color: Colors.white)),
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