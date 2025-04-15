import 'package:flutter/material.dart';
import 'nid_card_widget.dart';
import 'passport_card_widget.dart';
import 'package:mypocket/Home/WalletScreen.dart';
import 'package:flutter/services.dart';

class DocumentSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Documents',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.home_rounded, color: Colors.black87, size: 28),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WalletScreen()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select Your Identity Document',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Choose the document you want to add to your digital wallet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 40.0),
              Expanded(
                child: _buildNIDCard(context),
              ),
              SizedBox(height: 24.0),
              Expanded(
                child: _buildPassportCard(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNIDCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NIDCardWidget()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 5,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Center(
                  child: _buildNIDIcon(),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'National ID Card',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF4776E6).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Color(0xFF4776E6),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add your National ID Card to your digital wallet for easy access',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassportCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PassportCardWidget()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 5,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Center(
                  child: _buildPassportIcon(),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Passport',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF1E3C72).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Color(0xFF1E3C72),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Store your passport information securely in your digital wallet',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom NID ID Card Icon similar to the neon blue ID card image
  Widget _buildNIDIcon() {
    return Container(
      width: 120,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Card outline
          Container(
            width: 120,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          // User icon on left side
          Positioned(
            left: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 30,
                  height: 15,
                  margin: EdgeInsets.only(top: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),

          // Information lines on right side
          Positioned(
            right: 15,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 40, height: 2, color: Colors.white),
                SizedBox(height: 6),
                Container(width: 40, height: 2, color: Colors.white),
                SizedBox(height: 6),
                Container(width: 40, height: 2, color: Colors.white),
                SizedBox(height: 6),
                Container(width: 40, height: 2, color: Colors.white),
              ],
            ),
          ),

          // Verification circle with checkmark
          Positioned(
            bottom: 5,
            right: 5,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Custom Passport Icon similar to the passport image
  Widget _buildPassportIcon() {
    return Container(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Passport book
          Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              color: Color(0xFF172B4D),
              border: Border.all(color: Color(0xFFFFD700), width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Globe icon
          Positioned(
            top: 30,
            child: Container(
              width: 60,
              height: 60,
              child: CustomPaint(
                painter: GlobePainter(),
              ),
            ),
          ),

          // "PASSPORT" text
          Positioned(
            bottom: 20,
            child: Text(
              "PASSPORT",
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          // Camera icon
          Positioned(
            bottom: 5,
            child: Container(
              width: 24,
              height: 14,
              decoration: BoxDecoration(
                color: Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Center(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Color(0xFF172B4D),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for the globe icon on the passport
class GlobePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Color(0xFFFFD700)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw main circle (globe)
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 5,
      paint,
    );

    // Draw horizontal lines
    canvas.drawLine(
      Offset(5, size.height / 2),
      Offset(size.width - 5, size.height / 2),
      paint,
    );

    canvas.drawLine(
      Offset(5, size.height / 4),
      Offset(size.width - 5, size.height / 4),
      paint,
    );

    canvas.drawLine(
      Offset(5, size.height * 3 / 4),
      Offset(size.width - 5, size.height * 3 / 4),
      paint,
    );

    // Draw vertical lines
    canvas.drawLine(
      Offset(size.width / 2, 5),
      Offset(size.width / 2, size.height - 5),
      paint,
    );

    // Draw curved vertical lines for longitude
    final Path path1 = Path();
    path1.moveTo(size.width / 4, 5);
    path1.quadraticBezierTo(size.width / 4, size.height / 2, size.width / 4, size.height - 5);
    canvas.drawPath(path1, paint);

    final Path path2 = Path();
    path2.moveTo(size.width * 3 / 4, 5);
    path2.quadraticBezierTo(size.width * 3 / 4, size.height / 2, size.width * 3 / 4, size.height - 5);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}