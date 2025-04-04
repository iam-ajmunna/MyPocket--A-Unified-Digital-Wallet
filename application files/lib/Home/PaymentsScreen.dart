import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'transaction.dart';
import 'WalletScreen.dart';
import 'bkashpayscreen.dart';
import 'MobileTopUpScreen.dart';
import 'package:intl/intl.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

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
    // _loadTransactionsFromFirebase(); // Commented out Firebase call
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? transactionStrings =
        prefs.getStringList('transactions');
    if (transactionStrings != null) {
      setState(() {
        transactions = transactionStrings.map((transactionString) {
          return Transaction.fromMap(json.decode(transactionString));
        }).toList();

        // Sort transactions by date and time (newest first)
        transactions.sort((a, b) => b.date.compareTo(a.date));
      });
    }
  }

  // Future<void> _loadTransactionsFromFirebase() async {
  //   try {
  //     QuerySnapshot querySnapshot =
  //         await FirebaseFirestore.instance.collection('transactions').get();
  //     setState(() {
  //       transactions = querySnapshot.docs.map((doc) {
  //         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //         return Transaction(
  //           id: doc.id,
  //           type: data['type'],
  //           amount: data['amount'],
  //           date: DateTime.parse(data['date']),
  //           status: data['status'],
  //         );
  //       }).toList();
  //       transactions.sort((a, b) => b.date.compareTo(a.date));
  //     });
  //   } catch (e) {
  //     print('Error loading transactions from Firebase: $e');
  //   }
  // }

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
        title: Text(
          'Payments History',
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
          color: Color.fromARGB(241, 244, 248, 255),
        ),
        child: transactions.isEmpty
            ? Center(
                child: Text(
                  'No transactions yet.',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              )
            : ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  String formattedDate =
                      DateFormat('EEEE, dd-MMM-yy').format(transaction.date);
                  String formattedTime = _formatTime12Hour(transaction.date);

                  if (index == 0 ||
                      transactions[index - 1].date.day !=
                          transaction.date.day ||
                      transactions[index - 1].date.month !=
                          transaction.date.month ||
                      transactions[index - 1].date.year !=
                          transaction.date.year) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            formattedDate,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Card(
                          color: Colors.white,
                          margin: EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(
                              transaction.type,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Amount: \$${transaction.amount.toStringAsFixed(2)}\nTime: $formattedTime',
                              style: TextStyle(color: Colors.grey),
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
                        ),
                      ],
                    );
                  } else {
                    return Card(
                      color: Colors.white,
                      margin: EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(
                          transaction.type,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Amount: \$${transaction.amount.toStringAsFixed(2)}\nTime: $formattedTime',
                          style: TextStyle(color: Colors.grey),
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
                  }
                },
              ),
      ),
    );
  }

  String _formatTime12Hour(DateTime dateTime) {
    int hour = dateTime.hour % 12;
    if (hour == 0) {
      hour = 12;
    }
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String second = dateTime.second.toString().padLeft(2, '0');
    String amPm = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute:$second $amPm';
  }
}
