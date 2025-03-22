import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bkashpayscreen.dart';
import 'mobiletopupscreen.dart';
import 'paymentsscreen.dart';
import 'transaction.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  List<Map<String, String>> cards = [];
  final bankNameController = TextEditingController();
  final cardNumberController = TextEditingController();
  final expiryDateController = TextEditingController();
  final cvvController = TextEditingController();
  String? selectedCardType;
  int _selectedIndex = 2; // Default to "Home"

  // List of gradient colors for cards
  final List<LinearGradient> cardColors = [
    LinearGradient(
      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFF7971E), Color(0xFFFFD200)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFDA22FF), Color(0xFF9733EE)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  _loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedCards = prefs.getStringList('cards');
    if (savedCards != null) {
      setState(() {
        cards = savedCards.map((card) {
          final parts = card.split(',');
          return {
            'bankName': parts[0],
            'cardNumber': parts[1],
            'expiryDate': parts[2],
            'cvv': parts[3],
            'cardType': parts[4],
          };
        }).toList();
      });
    }
  }

  _saveCard(String bankName, String cardNumber, String expiryDate, String cvv, String cardType) async {
    final prefs = await SharedPreferences.getInstance();
    cards.add({
      'bankName': bankName,
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'cvv': cvv,
      'cardType': cardType,
    });
    List<String> cardList = cards.map((card) {
      return '${card['bankName']},${card['cardNumber']},${card['expiryDate']},${card['cvv']},${card['cardType']}';
    }).toList();
    prefs.setStringList('cards', cardList);
  }

  _deleteCard(int index) async {
    final prefs = await SharedPreferences.getInstance();
    cards.removeAt(index);
    List<String> cardList = cards.map((card) {
      return '${card['bankName']},${card['cardNumber']},${card['expiryDate']},${card['cvv']},${card['cardType']}';
    }).toList();
    prefs.setStringList('cards', cardList);
    setState(() {
      _loadCards();
    });
  }

  _addCard(BuildContext context) {
    final bankName = bankNameController.text;
    final cardNumber = cardNumberController.text;
    final expiryDate = expiryDateController.text;
    final cvv = cvvController.text;
    if (bankName.isNotEmpty && cardNumber.isNotEmpty && expiryDate.isNotEmpty && cvv.isNotEmpty && selectedCardType != null) {
      _saveCard(bankName, cardNumber, expiryDate, cvv, selectedCardType!);
      bankNameController.clear();
      cardNumberController.clear();
      expiryDateController.clear();
      cvvController.clear();
      setState(() {
        selectedCardType = null;
      });
      _loadCards();
      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text("Please fill all fields"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  void _showAddCardDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add New Card',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.grey[900],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bankNameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Bank Name',
                  labelStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cardNumberController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  labelStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: expiryDateController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Expiry Date (MM/YY)',
                  labelStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cvvController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'CVV',
                  labelStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButton<String>(
                  value: selectedCardType,
                  hint: Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      "Select Card Type",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                  isExpanded: true,
                  style: TextStyle(color: Colors.white),
                  dropdownColor: Colors.grey[800],
                  icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                  underline: SizedBox(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCardType = newValue;
                    });
                  },
                  items: <String>['Credit Card', 'Debit Card', 'MasterCard', 'Visa Card']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text(
                          value,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () => _addCard(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: Text("Add Card", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
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
      // Already on WalletScreen (Home)
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

  void _showCardDetails(Map<String, String> card) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(card['bankName'] ?? 'Unknown Bank'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Card Number: **** **** **** ${card['cardNumber']?.substring(card['cardNumber']!.length - 4) ?? "0000"}",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                "Expiry Date: ${card['expiryDate'] ?? "MM/YY"}",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                "CVV: ***",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                "Card Type: ${card['cardType']}",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Good morning, Tasmitun",
                  style: GoogleFonts.poppins(fontSize: 24, color: Colors.white),
                ),
                CircleAvatar(
                  backgroundColor: Colors.purple,
                  radius: 15,
                  child: Text("2", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Your Balance",
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.white54),
            ),
            Text(
              "\$79,456.88",
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showAddCardDialog();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: Text("+ Add New Card", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Stack(
                children: cards.asMap().entries.map((entry) {
                  final index = entry.key;
                  final card = entry.value;
                  final isLastCard = index == cards.length - 1;

                  return Positioned(
                    top: index * 20.0, // Overlap cards by 20 pixels
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _showCardDetails(card),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          gradient: cardColors[index % cardColors.length], // Use unique gradient color
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card['bankName'] ?? "Unknown",
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isLastCard)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10),
                                    Text(
                                      "**** **** **** ${card['cardNumber']?.substring(card['cardNumber']!.length - 4) ?? "0000"}",
                                      style: TextStyle(color: Colors.white, fontSize: 22),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Expiry: ${card['expiryDate'] ?? "MM/YY"}",
                                      style: TextStyle(color: Colors.white54, fontSize: 14),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "CVV: ***",
                                      style: TextStyle(color: Colors.white54, fontSize: 14),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      "Card Type: ${card['cardType']}",
                                      style: TextStyle(color: Colors.white54, fontSize: 14),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
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