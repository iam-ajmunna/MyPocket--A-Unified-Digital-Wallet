import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mypocket/Home/WalletScreen.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'scan_document.dart';

class MyDivider extends StatelessWidget {
  const MyDivider({
    Key? key,
    this.height = 1.0,
    this.thickness = 1.0,
    this.indent = 24.0,
    this.endIndent = 24.0,
    this.color = const Color(0xFFE0E3E7),
  }) : super(key: key);

  final double height;
  final double thickness;
  final double indent;
  final double endIndent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: color,
    );
  }
}

class DocumentManagerScreen extends StatefulWidget {
  @override
  _DocumentManagerScreenState createState() => _DocumentManagerScreenState();
}

class _DocumentManagerScreenState extends State<DocumentManagerScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> _documents = [];

  // Opens camera for scanning
  Future<void> _openCameraToScan() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanCameraScreen(
          onScanned: (File image) {
            setState(() {
              _documents.add(image);
            });
          },
        ),
      ),
    );
  }

  // Upload from device (gallery)
  Future<void> _uploadFromDevice() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _documents.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _shareDocument(File file) async {
    await Share.shareXFiles([XFile(file.path)], text: 'Shared Document');
  }

  void _deleteDocument(int index) {
    setState(() {
      _documents.removeAt(index);
    });
  }

  void _openEditPage() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 400,
          child: _documents.isEmpty
              ? Center(child: Text('No Documents Available'))
              : ListView.builder(
                  itemCount: _documents.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading:
                            Icon(Icons.edit_document, color: Colors.deepPurple),
                        title: Text('Document ${index + 1}'),
                        subtitle: Text('Tap to Edit'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteDocument(index),
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Edit functionality coming soon!')),
                          );
                        },
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  void _showUploadedDocuments() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 400,
          child: _documents.isEmpty
              ? Center(child: Text('No Uploaded Documents'))
              : ListView.builder(
                  itemCount: _documents.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Icon(Icons.insert_drive_file,
                            color: Colors.deepPurple),
                        title: Text('Uploaded Document ${index + 1}'),
                        subtitle: Text('Scanned via Camera'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.share, color: Colors.blue),
                              onPressed: () =>
                                  _shareDocument(_documents[index]),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteDocument(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Documents',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => WalletScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _featureTile(
                    Icons.scanner, 'Scan', Colors.greenAccent, _scanDocument),
                _featureTile(
                    Icons.edit, 'Edit', Colors.orangeAccent, _openEditPage),
                _featureTile(
                    Icons.swap_horiz, 'Convert', Colors.lightGreen, () {}),
                _featureTile(Icons.folder, 'Uploaded Documents',
                    Colors.amberAccent, _showUploadedDocuments),
              ],
            ),
            SizedBox(height: 15),
            MyDivider(),
            SizedBox(height: 15),
            Expanded(
              child: _documents.isEmpty
                  ? Center(
                      child: Text('No Documents',
                          style: TextStyle(color: Colors.grey, fontSize: 18)))
                  : ListView.builder(
                      itemCount: _documents.length,
                      itemBuilder: (context, index) => _documentTile(index),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCameraToScan,
        child: Icon(Icons.camera_alt),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  Widget _featureTile(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black87),
            SizedBox(height: 10),
            Text(label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _documentTile(int index) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 5,
      color: Colors.deepPurple.shade50,
      child: ListTile(
        leading: Icon(Icons.insert_drive_file, color: Colors.deepPurple),
        title: Text('Document ${index + 1}', style: TextStyle(fontSize: 16)),
        subtitle: Text('Secure Sharing Enabled',
            style: TextStyle(color: Colors.grey)),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'Share') {
              _shareDocument(_documents[index]);
            } else if (value == 'Delete') {
              _deleteDocument(index);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'Share', child: Text('Secure Share')),
            PopupMenuItem(value: 'Delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}