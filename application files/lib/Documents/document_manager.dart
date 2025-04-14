import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flip_card/flip_card.dart';
import 'scan_document.dart';
import 'package:mypocket/Home/WalletScreen.dart';

class DocumentManagerScreen extends StatefulWidget {
  @override
  _DocumentManagerScreenState createState() => _DocumentManagerScreenState();
}

class _DocumentManagerScreenState extends State<DocumentManagerScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> _documents = [];
  Map<File, String> _docCategoryMap = {}; // Document categories

  Future<void> _openCameraToScan() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanCameraScreen(
          onScanned: (File image) async {
            String? category = await _selectCategory();
            if (category != null) {
              setState(() {
                _documents.add(image);
                _docCategoryMap[image] = category;
              });
            }
          },
        ),
      ),
    );
  }

  Future<void> _uploadFromDevice() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      String? category = await _selectCategory();
      if (category != null) {
        File file = File(pickedFile.path);
        setState(() {
          _documents.add(file);
          _docCategoryMap[file] = category;
        });
      }
    }
  }

  Future<String?> _selectCategory() async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Document Category"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ["Aadhaar", "License", "PAN", "Passport", "Other"]
                .map((category) => ListTile(
              title: Text(category),
              onTap: () => Navigator.pop(context, category),
            ))
                .toList(),
          ),
        );
      },
    );
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
              File doc = _documents[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.edit_document, color: Colors.deepPurple),
                  title: Text(_docCategoryMap[doc] ?? 'Document ${index + 1}'),
                  subtitle: Text('Tap to Edit'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteDocument(index),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Edit functionality coming soon!')),
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
              File doc = _documents[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.insert_drive_file, color: Colors.deepPurple),
                  title: Text(_docCategoryMap[doc] ?? 'Document ${index + 1}'),
                  subtitle: Text('Scanned or Uploaded'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.share, color: Colors.blue),
                        onPressed: () => _shareDocument(doc),
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

  Widget documentFlipCard(File file, int index) {
    String fileName = file.path.split('/').last;
    String id = file.path;

    return FlipCard(
      direction: FlipDirection.HORIZONTAL,
      front: Card(
        elevation: 5,
        color: Colors.deepPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          height: 160,
          alignment: Alignment.center,
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_copy_rounded, size: 40, color: Colors.white),
              SizedBox(height: 10),
              Text(
                _docCategoryMap[file] ?? (fileName.length > 20 ? '${fileName.substring(0, 20)}...' : fileName),
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      back: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          height: 160,
          alignment: Alignment.center,
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              QrImageView(
                data: id,
                version: QrVersions.auto,
                size: 80,
              ),
              SizedBox(height: 10),
              Text("Path:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                id.length > 24 ? '${id.substring(0, 24)}...' : id,
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.share, color: Colors.blue),
                    onPressed: () => _shareDocument(file),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteDocument(index),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Documents', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => WalletScreen()),
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
                _featureTile(Icons.upload, 'Upload', Colors.greenAccent, _uploadFromDevice),
                _featureTile(Icons.edit, 'Edit', Colors.orangeAccent, _openEditPage),
                _featureTile(Icons.swap_horiz, 'Convert', Colors.lightGreen, () {}),
                _featureTile(Icons.folder, 'Uploaded Documents', Colors.amberAccent, _showUploadedDocuments),
              ],
            ),
            SizedBox(height: 15),
            Divider(thickness: 1.0),
            SizedBox(height: 15),
            Expanded(
              child: _documents.isEmpty
                  ? Center(child: Text('No Documents', style: TextStyle(color: Colors.grey, fontSize: 18)))
                  : GridView.builder(
                padding: EdgeInsets.only(top: 8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: _documents.length,
                itemBuilder: (context, index) => documentFlipCard(_documents[index], index),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Add new card functionality here
                _addNewCard(context); // Call a function to add new card
              },
              icon: Icon(Icons.add),
              label: Text('Add New Card'),
            ),
          ],
        ),
      ),
    );
  }

  // Function to add a new card
  void _addNewCard(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String cardType = 'Passport'; // Default card type

        return AlertDialog(
          title: Text('Add New Card'),
          content: StatefulBuilder( // Use StatefulBuilder to update dropdown
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DropdownButton<String>(
                    value: cardType,
                    onChanged: (String? newValue) {
                      setState(() {
                        cardType = newValue!;
                      });
                    },
                    items: <String>['Passport', 'NID']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      _uploadNewCard(cardType); // Upload the new card
                    },
                    child: Text('Upload $cardType'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // Function to upload the new card
  Future<void> _uploadNewCard(String cardType) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      setState(() {
        _documents.add(file);
        _docCategoryMap[file] = cardType; // Set the card type as the category
      });
    }
  }
}