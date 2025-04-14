import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'ScanCertificatesScreen.dart';
import 'CertificatesListScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mypocket/Home/WalletScreen.dart'; // Assuming WalletScreen is your home screen
import 'package:share_plus/share_plus.dart'; // Import the share_plus package

class CertificatesScreen extends StatefulWidget {
  @override
  _CertificatesScreenState createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Certificates & Cards',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.black87,
            shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.purple[800]),
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.purple[800]),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => WalletScreen(),
                ),
              );
            },
            tooltip: 'Go to Home',
          ),
        ],
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
                    "Your Certificates Hub",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    "Scan, store, and share effortlessly",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      children: [
                        _buildOptionTile(
                          context,
                          icon: Icons.library_books,
                          title: "Certificates List",
                          subtitle: "Browse all your documents",
                          gradient: LinearGradient(colors: [Colors.blue[600]!, Colors.blue[300]!]),
                          onTap: () => _navigateTo(context, CertificatesListScreen()),
                        ),
                        _buildOptionTile(
                          context,
                          icon: Icons.qr_code_scanner,
                          title: "Scan Certificates",
                          subtitle: "Capture new certificates",
                          gradient: LinearGradient(colors: [Colors.green[600]!, Colors.green[300]!]),
                          onTap: () => _navigateTo(context, ScanCertificatesScreen()),
                        ),
                        _buildOptionTile(
                          context,
                          icon: Icons.cloud_circle,
                          title: "Upload to Drive",
                          subtitle: "Securely back up online",
                          gradient: LinearGradient(colors: [Colors.orange[600]!, Colors.orange[300]!]),
                          onTap: _navigateToGoogleDrive, // Call _navigateToGoogleDrive directly
                        ),
                        _buildOptionTile(
                          context,
                          icon: Icons.share_outlined,
                          title: "Share to Social",
                          subtitle: "Send via WhatsApp or more",
                          gradient: LinearGradient(colors: [Colors.purple[600]!, Colors.purple[300]!]),
                          onTap: () async {
                            await Share.share('Check out my certificate: [Link or Text]');
                            print("Sharing initiated");
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required LinearGradient gradient,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color(0x4C000000),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0x33FFFFFF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 34),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_circle_right, color: Colors.white70, size: 28),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
  }
}