import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'transit_card.dart';

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
  List<Map<String, String>> _bankCards = [];
  String? _selectedPaymentMethod;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _loadBankCards();
    _amountController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadBankCards() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedCards = prefs.getStringList('cards');
    if (savedCards != null) {
      setState(() {
        _bankCards = savedCards.map((card) {
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

  void _recharge() {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.red[400],
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red[400],
        ),
      );
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isProcessingPayment = false;
      });
      widget.onRecharge(amount);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully recharged \$${amount.toStringAsFixed(2)}'),
          backgroundColor: Colors.green[600],
        ),
      );
    });
  }

  Widget _buildPaymentMethodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900]!.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple[400]!, width: 1.5),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SELECT PAYMENT METHOD',
            style: GoogleFonts.poppins(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          DropdownButton<String>(
            value: _selectedPaymentMethod,
            isExpanded: true,
            underline: SizedBox(),
            dropdownColor: Colors.grey[850],
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
            ),
            icon: Icon(Icons.arrow_drop_down, color: Colors.purple[300]),
            items: _bankCards.map((card) {
              final lastFour = card['cardNumber']?.substring(card['cardNumber']!.length - 4) ?? '****';
              return DropdownMenuItem<String>(
                value: '${card['bankName']} •••• $lastFour',
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.purple[800]!.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.credit_card,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card['bankName'] ?? 'Bank',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '•••• $lastFour',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
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
                _selectedPaymentMethod = value;
              });
            },
            hint: Text(
              'Select your card',
              style: GoogleFonts.poppins(
                color: Colors.white54,
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
          gradient: LinearGradient(
            colors: [
              Colors.purple[800]!.withOpacity(0.8),
              Colors.purple[600]!.withOpacity(0.8)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.purple[400]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.purple[800]!.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          '\$$amount',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final isValidAmount = amount > 0;

    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          'Recharge Card',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Balance Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1E1E1E),
                    Color(0xFF2D2D2D),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT BALANCE',
                    style: GoogleFonts.poppins(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '\$${widget.transitCard.balance.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Payment Method Selection
            _buildPaymentMethodSelector(),
            SizedBox(height: 25),

            // Amount Input
            Text(
              'RECHARGE AMOUNT',
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.attach_money, color: Colors.purple[300]),
                filled: true,
                fillColor: Colors.grey[900]!.withOpacity(0.7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.purple[400]!,
                    width: 1.5,
                  ),
                ),
                hintText: 'Enter amount',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.white54,
                ),
              ),
            ),
            SizedBox(height: 25),

            // Quick Recharge Section
            Text(
              'QUICK RECHARGE',
              style: GoogleFonts.poppins(
                color: Colors.white54,
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

            // Recharge Button - Updated with always visible background
            // Recharge Button - Updated to be visible only when amount is entered
            SizedBox(
              width: double.infinity,
              child: AnimatedOpacity(
                opacity: isValidAmount ? 1.0 : 0.0,
                duration: Duration(milliseconds: 300),
                child: ElevatedButton(
                  onPressed: isValidAmount ? _recharge : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[600],
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    shadowColor: Colors.purple[800]!.withOpacity(0.5),
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
                          letterSpacing: 1.0,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '\$${amount.toStringAsFixed(2)}',
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
            ),
          ],
        ),
      ),
    );
  }
}