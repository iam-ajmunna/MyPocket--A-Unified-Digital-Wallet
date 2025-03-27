import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bkashpayscreen.dart'; // Ensure this file exists
import 'mobiletopupscreen.dart'; // Ensure this file exists
import 'paymentsscreen.dart'; // Ensure this file exists
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';

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

// For the Cards Colors
  final List<LinearGradient> cardColors = [
    LinearGradient(
        colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
    LinearGradient(
        colors: [Color(0xFFF7971E), Color(0xFFFFD200)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
    LinearGradient(
        colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
    LinearGradient(
        colors: [Color(0xFFDA22FF), Color(0xFF9733EE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight),
  ];

  late PageController _pageController;
  late NotchBottomBarController _controller;
  int _selectedIndex = 2; // Default to "Home"

  @override
  void initState() {
    super.initState();
    _loadCards();
    _pageController = PageController(initialPage: _selectedIndex);
    _controller = NotchBottomBarController(index: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

//For Loading the Cards
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

// For Saving the card
  _saveCard(String bankName, String cardNumber, String expiryDate, String cvv,
      String cardType) async {
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

// For Adding The Card
  _addCard(BuildContext context) {
    final bankName = bankNameController.text;
    final cardNumber = cardNumberController.text;
    final expiryDate = expiryDateController.text;
    final cvv = cvvController.text;

    if (bankName.isNotEmpty &&
        cardNumber.isNotEmpty &&
        expiryDate.isNotEmpty &&
        cvv.isNotEmpty &&
        selectedCardType != null) {
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK")),
            ],
          );
        },
      );
    }
  }

//For Showing the Cards Catalog for Adding
  void _showAddCardDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Card',
              style: GoogleFonts.poppins(color: Colors.white)),
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
                      fillColor: Colors.grey[800])),
              const SizedBox(height: 10),
              TextField(
                  controller: cardNumberController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      labelText: 'Card Number',
                      labelStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[800]),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              TextField(
                  controller: expiryDateController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      labelText: 'Expiry Date (MM/YY)',
                      labelStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[800]),
                  keyboardType: TextInputType.datetime),
              const SizedBox(height: 10),
              TextField(
                  controller: cvvController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      labelText: 'CVV',
                      labelStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[800]),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4)),
                child: DropdownButton<String>(
                  value: selectedCardType,
                  hint: Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text("Select Card Type",
                          style: TextStyle(color: Colors.white54))),
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
                  items: <String>[
                    'Credit Card',
                    'Debit Card',
                    'MasterCard',
                    'Visa Card'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Text(value,
                                style: TextStyle(color: Colors.white))));
                  }).toList(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel',
                    style: GoogleFonts.poppins(color: Colors.white))),
            ElevatedButton(
                onPressed: () => _addCard(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent[100]),
                child: Text("Add Card", style: TextStyle(color: Colors.white))),
          ],
        );
      },
    );
  }

// For Showing the Page of Card info
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeIn,
    );
    _controller.jumpTo(index);
  }

// For Showing the Page of Card info
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
                  style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text("Expiry Date: ${card['expiryDate'] ?? "MM/YY"}",
                  style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text("CVV: ***", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text("Card Type: ${card['cardType']}",
                  style: TextStyle(fontSize: 16)),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("Close")),
          ],
        );
      },
    );
  }

// Building the Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          BkashPayScreen(), // Ensure this screen exists
          MobileTopUpScreen(), // Ensure this screen exists
          Container(
            // original WalletScreen content
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.indigoAccent,
                  Color.fromARGB(255, 255, 255, 255)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),

            // For The Welcome Text
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Welcome, Tasmitun",
                        style: GoogleFonts.poppins(
                            fontSize: 24, color: Colors.white)),
                    CircleAvatar(
                        backgroundColor: Colors.amberAccent,
                        radius: 15,
                        child:
                            Text("2", style: TextStyle(color: Colors.white))),
                  ],
                ),

                // For Showing The Balance
                const SizedBox(height: 20),
                Text("Your Balance",
                    style: GoogleFonts.poppins(
                        fontSize: 18, color: Colors.white54)),
                Text("\$79,456.88",
                    style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () => _showAddCardDialog(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amberAccent),
                    child: Text("+ Add New Card",
                        style: TextStyle(color: Colors.white))),
                const SizedBox(height: 20),
                Expanded(
                  child: Stack(
                    children: cards.asMap().entries.map((entry) {
                      final index = entry.key;
                      final card = entry.value;
                      final isLastCard = index == cards.length - 1;

                      return Positioned(
                        top: index * 20.0,
                        left: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _showCardDetails(card),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                                gradient: cardColors[index % cardColors.length],
                                borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(card['bankName'] ?? "Unknown",
                                      style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  if (isLastCard)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 10),
                                        Text(
                                            "**** **** **** ${card['cardNumber']?.substring(card['cardNumber']!.length - 4) ?? "0000"}",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 22)),
                                        const SizedBox(height: 10),
                                        Text(
                                            "Expiry: ${card['expiryDate'] ?? "MM/YY"}",
                                            style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 14)),
                                        const SizedBox(height: 10),
                                        Text("CVV: ***",
                                            style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 14)),
                                        const SizedBox(height: 1),
                                        Text("Card Type: ${card['cardType']}",
                                            style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 14)),
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
          PaymentsScreen(), // Ensure this screen exists
          Center(
              child: Text(
                  'Transfer Page')), // Placeholder - Replace with your Transfer page content
        ],
      ),
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        kIconSize: 24.0,
        kBottomRadius: 18.0,
        bottomBarItems: [
          const BottomBarItem(
              inActiveItem: Icon(Icons.payment, color: Colors.grey),
              activeItem: Icon(Icons.payment, color: Colors.indigoAccent),
              itemLabel: 'bKash Pay'),
          const BottomBarItem(
              inActiveItem: Icon(Icons.phone_android, color: Colors.grey),
              activeItem: Icon(Icons.phone_android, color: Colors.indigoAccent),
              itemLabel: 'Mobile Top-Up'),
          const BottomBarItem(
              inActiveItem: Icon(Icons.home, color: Colors.grey),
              activeItem: Icon(Icons.home, color: Colors.indigo),
              itemLabel: 'Home'),
          const BottomBarItem(
              inActiveItem: Icon(Icons.payments, color: Colors.grey),
              activeItem: Icon(Icons.payments, color: Colors.indigoAccent),
              itemLabel: 'Payments'),
          const BottomBarItem(
              inActiveItem: Icon(Icons.compare_arrows, color: Colors.grey),
              activeItem:
                  Icon(Icons.compare_arrows, color: Colors.indigoAccent),
              itemLabel: 'Transfer'),
        ],
        onTap: (index) => _onItemTapped(index),
      ),
    );
  }
}
