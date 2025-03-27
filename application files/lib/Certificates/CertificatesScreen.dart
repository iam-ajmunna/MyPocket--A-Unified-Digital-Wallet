import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mypocket/Documents/SendToSocialScreen.dart';
import 'package:mypocket/Documents/UploadToDriveScreen.dart';
import 'ScanCertificatesScreen.dart';
import 'CertificatesListScreen.dart';

class CertificatesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Certificates & Vaccine Cards'),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Manage Your Certificates",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionTile(
              context,
              icon: Icons.list,
              title: "Certificates List",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CertificatesListScreen()),
                );
              },
            ),
            _buildOptionTile(
              context,
              icon: Icons.camera_alt,
              title: "Scan Certificates",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScanCertificatesScreen()),
                );
              },
            ),
            _buildOptionTile(
              context,
              icon: Icons.cloud_upload,
              title: "Upload to Drive",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UploadToDriveScreen()),
                );
              },
            ),
            _buildOptionTile(
              context,
              icon: Icons.share,
              title: "Send to WhatsApp/Messenger",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SendToSocialScreen()),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildOptionTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.purple, size: 30),
            const SizedBox(width: 15),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 4, // Assuming Certificates is the 5th option (index 4)
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/bkash');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/mobile-topup');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/wallet');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/payments');
            break;
          case 4:
          // Already on CertificatesScreen
            break;
        }
      },
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.grey,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'bKash Pay'),
        BottomNavigationBarItem(icon: Icon(Icons.phone_android), label: 'Mobile Top-Up'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.payments), label: 'Payments'),
        BottomNavigationBarItem(icon: Icon(Icons.verified_user), label: 'Certificates'),
      ],
    );
  }
}