import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'ScanCertificatesScreen.dart';
import 'CertificatesListScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mypocket/Home/WalletScreen.dart'; // Assuming WalletScreen is your home screen
import 'package:share_plus/share_plus.dart'; // Import the share_plus package
import 'package:lottie/lottie.dart'; // Import Lottie for animations

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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Digital Certificates',
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
            icon: Icon(Icons.home_rounded, color: Colors.purple[800], size: 30),
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
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Manage Smartly",
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Access and organize your important documents effortlessly.",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Expanded(
                    child: GridView.count(
                      physics: BouncingScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildFeatureCard(
                          context,
                          icon: Icons.list_alt_rounded,
                          title: "View All",
                          subtitle: "Your Stored Certificates",
                          gradient: LinearGradient(colors: [Colors.blue[400]!, Colors.blue[600]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          onTap: () => _navigateTo(context, CertificatesListScreen()),
                        ),
                        _buildFeatureCard(
                          context,
                          icon: Icons.camera_alt_rounded,
                          title: "Scan New",
                          subtitle: "Capture and Save",
                          gradient: LinearGradient(colors: [Colors.green[400]!, Colors.green[600]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          onTap: () => _navigateTo(context, ScanCertificatesScreen()),
                        ),
                        _buildFeatureCard(
                          context,
                          icon: Icons.cloud_upload_rounded,
                          title: "Drive Backup",
                          subtitle: "Secure Online Storage",
                          gradient: LinearGradient(colors: [Colors.orange[400]!, Colors.orange[600]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          onTap: _navigateToGoogleDrive,
                        ),
                        _buildFeatureCard(
                          context,
                          icon: Icons.share_rounded,
                          title: "Quick Share",
                          subtitle: "Send to Others",
                          gradient: LinearGradient(colors: [Colors.purple[400]!, Colors.purple[600]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          onTap: () async {
                            await Share.share('Check out my certificate: [Link or Text]');
                            print("Sharing initiated");
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Opacity(
                      opacity: 0.7,
                      child: Text(
                        "Keep your important documents safe and accessible.",
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
                      ),
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

  Widget _buildFeatureCard(
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
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 48),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
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