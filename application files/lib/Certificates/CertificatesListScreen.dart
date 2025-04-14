import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class Certificate {
  final String id;
  final String name;
  final String date;
  final String category;
  final String subCategory;
  File? file;

  Certificate({
    required this.id,
    required this.name,
    required this.date,
    required this.category,
    required this.subCategory,
    this.file,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'category': category,
      'sub_category': subCategory,
      'file_path': file?.path,
    };
  }

  factory Certificate.fromMap(Map<String, dynamic> map) {
    return Certificate(
      id: map['id'],
      name: map['name'],
      date: map['date'],
      category: map['category'] ?? '',
      subCategory: map['sub_category'] ?? '',
      file: map['file_path'] != null ? File(map['file_path']) : null,
    );
  }
}

class CertificatesListScreen extends StatefulWidget {
  @override
  _CertificatesListScreenState createState() => _CertificatesListScreenState();
}

class _CertificatesListScreenState extends State<CertificatesListScreen> with SingleTickerProviderStateMixin {
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
          'Certificate Categories',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.purple[400],
        elevation: 3,
        shadowColor: Colors.purple.withOpacity(0.4),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Explore Domains",
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[800],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      children: [
                        _buildCategoryCard(context, "ACADEMIC", Icons.school_rounded, Colors.blue[300]!),
                        _buildCategoryCard(context, "OLYMPIAD", Icons.lightbulb_rounded, Colors.amber[300]!),
                        _buildCategoryCard(context, "QUIZCOMP", Icons.quiz_rounded, Colors.teal[300]!),
                        _buildCategoryCard(context, "BIZCOMP", Icons.business_rounded, Colors.orange[300]!),
                        _buildCategoryCard(context, "SPORTS", Icons.accessibility_rounded, Colors.redAccent[200]!),
                        _buildCategoryCard(context, "SKILLS", Icons.build_rounded, Colors.grey[400]!),
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

  Widget _buildCategoryCard(BuildContext context, String category, IconData icon, Color color) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AcademicSubCategoryScreen(category: category),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(width: 20),
              Text(
                category,
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[600]),
            ],
          ),
        ),
      ),
    );
  }
}

class AcademicSubCategoryScreen extends StatefulWidget {
  final String category;

  AcademicSubCategoryScreen({required this.category});

  @override
  _AcademicSubCategoryScreenState createState() => _AcademicSubCategoryScreenState();
}

class _AcademicSubCategoryScreenState extends State<AcademicSubCategoryScreen> {
  final List<String> academicSubCategories = ["SSC", "HSC", "UNDER GRAD", "GRAD", "PHD", "POST DOC"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[400],
        elevation: 3,
        shadowColor: Colors.blue.withOpacity(0.4),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Academic Paths",
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: academicSubCategories.length,
                    itemBuilder: (context, index) {
                      final subCategory = academicSubCategories[index];
                      return _buildSubCategoryCard(context, widget.category, subCategory, index);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubCategoryCard(BuildContext context, String category, String subCategory, int index) {
    final colors = [Colors.lightBlue[300]!, Colors.blueAccent[200]!];
    final startColor = colors[index % colors.length];
    final endColor = colors[(index + 1) % colors.length];

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CertificateUploadScreen(category: category, subCategory: subCategory),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [startColor, endColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(Icons.book_rounded, size: 32, color: Colors.white),
              const SizedBox(width: 20),
              Text(
                subCategory,
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}

class CertificateUploadScreen extends StatefulWidget {
  final String category;
  final String subCategory;

  CertificateUploadScreen({required this.category, required this.subCategory});

  @override
  _CertificateUploadScreenState createState() => _CertificateUploadScreenState();
}

class _CertificateUploadScreenState extends State<CertificateUploadScreen> {
  List<Certificate> certificates = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCertificates(widget.category, widget.subCategory);
  }

  Future<void> _loadCertificates(String category, String subCategory) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? certStrings = prefs.getStringList('certificates');
    if (certStrings != null) {
      setState(() {
        certificates = certStrings
            .map((cert) => Certificate.fromMap(json.decode(cert)))
            .where((cert) => cert.category == category && cert.subCategory == subCategory)
            .toList();
      });
    } else {
      setState(() {
        certificates = [];
      });
    }
  }

  Future<void> _uploadAndRename() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      await _showRenameDialog(file, widget.category, widget.subCategory);
    }
  }

  Future<void> _showRenameDialog(File file, String category, String subCategory) async {
    TextEditingController _nameController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Name Your Document'),
          content: SingleChildScrollView(
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Document Name'),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                if (_nameController.text.isNotEmpty) {
                  final cert = Certificate(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text,
                    date: DateTime.now().toString(),
                    category: category,
                    subCategory: subCategory,
                    file: file,
                  );
                  setState(() {
                    certificates.add(cert);
                  });
                  await _saveCertificates();
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a document name')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveCertificates() async {
    final prefs = await SharedPreferences.getInstance();
    final updatedList = certificates.map((c) => json.encode(c.toMap())).toList();
    await prefs.setStringList('certificates', updatedList);
  }

  Future<void> _renameCertificate(Certificate certificate) async {
    TextEditingController _renameController = TextEditingController(text: certificate.name);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rename Document'),
          content: SingleChildScrollView(
            child: TextField(
              controller: _renameController,
              decoration: InputDecoration(labelText: 'New Name'),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Keep Same'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Rename'),
              onPressed: () async {
                if (_renameController.text.isNotEmpty) {
                  setState(() {
                    final index = certificates.indexOf(certificate);
                    if (index != -1) {
                      certificates[index] = Certificate(
                        id: certificate.id,
                        name: _renameController.text,
                        date: certificate.date,
                        category: certificate.category,
                        subCategory: certificate.subCategory,
                        file: certificate.file,
                      );
                    }
                  });
                  await _saveCertificates();
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a new name')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text(
        widget.subCategory,
        style: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        fontSize: 24,
        color: Colors.white,
    ),
    ),
    backgroundColor: Colors.green[400],
    elevation: 3,
    shadowColor: Colors.green.withOpacity(0.4),
    ),
    body: Container(
    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: [Colors.green[50]!, Colors.white],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    ),
    ),
    child: SafeArea(
    child: Padding(
    padding: const EdgeInsets.all(25.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    "Welcome to ${widget.subCategory}!",
    style: GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.green[800],
    letterSpacing: 0.5,
    ),
    ),
    const SizedBox(height: 20),
    ElevatedButton.icon(
    onPressed: _uploadAndRename,
    icon: Icon(Icons.cloud_upload_rounded, color: Colors.white),
    label: Text("Upload Document", style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green[600],
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    ),
    ),
    const SizedBox(height: 30),
    Text(
    "Your Documents:",
    style: GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
    ),
    ),
    const SizedBox(height: 10),
    Expanded(
    child: certificates.isEmpty
    ? Center(
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(Icons.folder_open_rounded, size: 60, color: Colors.grey[400]),
    const SizedBox(height: 10),
    Text("No documents uploaded here yet.", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
    ],
    ),
    )
        : ListView.builder(
    physics: BouncingScrollPhysics(),
    itemCount: certificates.length,
    itemBuilder: (context, index) {
    final cert = certificates[index];
    return _buildUploadedDocumentCard(cert);
    },
    ),

    ),
      ],
    ),
    ),
    ),
    ),
    );
  }

  Widget _buildUploadedDocumentCard(Certificate cert) {
    return GestureDetector(
      onDoubleTap: () => _renameCertificate(cert),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.insert_drive_file_rounded, size: 30, color: Colors.blueAccent),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cert.name,
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Uploaded on: ${cert.date.substring(0, 10)}",
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit_outlined, color: Colors.grey[600]),
                onPressed: () => _renameCertificate(cert),
              ),
            ],
          ),
        ),
      ),
    );
  }
}