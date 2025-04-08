import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mypocket/Documents/SendToSocialScreen.dart';
import 'package:mypocket/Documents/UploadToDriveScreen.dart';
import 'ScanCertificatesScreen.dart';
import 'CertificatesListScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Certificates & Cards',
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
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home'); // Assuming '/home' is your home route
            },
            tooltip: 'Go to Home',
          ),
        ],
      ),
      body: Container(
        color: Colors.white, // Changed from gradient to solid white
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
                      color: Colors.black, // Changed from white to black for visibility
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    "Scan, store, and share effortlessly",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600], // Changed from grey[300] to grey[600] for better contrast
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
                          onTap: () => _navigateTo(context, UploadToDriveScreen()),
                        ),
                        _buildOptionTile(
                          context,
                          icon: Icons.share_outlined,
                          title: "Share to Social",
                          subtitle: "Send via WhatsApp or more",
                          gradient: LinearGradient(colors: [Colors.purple[600]!, Colors.purple[300]!]),
                          onTap: () => _navigateTo(context, SendToSocialScreen()),
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
      bottomNavigationBar: _buildBottomNavigationBar(context),
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

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 4,
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
              break;
          }
        },
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.purple[400],
        unselectedItemColor: Colors.grey[500],
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.payment, size: 28),
            label: 'bKash',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone_iphone, size: 28),
            label: 'Top-Up',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined, size: 28),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long, size: 28),
            label: 'Payments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified, size: 28),
            label: 'Certificates',
          ),
        ],
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