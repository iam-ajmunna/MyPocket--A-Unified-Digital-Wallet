import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../Home/WalletScreen.dart';
import 'transit_card.dart';
import 'recharge_transit_card.dart';

class TransitListScreen extends StatefulWidget {
  @override
  _TransitListScreenState createState() => _TransitListScreenState();
}

class _TransitListScreenState extends State<TransitListScreen> {
  List<TransitCard> _transitCards = [];
  final Map<String, LinearGradient> _cardColors = {};
  final Map<String, bool> _buttonAnimations = {};

  final List<LinearGradient> _gradients = [
    LinearGradient(colors: [Color(0xFFF7971E), Color(0xFFFFD200)]),
    LinearGradient(colors: [Color(0xFF1A2980), Color(0xFF26D0CE)]),
    LinearGradient(colors: [Color(0xFFDA22FF), Color(0xFF9733EE)]),
    LinearGradient(colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)]),
    LinearGradient(colors: [Color(0xFF1D976C), Color(0xFF93F9B9)]),
    LinearGradient(colors: [Color(0xFF673AB7), Color(0xFFFF9800)]),
    LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF3F51B5)]),
    LinearGradient(colors: [Color(0xFF009688), Color(0xFF00BCD4)]),
  ];

  @override
  void initState() {
    super.initState();
    _loadTransitCards();
  }

  Future<void> _loadTransitCards() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCards = prefs.getStringList('transitCards') ?? [];
    final savedColors = prefs.getString('transitCardColors') ?? '';

    setState(() {
      _transitCards = savedCards.map((cardStr) {
        final parts = cardStr.split('|');
        return TransitCard(
          id: parts[0],
          name: parts[1],
          cardNumber: parts[2],
          expiryDate: DateTime.parse(parts[3]),
          transitType: parts[4],
          balance: double.parse(parts[5]),
        );
      }).toList();

      if (savedColors.isNotEmpty) {
        savedColors.split(',').forEach((entry) {
          final parts = entry.split(':');
          if (parts.length == 2) {
            final colors = parts[1].split(';');
            if (colors.length == 2) {
              _cardColors[parts[0]] = LinearGradient(
                colors: [
                  Color(int.parse(colors[0])),
                  Color(int.parse(colors[1])),
                ],
              );
            }
          }
        });
      }

      for (int i = 0; i < _transitCards.length; i++) {
        if (!_cardColors.containsKey(_transitCards[i].id)) {
          _cardColors[_transitCards[i].id] = _gradients[i % _gradients.length];
        }
        _buttonAnimations[_transitCards[i].id + '_add'] = false;
        _buttonAnimations[_transitCards[i].id + '_delete'] = false;
      }
    });

    if (_cardColors.length > savedCards.length) {
      _saveColors();
    }
  }

  Future<void> _saveTransitCards() async {
    final prefs = await SharedPreferences.getInstance();
    final cards = _transitCards
        .map((card) =>
    '${card.id}|${card.name}|${card.cardNumber}|${card.expiryDate.toIso8601String()}|${card.transitType}|${card.balance}')
        .toList();
    await prefs.setStringList('transitCards', cards);
  }

  Future<void> _saveColors() async {
    final prefs = await SharedPreferences.getInstance();
    final colors = _cardColors.entries
        .map((entry) =>
    '${entry.key}:${entry.value.colors[0].value};${entry.value.colors[1].value}')
        .join(',');
    await prefs.setString('transitCardColors', colors);
  }

  Future<void> _saveAll() async {
    await _saveTransitCards();
    await _saveColors();
  }

  void _addTransitCard(TransitCard card) {
    setState(() {
      _transitCards.add(card);
      _cardColors[card.id] =
      _gradients[_transitCards.length % _gradients.length];
      _buttonAnimations[card.id + '_add'] = false;
      _buttonAnimations[card.id + '_delete'] = false;
      _saveAll();
    });
  }

  void _updateTransitCard(TransitCard card) {
    setState(() {
      final index = _transitCards.indexWhere((c) => c.id == card.id);
      if (index != -1) {
        _transitCards[index] = card;
      }
      _saveAll();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Card updated successfully"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteTransitCard(String id) {
    setState(() {
      _transitCards.removeWhere((card) => card.id == id);
      _cardColors.remove(id);
      _buttonAnimations.remove(id + '_add');
      _buttonAnimations.remove(id + '_delete');
      _saveAll();
    });
  }

  void _showDeleteDialog(TransitCard card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Delete Card', style: TextStyle(color: Colors.white)),
        content: Text('Delete ${card.name}?',
            style: TextStyle(color: Colors.white54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              _deleteTransitCard(card.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Card deleted'),
                  backgroundColor: Colors.purple,
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showRechargeDialog(TransitCard card) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RechargeTransitCardScreen(
          transitCard: card,
          onRecharge: (amount) {
            setState(() {
              card.addBalance(amount);
              _saveTransitCards();
            });
          },
        ),
      ),
    );
  }

  void _showCardDetails(TransitCard card) {
    final cardData = '''Transit Card Details:
Name: ${card.name}
Card Number: ${card.cardNumber}
Type: ${card.transitType}
Expiry: ${card.formattedExpiry}
Balance: \BDT${card.balance.toStringAsFixed(2)}''';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: _cardColors[card.id] ?? _gradients[0],
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    card.name,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: QrImageView(
                    data: cardData,
                    version: QrVersions.auto,
                    size: 150,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildDetailRow('Full Card Number', card.cardNumber),
              SizedBox(height: 15),
              _buildDetailRow('Transit Type', card.transitType),
              SizedBox(height: 15),
              _buildDetailRow('Expiry Date', card.formattedExpiry),
              SizedBox(height: 15),
              _buildDetailRow(
                  'Current Balance', '\BDT${card.balance.toStringAsFixed(2)}'),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => AddTransitCardDialog(
                        existingCard: card,
                        onSave: (editedCard) {
                          _updateTransitCard(editedCard);
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Edit Card',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  'Scan QR code for transit verification',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _animateButton(String cardId, String buttonType) async {
    setState(() {
      _buttonAnimations[cardId + '_' + buttonType] = true;
    });
    await HapticFeedback.lightImpact();
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      _buttonAnimations[cardId + '_' + buttonType] = false;
    });
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.white.withOpacity(0.9)),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(241, 244, 248, 255),
      appBar: AppBar(
        title: Text(
          'Transit Cards',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => WalletScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _transitCards.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card, size: 60, color: Colors.purple),
            SizedBox(height: 20),
            Text(
              'No Transit Cards',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Add your first transit card',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _transitCards.length,
        itemBuilder: (context, index) {
          final card = _transitCards[index];
          final gradient = _cardColors[card.id] ?? _gradients[0];

          return Dismissible(
            key: Key(card.id),
            background: Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.delete, color: Colors.red),
            ),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.endToStart) {
                _showDeleteDialog(card);
                return false;
              }
              return null;
            },
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: gradient,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () => _showCardDetails(card),
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AddTransitCardDialog(
                        existingCard: card,
                        onSave: _updateTransitCard,
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                card.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color:
                                      Colors.black.withOpacity(0.3),
                                      blurRadius: 3,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _animateButton(card.id, 'add');
                                      _showRechargeDialog(card);
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                      Duration(milliseconds: 100),
                                      curve: Curves.easeInOut,
                                      transform: Matrix4.identity()
                                        ..scale(_buttonAnimations[
                                        card.id + '_add'] ??
                                            false
                                            ? 0.9
                                            : 1.0),
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        child: Icon(
                                          Icons.add_circle,
                                          color: Colors.green[200],
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () {
                                      _animateButton(card.id, 'delete');
                                      _showDeleteDialog(card);
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                      Duration(milliseconds: 100),
                                      curve: Curves.easeInOut,
                                      transform: Matrix4.identity()
                                        ..scale(_buttonAnimations[
                                        '${card.id}_delete'] ??
                                            false
                                            ? 0.9
                                            : 1.0),
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.red[200],
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow(
                                      Icons.credit_card,
                                      'Card Number',
                                      '•••• •••• •••• ${card.lastFourDigits}'),
                                  SizedBox(height: 12),
                                  _buildInfoRow(Icons.directions_transit,
                                      'Type', card.transitType),
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow(Icons.calendar_today,
                                      'Expiry', card.formattedExpiry),
                                  SizedBox(height: 12),
                                  _buildInfoRow(
                                      Icons.account_balance_wallet,
                                      'Balance',
                                      '\BDT${card.balance.toStringAsFixed(2)}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddTransitCardDialog(
              onSave: _addTransitCard,
            ),
          );
        },
        backgroundColor: Colors.indigoAccent,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}