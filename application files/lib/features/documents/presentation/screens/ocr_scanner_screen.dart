import 'package:flutter/material.dart';
import '../services/ocr_parser_service.dart';

class OcrScannerScreen extends StatefulWidget {
  final String documentType; // 'NID' or 'PASSPORT'
  final Function(OcrParsedResult result) onScanned;

  const OcrScannerScreen({
    super.key,
    required this.documentType,
    required this.onScanned,
  });

  @override
  State<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends State<OcrScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isScanning = true;
  OcrParsedResult? _parsedResult;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Simulate camera scan detection after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        final mockText = widget.documentType == 'NID'
            ? 'BANGLADESH NATIONAL ID\nName: MD. TANVIR HOSSAIN\nFather: MD. ABUL HOSSAIN\nMother: JAHANARA BEGUM\nDOB: 15-05-1995\nNID NO: 1995123456789'
            : 'PASSPORT BANGLADESH\nType: P Country: BGD\nPassport No: A09876543\nName: MD. TANVIR HOSSAIN\nDOB: 15-05-1995 Expiry: 2030-12-31';

        final result = widget.documentType == 'NID'
            ? OcrParserService.parseNid(mockText)
            : OcrParserService.parsePassport(mockText);

        setState(() {
          _isScanning = false;
          _parsedResult = result;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: Text(
          'Scan ${widget.documentType}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Camera Preview Frame Simulation
          Container(
            color: Colors.black87,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: widget.documentType == 'NID' ? 220 : 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isScanning ? const Color(0xFF6366F1) : const Color(0xFF10B981),
                    width: 3,
                  ),
                ),
                child: Stack(
                  children: [
                    if (_isScanning)
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Positioned(
                            top: _animationController.value * (widget.documentType == 'NID' ? 200 : 280),
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 3,
                              decoration: const BoxDecoration(
                                color: Color(0xFF6366F1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF6366F1),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Scan Instruction & Result Sheet
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              children: [
                if (_isScanning)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Color(0xFF6366F1), strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Align ${widget.documentType} within frame...',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )
                else if (_parsedResult != null)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 24),
                            SizedBox(width: 8),
                            Text(
                              'OCR Field Extraction Successful',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (widget.documentType == 'NID') ...[
                          Text('NID No: ${_parsedResult!.nidNumber}', style: const TextStyle(color: Colors.white70)),
                          Text('Name: ${_parsedResult!.fullName}', style: const TextStyle(color: Colors.white70)),
                          Text('DOB: ${_parsedResult!.dateOfBirth}', style: const TextStyle(color: Colors.white70)),
                        ] else ...[
                          Text('Passport No: ${_parsedResult!.passportNumber}', style: const TextStyle(color: Colors.white70)),
                          Text('Name: ${_parsedResult!.fullName}', style: const TextStyle(color: Colors.white70)),
                          Text('Expiry: ${_parsedResult!.expiryDate}', style: const TextStyle(color: Colors.white70)),
                        ],
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () {
                              widget.onScanned(_parsedResult!);
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Auto-Fill & Review Details',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
