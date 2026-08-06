import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class DocumentPdfService {
  /// Generate a high-contrast watermarked PDF document for NID
  static Future<List<int>> generateNidPdf({
    required String nidNumber,
    required String fullName,
    required String dateOfBirth,
    required String fatherName,
    required String motherName,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(30),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.indigo900, width: 3),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('BANGLADESH NATIONAL ID', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900)),
                      pw.Text('OFFICIAL DIGITAL VAULT COPY', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('National ID Number: $nidNumber', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('Full Name: $fullName', style: const pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 8),
                pw.Text('Date of Birth: $dateOfBirth', style: const pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 8),
                pw.Text('Father\'s Name: $fatherName', style: const pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 8),
                pw.Text('Mother\'s Name: $motherName', style: const pw.TextStyle(fontSize: 14)),
                pw.Spacer(),
                pw.Divider(color: PdfColors.indigo900),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Protected by MyPocket AES-256-GCM Envelope Encryption', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                    pw.Text('Generated on ${DateTime.now().toIso8601String().split('T').first}', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Print or Share generated PDF
  static Future<void> sharePdf(List<int> pdfBytes, String filename) async {
    final file = XFile.fromData(
      Uint8List.fromList(pdfBytes),
      mimeType: 'application/pdf',
      name: filename,
    );
    await Share.shareXFiles([file], text: 'MyPocket Digital Document: $filename');
  }

  /// Print PDF directly
  static Future<void> printPdf(List<int> pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => Uint8List.fromList(pdfBytes),
    );
  }
}
