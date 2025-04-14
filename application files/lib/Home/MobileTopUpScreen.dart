import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'transaction.dart';
import 'WalletScreen.dart';
import 'PaymentsScreen.dart';
import 'bkashpayscreen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class MobileTopUpScreen extends StatefulWidget {
  @override
  _MobileTopUpScreenState createState() => _MobileTopUpScreenState();
}

class _MobileTopUpScreenState extends State<MobileTopUpScreen> {
  int _selectedIndex = 1; // Default to "Mobile Top-Up"
  final _mobileNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final _pinController = TextEditingController();

  // Variables for user inputs
  String _mobileNumber = '';
  double _amount = 0.0;
  String _pin = '';

  // Validation error messages
  String? _mobileNumberError;
  String? _amountError;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BkashPayScreen()),
        );
        break;
      case 1:
        // Already on MobileTopUpScreen
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WalletScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PaymentsScreen()),
        );
        break;
      case 4:
        // Handle Transfer navigation
        break;
      default:
        break;
    }
  }

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
      _mobileNumberError = null;
      _amountError = null;
    });

    _mobileNumber = _mobileNumberController.text;
    _amount = double.tryParse(_amountController.text) ?? 0.0;

    if (_mobileNumber.length != 11 || !_mobileNumber.startsWith('01')) {
      setState(() {
        _mobileNumberError =
            'Mobile number must be 11 digits and start with 01';
      });
      return false;
    }

    if (_amount <= 0 || _amount > 1000) {
      setState(() {
        _amountError = 'Amount must be between 1 and 1000';
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
                // Corrected PIN verification
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
        'Mobile Top-Up',
        _amount,
        'Success',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Top-Up successful!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear fields
      _mobileNumberController.clear();
      _amountController.clear();
      _pinController.clear();

      // Clear error messages
      setState(() {
        _mobileNumberError = null;
        _amountError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mobile Top-Up',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:Color.fromARGB(241, 244, 248, 255),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 80,
            ),
            Container(
              child: Image.asset(
                'Mobile-Top-Up.png',
                width: 450,
                height: 220,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _mobileNumberController,
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                labelStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                errorText: _mobileNumberError,
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
