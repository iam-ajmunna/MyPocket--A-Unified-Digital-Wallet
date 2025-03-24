import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'transaction.dart';
import 'WalletScreen.dart';
import 'bkashpayscreen.dart';
import 'MobileTopUpScreen.dart';

class PaymentsScreen extends StatefulWidget {
  @override
  _PaymentsScreenState createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  List<Transaction> transactions = [];
  int _selectedIndex = 3; // Default to "Payments"

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? transactionStrings = prefs.getStringList('transactions');
    if (transactionStrings != null) {
      setState(() {
        transactions = transactionStrings.map((transactionString) {
          return Transaction.fromMap(json.decode(transactionString));
        }).toList();
      });
    }
  }

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
      // Already on PaymentsScreen
        break;
      case 4:
      // Handle Transfer navigation
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payments History'),
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
        child: transactions.isEmpty
            ? Center(
          child: Text(
            'No transactions yet.',
            style: TextStyle(color: Colors.white54, fontSize: 18),
          ),
        )
            : ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return Card(
              color: Colors.grey[900],
              margin: EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(
                  transaction.type,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                subtitle: Text(
                  'Amount: \$${transaction.amount.toStringAsFixed(2)}\nDate: ${transaction.date.toString()}',
                  style: TextStyle(color: Colors.white54),
                ),
                trailing: Text(
                  transaction.status,
                  style: TextStyle(
                    color: transaction.status == 'Success'
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),
            );
          },
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