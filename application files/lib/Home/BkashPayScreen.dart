import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'transaction.dart';
import 'WalletScreen.dart';
import 'PaymentsScreen.dart';
import 'MobileTopUpScreen.dart';

class BkashPayScreen extends StatefulWidget {
  @override
  _BkashPayScreenState createState() => _BkashPayScreenState();
}

class _BkashPayScreenState extends State<BkashPayScreen> {
  int _selectedIndex = 0; // Default to "bKash Pay"
  final _bkashIdController = TextEditingController();
  final _amountController = TextEditingController();
  final _pinController = TextEditingController();
  String? selectedCard;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
      // Already on BkashPayScreen
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MobileTopUpScreen()),
        );
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

  Future<void> _addTransaction(String type, double amount, String status) async {
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

  void _confirmTransaction() async {
    if (_bkashIdController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show PIN confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Transaction'),
          content: TextField(
            controller: _pinController,
            decoration: InputDecoration(
              labelText: 'Enter PIN',
              labelStyle: TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            style: TextStyle(color: Colors.white),
            obscureText: true,
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
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
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Add transaction to history
      _addTransaction(
        'bKash Pay',
        double.parse(_amountController.text),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('bKash Pay'),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // bKash Logo
            Container(
              color: Colors.white, // White background for the image
              child: Image.asset(
                'assets/bkash_logo_new.png', // Add bKash logo to your assets folder
                width: 250,
                height: 80,
              ),
            ),
            const SizedBox(height: 20),
            // bKash ID Input
            TextField(
              controller: _bkashIdController,
              decoration: InputDecoration(
                labelText: 'bKash ID (Mobile Number)',
                labelStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            // Amount Input
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            // Transfer Button
            ElevatedButton(
              onPressed: _confirmTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.grey,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.payment),
          label: 'bKash Pay',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.phone_android),
          label: 'Mobile Top-Up',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payments),
          label: 'Payments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.compare_arrows),
          label: 'Transfer',
        ),
      ],
    );
  }
}