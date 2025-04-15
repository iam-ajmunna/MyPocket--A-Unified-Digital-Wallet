import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mypocket/Home/WalletScreen.dart';
import 'dart:typed_data';

class IdentityCardsPage extends StatefulWidget {
  @override
  _IdentityCardsPageState createState() => _IdentityCardsPageState();
}

class _IdentityCardsPageState extends State<IdentityCardsPage> {
  Uint8List? _nidImageBytes;
  Uint8List? _passportImageBytes;

  Future<void> _pickNidImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _nidImageBytes = bytes;
      });
    }
  }

  Future<void> _pickPassportImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _passportImageBytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Identity Cards', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.deepPurple),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => WalletScreen(),
                ),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Color(0xFFF0F0F0), // Background color from the image
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Scan Your IDs',
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.deepPurple),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(0, 0, 0),
              child: _buildIdCard(
                context,
                'Passport',
                'assets/passport.png',
                _passportImageBytes,
                _pickPassportImage,
              ),
            ),
            SizedBox(height: 20),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              transform: Matrix4.translationValues(0, 0, 0),
              child: _buildIdCard(
                context,
                'NID',
                'assets/bd_nid.jpeg',
                _nidImageBytes,
                _pickNidImage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdCard(
      BuildContext context,
      String title,
      String assetImage,
      Uint8List? imageBytes,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            SizedBox(height: 15),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[100],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageBytes != null
                    ? Image.memory(
                  imageBytes,
                  fit: BoxFit.cover,
                )
                    : Image.asset(
                  assetImage,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Tap to Scan $title',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}