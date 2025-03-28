import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mypocket/Certificates/CertificatesScreen.dart';
import 'package:mypocket/Passes/event_ticket.dart';
import 'package:mypocket/Passes/passes_list_screen.dart';
import 'package:mypocket/Transit/transit_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:ui';
import 'bkashpayscreen.dart';
import 'mobiletopupscreen.dart';
import 'paymentsscreen.dart';
import 'package:mypocket/Profile/user_profile.dart';
import 'package:intl/intl.dart'; // Import the intl package

// Constants for UI elements and text
const double cardHeight = 210.0;
const double cardWidthFactor = 0.8;
const double pagePaddingHorizontal = 20.0;
const double pagePaddingVertical = 40.0;
const double carouselItemMargin = 8.0;
const double indicatorSize = 8.0;
const double dividerHeight = 1.0;
const double dividerThickness = 2.0;
const double dividerIndent = 24.0;
const double dividerEndIndent = 24.0;
const Color dividerColor = Color(0xFFE0E3E7);
const double addNewCardButtonIconSize = 30.0;
const double addNewCardButtonPadding = 8.0;
const double appBarRadius = 18.0;

// Dummy data for user and balance (will be replaced with backend data)
const String userName = "Tasmitun";
const String userBalance = "\$79,456.88";

// Card colors
final List<LinearGradient> cardColors = [
  const LinearGradient(
    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  const LinearGradient(
    colors: [Color(0xFFF7971E), Color(0xFFFFD200)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  const LinearGradient(
    colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  const LinearGradient(
    colors: [Color(0xFFDA22FF), Color(0xFF9733EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
];

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  // List to hold card data.  Each card is a map of String keys and String values.
  List<Map<String, String>> cards = [];

  // Controllers for the text fields in the Add New Card dialog.
  final bankNameController = TextEditingController();
  final cardNumberController = TextEditingController();
  final expiryDateController = TextEditingController();
  final cvvController = TextEditingController();

  // Selected card type from the dropdown.
  String? selectedCardType;

  // Index of the currently focused card in the carousel.
  int _carouselCurrentIndex = 0;

  // Flag to control the visibility of the Add New Card button.
  bool _showAddNewCardButton = true;

  // PageController for the main page view.
  late PageController _pageController;

  // Controller for the bottom navigation bar.
  late NotchBottomBarController _controller;

  // Index of the currently selected page.
  int _selectedIndex = 2;

  // Controller for the card carousel.
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Index of the card to be deleted
  int? _cardToDeleteIndex;

  @override
  void initState() {
    super.initState();
    _loadCards(); // Load cards from shared preferences.
    _pageController = PageController(
        initialPage: _selectedIndex); // Initialize page controller
    _controller = NotchBottomBarController(
        index: _selectedIndex); // Initialize bottom bar controller
  }

  @override
  void dispose() {
    // Dispose of all controllers to prevent memory leaks.
    _pageController.dispose();
    _controller.dispose();
    bankNameController.dispose();
    cardNumberController.dispose();
    expiryDateController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  // Load card data from shared preferences.
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
        _showAddNewCardButton =
            cards.isEmpty; // Only show if there are no cards.
      });
    } else {
      setState(() {
        _showAddNewCardButton =
            true; //show add new card button if there are no saved cards
      });
    }
  }

  // Save card data to shared preferences.
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

  // Add a new card.
  _addCard(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _saveCard(
        bankNameController.text,
        cardNumberController.text,
        expiryDateController.text,
        cvvController.text,
        selectedCardType!,
      );
      bankNameController.clear();
      cardNumberController.clear();
      expiryDateController.clear();
      cvvController.clear();
      setState(() {
        selectedCardType = null;
        _showAddNewCardButton = false; // Hide the button after adding a card
        _loadCards();
      });
      Navigator.pop(context);
    }
  }

  // Show the Add New Card dialog.
  void _showAddCardDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Add New Card',
              style: GoogleFonts.poppins(
                  color: const Color.fromARGB(255, 0, 0, 0))),
          backgroundColor: const Color.fromARGB(241, 244, 253, 255),
          content: Form(
            //Wrap the Column with a form
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                    controller: bankNameController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                        labelText: 'Bank Name',
                        labelStyle: TextStyle(
                            color: const Color.fromARGB(137, 0, 0, 0)),
                        filled: true,
                        fillColor: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter bank name';
                      }
                      return null;
                    }),
                const SizedBox(height: 10),
                TextFormField(
                    controller: cardNumberController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                        labelText: 'Card Number',
                        labelStyle: TextStyle(
                            color: const Color.fromARGB(137, 0, 0, 0)),
                        filled: true,
                        fillColor: Colors.white),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter card number';
                      }
                      if (value.length < 16 || value.length > 19) {
                        return 'Invalid card number length';
                      }
                      return null;
                    },
                    inputFormatters: [
                      //LengthLimitingTextInputFormatter(19), //removed this and added validation
                    ]),
                const SizedBox(height: 10),
                TextFormField(
                    controller: expiryDateController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                        labelText: 'Expiry Date (MM/YY)',
                        labelStyle: TextStyle(
                            color: const Color.fromARGB(137, 0, 0, 0)),
                        filled: true,
                        fillColor: Colors.white),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter expiry date';
                      }
                      // Basic format check (MM/YY)
                      if (!RegExp(r'^(0[1-9]|1[0-2])\/[0-9]{2}$')
                          .hasMatch(value)) {
                        return 'Invalid date format (MM/YY)';
                      }

                      // Parse the date and check if it's in the future
                      try {
                        final parts = value.split('/');
                        final month = int.parse(parts[0]);
                        final year =
                            int.parse('20${parts[1]}'); // Assume 21st century
                        final now = DateTime.now();
                        final expiryDate = DateTime(year, month);

                        if (expiryDate
                            .isBefore(DateTime(now.year, now.month))) {
                          return 'Card has expired';
                        }
                      } catch (e) {
                        return 'Invalid date';
                      }
                      return null;
                    },
                    onTap: () async {
                      // Show date picker
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(DateTime.now().year + 10),
                      );

                      if (pickedDate != null) {
                        // Format the selected date as MM/YY
                        final formattedDate =
                            DateFormat('MM/yy').format(pickedDate);
                        expiryDateController.text = formattedDate;
                      }
                    }),
                const SizedBox(height: 10),
                TextFormField(
                    controller: cvvController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                        labelText: 'CVV',
                        labelStyle: TextStyle(
                            color: const Color.fromARGB(137, 0, 0, 0)),
                        filled: true,
                        fillColor: Colors.white),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter CVV';
                      }
                      if (value.length != 3) {
                        return 'CVV must be 3 digits';
                      }
                      return null;
                    },
                    inputFormatters: [
                      //LengthLimitingTextInputFormatter(3), // Removed and added validation
                    ]),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4)),
                  child: DropdownButtonFormField<String>(
                    value: selectedCardType,
                    hint: const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text("Select Card Type",
                            style: TextStyle(
                                color: const Color.fromARGB(137, 0, 0, 0)))),
                    isExpanded: true,
                    style: const TextStyle(color: Colors.black),
                    dropdownColor: Colors.white,
                    icon:
                        const Icon(Icons.arrow_drop_down, color: Colors.black),
                    //underline: const SizedBox(), // Removed underline
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
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(value,
                                style: const TextStyle(color: Colors.black))),
                      );
                    }).toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select card type';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel',
                    style: GoogleFonts.poppins(color: Colors.black))),
            ElevatedButton(
                onPressed: () => _addCard(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigoAccent[100]),
                child: const Text("Add Card",
                    style: TextStyle(color: Colors.white))),
          ],
        );
      },
    );
  }

  // Handle item tap in the bottom navigation bar.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 1),
      curve: Curves.linear,
    );
    _controller.jumpTo(
      index,
    );
  }

  // Show card details in a dialog.
  void _showCardDetails(Map<String, String> card) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(card['bankName'] ?? 'Unknown Bank',
              style: const TextStyle(color: Colors.black)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Card Number: **** **** **** ${card['cardNumber']?.substring(card['cardNumber']!.length - 4) ?? "0000"}",
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 10),
              Text("Expiry Date: ${card['expiryDate'] ?? "MM/YY"}",
                  style: const TextStyle(fontSize: 16, color: Colors.black)),
              const SizedBox(height: 10),
              const Text("CVV: ***",
                  style: TextStyle(fontSize: 16, color: Colors.black)),
              const SizedBox(height: 10),
              Text("Card Type: ${card['cardType']}",
                  style: const TextStyle(fontSize: 16, color: Colors.black)),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text("Close", style: TextStyle(color: Colors.black))),
          ],
        );
      },
    );
  }

  // Function to delete a card at a given index
  void _deleteCard(int index) {
    setState(() {
      cards.removeAt(_carouselCurrentIndex);
      _saveCards(); // Save the updated card list
      if (cards.isEmpty) {
        _showAddNewCardButton = true;
      }
    });
  }

  // Save the cards to shared preferences
  void _saveCards() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cardList = cards.map((card) {
      return '${card['bankName']},${card['cardNumber']},${card['expiryDate']},${card['cvv']},${card['cardType']}';
    }).toList();
    prefs.setStringList('cards', cardList);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final cardWidth = screenWidth * cardWidthFactor;

    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          BkashPayScreen(),
          MobileTopUpScreen(),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
// Row for Welcome text and Add Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Welcome, " + userName,
                              style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          if (cards.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 14, 0),
                              child: GestureDetector(
                                onTap: () {
                                  _showAddCardDialog();
                                },
                                child: const CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 15,
                                    child: Icon(
                                      Icons.add_box,
                                      color: Colors.indigoAccent,
                                    )),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
// Your Button is seperate Column
                      Text("Your Balance",
                          style: GoogleFonts.poppins(
                              fontSize: 18, color: Colors.black54)),

// Row For Balance and Delete Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(userBalance,
                              style: GoogleFonts.poppins(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),

                          // Start of Delete Button If there are Cards
                          if (cards.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    // Show a confirmation dialog
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: const Text(
                                          'Delete Card',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        content: const Text(
                                            'Are you sure you want to delete this card?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(), // Cancel
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                  color: Colors.indigoAccent),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              // Delete the card
                                              _deleteCard(_selectedIndex);
                                              Navigator.of(context)
                                                  .pop(); // Close dialog
                                            },
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                  color: Colors.indigoAccent),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white70,
                                    ),
                                    child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        radius: 15,
                                        child: Icon(
                                          Icons.delete_outline_outlined,
                                          color: Colors.indigoAccent,
                                        )),
                                  ),
                                ),
                              ),
                            ),
                          //if there is no card
                          if (cards.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white70,
                              ),
                              child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 15,
                                  child: Icon(
                                    Icons.delete_outline_outlined,
                                    color: const Color.fromARGB(
                                        255, 124, 124, 124),
                                  )),
                            ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Center(child: _buildAddNewCardButton()),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
                // Carousel Slider

                if (cards.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    height: cardHeight + 30,
                    child: CarouselSlider.builder(
                      itemCount: cards.length,
                      carouselController: _carouselController,
                      options: CarouselOptions(
                        height: cardHeight,
                        initialPage: 0,
                        viewportFraction: cardWidthFactor,
                        enableInfiniteScroll: false,
                        autoPlay: false,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _carouselCurrentIndex = index;
                          });
                        },
                      ),
                      itemBuilder: (context, index, realIndex) {
                        final card = cards[index];
                        // Calculate scale based on the current index
                        double scale;
                        if (index == _carouselCurrentIndex) {
                          scale = 1.0; // Full size for the focused card
                        } else if (index == _carouselCurrentIndex - 1 ||
                            index == _carouselCurrentIndex + 1) {
                          scale = 0.9; // Slightly smaller for adjacent cards
                        } else {
                          scale = 0.8; // Smaller for distant cards
                        }

                        return AnimatedScale(
                          duration: const Duration(milliseconds: 300),
                          scale: scale,
                          child: Stack(
                            children: [
                              _buildCarouselItem(
                                  context, card, index, cardWidth),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 20),
                // Page Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: cards.map((card) {
                    int index = cards.indexOf(card);
                    return Container(
                      width: indicatorSize,
                      height: indicatorSize,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: _carouselCurrentIndex == index
                            ? Colors.blue
                            : const Color.fromARGB(163, 155, 154, 154),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: pagePaddingHorizontal),
                  child: const MyDivider(
                    height: dividerHeight,
                    thickness: dividerThickness,
                    indent: dividerIndent,
                    endIndent: dividerEndIndent,
                    color: dividerColor,
                  ),
                ),
                const SizedBox(height: 20),
                // Making the Bottom Button Grids

                Container(
                  padding: const EdgeInsets.all(40),
                  child: buildButtonGrid(context),
                )
              ],
            ),
          ),
          PaymentsScreen(),
          UserProfileView(),
        ],
      ),
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        kIconSize: 24.0,
        kBottomRadius: appBarRadius,
        bottomBarItems: [
          const BottomBarItem(
              inActiveItem: Icon(Icons.payment, color: Colors.grey),
              activeItem: Icon(Icons.payment, color: Colors.indigoAccent),
              itemLabel: 'bKash Pay'),
          const BottomBarItem(
              inActiveItem: Icon(Icons.phone_android, color: Colors.grey),
              activeItem: Icon(Icons.phone_android, color: Colors.indigoAccent),
              itemLabel: 'Top-Up'),
          const BottomBarItem(
              inActiveItem: Icon(Icons.home, color: Colors.grey),
              activeItem: Icon(Icons.home, color: Colors.indigoAccent),
              itemLabel: 'Home'),
          const BottomBarItem(
              inActiveItem: Icon(Icons.payments, color: Colors.grey),
              activeItem: Icon(Icons.payments, color: Colors.indigoAccent),
              itemLabel: 'Payments'),
          const BottomBarItem(
              inActiveItem:
                  Icon(Icons.account_circle_sharp, color: Colors.grey),
              activeItem:
                  Icon(Icons.account_circle_sharp, color: Colors.indigoAccent),
              itemLabel: 'Profile'),
        ],
        onTap: (index) {
          _onItemTapped(index);
        },
        color: Colors.white,
        durationInMilliSeconds: 100,
      ),
    );
  }

  // Build an individual card item for the carousel.
  Widget _buildCarouselItem(BuildContext context, Map<String, String> card,
      int index, double cardWidth) {
    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: const EdgeInsets.symmetric(horizontal: carouselItemMargin),
      decoration: BoxDecoration(
        gradient: cardColors[index % cardColors.length],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(-5, 5),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(card['bankName'] ?? "Unknown",
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                "**** **** **** ${card['cardNumber']?.substring(card['cardNumber']!.length - 4) ?? "0000"}",
                style: const TextStyle(color: Colors.white54, fontSize: 22),
              ),
              const SizedBox(height: 10),
              Text(
                "Expiry: ${card['expiryDate'] ?? "MM/YY"}",
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 10),
              const Text("CVV: ***",
                  style: TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 1),
              Text("Card Type: ${card['cardType']}",
                  style: const TextStyle(color: Colors.white54, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  // Build the Add New Card button.
  Widget _buildAddNewCardButton() {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * cardWidthFactor;

    if (_showAddNewCardButton) {
      return GestureDetector(
        onTap: () => _showAddCardDialog(),
        child: Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(-5, 5),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(5, 5),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  padding: const EdgeInsets.all(addNewCardButtonPadding),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: addNewCardButtonIconSize,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Add New Card",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

// Divider Class
class MyDivider extends StatelessWidget {
  const MyDivider({
    Key? key,
    this.height = 1.0,
    this.thickness = 1.0,
    this.indent = 24.0,
    this.endIndent = 24.0,
    this.color = const Color(0xFFE0E3E7),
  }) : super(key: key);

  final double height;
  final double thickness;
  final double indent;
  final double endIndent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: color,
    );
  }
}

Widget buildBodyButton(
  BuildContext context, {
  required String title,
  required IconData icon,
  VoidCallback? onPressed,
}) {
  return SizedBox(
    width: 100,
    height: 100,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // Change background color
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            // Add a border
            color: Colors.grey.shade300,
            width: 1.0,
          ),
        ),
        elevation: 3,
        shadowColor: Colors.indigoAccent.withOpacity(0.8), // Add shadow color
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 30,
            color: Colors.indigoAccent, // Change icon color
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.black87, // Change text color
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget buildButtonGrid(BuildContext context) {
  return GridView.count(
    crossAxisCount: 3,
    mainAxisSpacing: 56.0,
    crossAxisSpacing: 56.0,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    childAspectRatio: 1.0,
    children: [
      buildBodyButton(context, icon: Icons.event, title: 'Event Passes',
          onPressed: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PassesListScreen(),
          ),
        );
      }),
      buildBodyButton(context, icon: Icons.train, title: 'Transits',
          onPressed: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => TransitListScreen(),
          ),
        );
      }),
      buildBodyButton(context,
          icon: Icons.document_scanner, title: 'Statements', onPressed: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PassesListScreen(),
          ),
        );
      }),
      buildBodyButton(context, icon: Icons.description, title: 'Documents',
          onPressed: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PassesListScreen(),
          ),
        );
      }),
      buildBodyButton(context, icon: Icons.school, title: 'Certificates',
          onPressed: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => CertificatesScreen(),
          ),
        );
      }),
      buildBodyButton(context, icon: Icons.widgets, title: 'More',
          onPressed: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PassesListScreen(),
          ),
        );
      }),
    ],
  );
}
