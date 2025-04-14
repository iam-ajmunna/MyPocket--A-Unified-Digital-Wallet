import 'package:flutter/material.dart';
import 'nid_card_widget.dart';
import 'passport_card_widget.dart';

class DocumentSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Document Type'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NIDCardWidget()),
                );
              },
              child: Text('NID'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PassportCardWidget()),
                );
              },
              child: Text('Passport'),
            ),
          ],
        ),
      ),
    );
  }
}