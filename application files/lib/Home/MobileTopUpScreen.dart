import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mypocket/Home/transaction.dart' as my_transaction;
import 'package:mypocket/Home/WalletScreen.dart';
import 'package:mypocket/Home/PaymentsScreen.dart';
import 'package:mypocket/Home/bkashpayscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MobileTopUpScreen extends StatefulWidget {
  @override
  _MobileTopUpScreenState createState() => _MobileTopUpScreenState();
}

class _MobileTopUpScreenState extends State<MobileTopUpScreen> {
  int _selectedIndex = 1;
  final _mobileNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final _pinController = TextEditingController();

  String _mobileNumber = '';
  double _amount = 0.0;
  String _pin = '';
  String? _mobileNumberError;
  String? _amountError;
  List<CardData> _cards = [];
  String? _selectedCardId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final QuerySnapshot cardsSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('cards')
            .get();

        List<CardData> loadedCards = [];
        for (var doc in cardsSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>?;
          loadedCards.add(CardData.fromFirestore(data, doc.id));
        }

        setState(() {
          _cards = loadedCards;
          if (_cards.isNotEmpty) {
            _selectedCardId = _cards.first.cardId;
          }
          _isLoading = false;
        });
      } catch (e) {
        print("Error fetching cards: $e");
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateCardBalance(String cardId, double newBalance) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('cards')
            .doc(cardId)
            .update({'balance': newBalance});
      } catch (e) {
        print("Error updating card balance: $e");
        throw e;
      }
    }
  }

  Future<void> _addTransaction(
      String type, double amount, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final transaction = my_transaction.Transaction(
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

    if (_selectedCardId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a card'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  void _confirmTransaction() async {
    if (!_validateInput()) {
      return;
    }

    _pin = _pinController.text;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFE0E3E7),
          title: Text('Confirm Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Amount: ${_amount.toStringAsFixed(2)}'),
              Text('Mobile: $_mobileNumber'),
              SizedBox(height: 20),
              TextField(
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
            ],
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
      final selectedCard = _cards.firstWhere((card) => card.cardId == _selectedCardId);
      if (selectedCard.balance != null && selectedCard.balance! >= _amount) {
        double newBalance = selectedCard.balance! - _amount;
        await _updateCardBalance(selectedCard.cardId, newBalance);

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

        _mobileNumberController.clear();
        _amountController.clear();
        _pinController.clear();

        setState(() {
          _mobileNumberError = null;
          _amountError = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Insufficient balance in selected card'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color.fromARGB(241, 244, 248, 255),
          ),
          child: Column(
            children: [
              SizedBox(height: 20), // Reduced from 80
              Container(
                child: Image.asset(
                  'Mobile-Top-Up.png',
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 180, // Reduced from 220
                ),
              ),
              const SizedBox(height: 20),
              if (_cards.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedCardId,
                    decoration: InputDecoration(
                      labelText: 'Select Card',
                      labelStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: _cards.map((CardData card) {
                      return DropdownMenuItem<String>(
                        value: card.cardId,
                        child: Text(
                          '${card.bankName} (•••• ${card.cardNumber.substring(card.cardNumber.length - 4)}) - ${card.balance?.toStringAsFixed(2) ?? '0.00'}',
                          style: TextStyle(color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCardId = newValue;
                      });
                    },
                  ),
                ),
              if (_cards.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'No cards available. Please add a card first.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
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
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
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
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _cards.isEmpty ? null : _confirmTransaction,
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(200, 50),
                  backgroundColor: _cards.isEmpty
                      ? Colors.grey
                      : Colors.indigoAccent,
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
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
