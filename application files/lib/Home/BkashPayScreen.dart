import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'transaction.dart';
import 'WalletScreen.dart';
import 'PaymentsScreen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class BkashPayScreen extends StatefulWidget {
  @override
  _BkashPayScreenState createState() => _BkashPayScreenState();
}

class _BkashPayScreenState extends State<BkashPayScreen> {
  final _bkashIdController = TextEditingController();
  final _amountController = TextEditingController();
  final _pinController = TextEditingController();

  // Variables for user inputs
  String _bkashId = '';
  double _amount = 0.0;
  String _pin = '';

  // Validation error messages
  String? _bkashIdError;
  String? _amountError;

  // Variable for firebase pin
  // String _firebasePin = '';

  Future<void> _addTransaction(
      String type, double amount, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      amount: amount,
      date: DateTime.now(),
      status: status,
    );

    final List<String> transactionStrings =
        prefs.getStringList('transactions') ?? [];
    transactionStrings.add(json.encode(transaction.toMap()));
    await prefs.setStringList('transactions', transactionStrings);
  }

  bool _validateInput() {
    setState(() {
      _bkashIdError = null;
      _amountError = null;
    });

    _bkashId = _bkashIdController.text;
    _amount = double.tryParse(_amountController.text) ?? 0.0;

    if (_bkashId.length != 11 || !_bkashId.startsWith('01')) {
      setState(() {
        _bkashIdError = 'Mobile number must be 11 digits and start with 01';
      });
      return false;
    }

    if (_amount <= 0 || _amount > 50000) {
      setState(() {
        _amountError = 'Amount must be between 1 and 50000';
      });
      return false;
    }

    return true;
  }

  void _confirmTransaction() async {
    if (!_validateInput()) {
      return;
    }

    _pin = _pinController.text;

    // Show PIN confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFE0E3E7),
          title: Text('Confirm Transaction'),
          content: TextField(
            controller: _pinController,
            decoration: InputDecoration(
              labelText: 'Enter PIN',
              labelStyle: TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            style: TextStyle(color: Colors.black),
            obscureText: true,
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.indigoAccent,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Firebase PIN verification (Commented Out)
                // try {
                //   // Retrieve PIN from Firebase
                //   DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc('your_user_id').get();
                //   _firebasePin = userDoc.get('pin');
                //
                //   if (_pinController.text == _firebasePin) {
                //     Navigator.pop(context, true);
                //   } else {
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       SnackBar(
                //         content: Text('Invalid PIN'),
                //         backgroundColor: Colors.red,
                //       ),
                //     );
                //   }
                // } catch (e) {
                //   print('Error verifying PIN from Firebase: $e');
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(
                //       content: Text('Error verifying PIN'),
                //       backgroundColor: Colors.red,
                //     ),
                //   );
                // }

                // Temporary PIN verification (Replace with Firebase)
                if (_pinController.text == '1234') {
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid PIN'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.indigoAccent,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Add transaction to history
      _addTransaction(
        'bKash Pay',
        _amount,
        'Success',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transfer successful!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear fields
      _bkashIdController.clear();
      _amountController.clear();
      _pinController.clear();

      // Clear error messages
      setState(() {
        _bkashIdError = null;
        _amountError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'b',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),
            Text(
              'Kash',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              'Pay',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),
          ],
        ),
        
        backgroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color.fromARGB(241, 244, 248, 255),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 180,
            ),
            Container(
              child: Image.asset(
                'bkash_logo_new.png',
                width: 350,
                height: 120,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _bkashIdController,
              decoration: InputDecoration(
                labelText: 'bKash ID (Mobile Number)',
                labelStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                errorText: _bkashIdError,
              ),
              style: TextStyle(color: Colors.black),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                errorText: _amountError,
              ),
              style: TextStyle(color: Colors.black),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confirmTransaction,
              style: ElevatedButton.styleFrom(
                fixedSize: Size(200, 50),
                backgroundColor: Colors.indigoAccent,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                'Transfer',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
