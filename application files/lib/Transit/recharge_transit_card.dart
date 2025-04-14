import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'transit_card.dart';
import 'package:mypocket/Home/WalletScreen.dart';

class RechargeTransitCardScreen extends StatefulWidget {
  final TransitCard transitCard;
  final Function(double) onRecharge;

  RechargeTransitCardScreen({required this.transitCard, required this.onRecharge});

  @override
  _RechargeTransitCardScreenState createState() => _RechargeTransitCardScreenState();
}

class _RechargeTransitCardScreenState extends State<RechargeTransitCardScreen> {
  final _amountController = TextEditingController();
  final List<double> _quickAmounts = [10, 20, 50, 100];
  List<CardData> _bankCards = [];
  String? _selectedCardId;
  bool _isProcessingPayment = false;
  double _newBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadBankCards();
    _amountController.addListener(_updateTotal);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _updateTotal() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    setState(() {
      _newBalance = widget.transitCard.balance + amount;
    });
  }

  Future<void> _loadBankCards() async {
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
          _bankCards = loadedCards;
          if (_bankCards.isNotEmpty) {
            _selectedCardId = _bankCards.first.cardId;
          }
        });
      } catch (e) {
        print("Error fetching cards: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load cards'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  Future<void> _recharge() async {
    if (_selectedCardId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final selectedCard = _bankCards.firstWhere((card) => card.cardId == _selectedCardId);
    if (selectedCard.balance == null || selectedCard.balance! < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient balance in selected card'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // Deduct from bank card
      final newCardBalance = selectedCard.balance! - amount;
      await _updateCardBalance(selectedCard.cardId, newCardBalance);

      // Add to transit card
      widget.onRecharge(amount);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully recharged \BDT${amount.toStringAsFixed(2)}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  Widget _buildPaymentMethodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 1.5),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SELECT PAYMENT METHOD',
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          DropdownButton<String>(
            value: _selectedCardId,
            isExpanded: true,
            underline: SizedBox(),
            dropdownColor: Colors.white,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 16,
            ),
            icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
            items: _bankCards.map((card) {
              final lastFour = card.cardNumber.substring(card.cardNumber.length - 4);
              return DropdownMenuItem<String>(
                value: card.cardId,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.credit_card,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.bankName,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '•••• $lastFour • \BDT${card.balance?.toStringAsFixed(2) ?? '0.00'}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                _selectedCardId = value;
              });
            },
            hint: Text(
              'Select your card',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickRechargeButton(double amount) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _amountController.text = amount.toStringAsFixed(2);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue, width: 1),
        ),
        child: Text(
          '\BDT$amount',
          style: GoogleFonts.poppins(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Balance',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                '\BDT${widget.transitCard.balance.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Divider(height: 30, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New Balance',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                '\BDT${_newBalance.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final isValidAmount = amount > 0 && _selectedCardId != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Recharge Transit Card',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            _buildBalanceCard(),
            SizedBox(height: 30),

            // Payment Method Selection
            _buildPaymentMethodSelector(),
            SizedBox(height: 25),

            // Amount Input
            Text(
              'RECHARGE AMOUNT',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 18,
              ),
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
                  child: Text(
                    'BDT',
                    style: GoogleFonts.poppins(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 1.5,
                  ),
                ),
                hintText: 'Enter amount',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[400],
                ),
              ),
            ),
            SizedBox(height: 25),
            // Quick Recharge Section
            Text(
              'QUICK RECHARGE',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _quickAmounts.map((amount) {
                return _buildQuickRechargeButton(amount);
              }).toList(),
            ),
            SizedBox(height: 30),

            // Recharge Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isValidAmount && !_isProcessingPayment ? _recharge : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: _isProcessingPayment
                    ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
                    : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'RECHARGE NOW',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (isValidAmount) SizedBox(height: 4),
                    if (isValidAmount)
                      Text(
                        '\BDT${amount.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}