import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class DocumentManagerScreen extends StatefulWidget {
  const DocumentManagerScreen({super.key});

  @override
  _DocumentManagerScreenState createState() => _DocumentManagerScreenState();
}

class _DocumentManagerScreenState extends State<DocumentManagerScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _documents = [];

  Future<void> _scanDocument() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDocumentScreen(documents: _documents),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyPocket'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none),
            onPressed: () {},
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
                _featureTile(Icons.scanner, 'Scan', Colors.greenAccent, _scanDocument),
                _featureTile(Icons.edit, 'Edit', Colors.orangeAccent, _openEditPage),
                _featureTile(Icons.swap_horiz, 'Convert', Colors.lightGreen, () {}),
                _featureTile(Icons.lightbulb, 'Uploaded Document', Colors.amberAccent, () {}),
              ],
            ),
            SizedBox(height: 15),
            Expanded(
              child: _documents.isEmpty
                  ? Center(child: Text('No Documents', style: TextStyle(color: Colors.grey, fontSize: 18)))
                  : ListView.builder(
                itemCount: _documents.length,
                itemBuilder: (context, index) => _documentTile(index),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanDocument,
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.camera_alt),
      ),
    );
  }

  Widget _featureTile(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black87),
            SizedBox(height: 10),
            Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
        subtitle: Text('Secure Sharing Enabled', style: TextStyle(color: Colors.grey)),
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

class EditDocumentScreen extends StatelessWidget {
  final List<File> documents;

  const EditDocumentScreen({super.key, required this.documents});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Documents')),
      body: documents.isEmpty
          ? Center(child: Text('No Documents Available'))
          : ListView.builder(
        itemCount: documents.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(Icons.insert_drive_file, color: Colors.deepPurple),
              title: Text('Document ${index + 1}'),
              subtitle: Text('Tap to Edit'),
              onTap: () {
                // Add functionality to edit document
              },
            ),
          );
        },
      ),
    );
  }
}
