import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TransitCard {
  final String id;
  final String name;
  final String cardNumber;
  final DateTime expiryDate;
  final String transitType;
  double balance;

  TransitCard({
    required this.id,
    required this.name,
    required this.cardNumber,
    required this.expiryDate,
    required this.transitType,
    this.balance = 0.0,
  });

  String get formattedExpiry => DateFormat('MM/yy').format(expiryDate);
  String get lastFourDigits => cardNumber.length > 4
      ? cardNumber.substring(cardNumber.length - 4)
      : cardNumber;

  void addBalance(double amount) {
    balance += amount;
  }
}

class AddTransitCardDialog extends StatefulWidget {
  final TransitCard? existingCard;
  final Function(TransitCard) onSave;

  AddTransitCardDialog({this.existingCard, required this.onSave});

  @override
  _AddTransitCardDialogState createState() => _AddTransitCardDialogState();
}

class _AddTransitCardDialogState extends State<AddTransitCardDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  String? _selectedTransitType;
  DateTime? _expiryDate;

  final List<Map<String, dynamic>> _transitTypes = [
    {'name': 'Metro', 'icon': Icons.directions_subway},
    {'name': 'Bus', 'icon': Icons.directions_bus},
    {'name': 'Train', 'icon': Icons.train},
    {'name': 'Ferry', 'icon': Icons.directions_boat},
    {'name': 'Tram', 'icon': Icons.tram},
    {'name': 'Subway', 'icon': Icons.subway},
    {'name': 'Light Rail', 'icon': Icons.directions_railway},
    {'name': 'Bike Share', 'icon': Icons.pedal_bike},
  ];

  IconData _getSelectedIcon() {
    if (_selectedTransitType == null) return Icons.directions_transit;
    final type = _transitTypes.firstWhere(
          (t) => t['name'] == _selectedTransitType,
      orElse: () => {'icon': Icons.directions_transit},
    );
    return type['icon'];
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingCard != null) {
      _nameController.text = widget.existingCard!.name;
      _numberController.text = widget.existingCard!.cardNumber;
      _expiryController.text = widget.existingCard!.formattedExpiry;
      _selectedTransitType = widget.existingCard!.transitType;
      _expiryDate = widget.existingCard!.expiryDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 10),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.indigoAccent,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
        _expiryController.text = DateFormat('MM/yy').format(picked);
      });
    }
  }

  void _saveCard() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTransitType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select transit type')),
      );
      return;
    }
    if (_expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select expiry date')),
      );
      return;
    }

    final newCard = TransitCard(
      id: widget.existingCard?.id ?? DateTime.now().toString(),
      name: _nameController.text,
      cardNumber: _numberController.text,
      expiryDate: _expiryDate!,
      transitType: _selectedTransitType!,
    );

    widget.onSave(newCard);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(
        widget.existingCard != null ? 'Edit Transit Card' : 'Add Transit Card',
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      backgroundColor: const Color.fromARGB(241, 244, 253, 255),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Card Name',
                icon: Icons.credit_card,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _numberController,
                label: 'Card Number',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Required';
                  if (value.length < 8) return 'Invalid card number';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _selectExpiryDate(context),
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: _expiryController,
                    label: 'Expiry Date (MM/YY)',
                    icon: Icons.calendar_today,
                    validator: (value) {
                      if (value!.isEmpty) return 'Required';
                      if (!RegExp(r'^(0[1-9]|1[0-2])\/[0-9]{2}$').hasMatch(value)) {
                        return 'Invalid format (MM/YY)';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedTransitType,
                  decoration: InputDecoration(
                    labelText: 'Transit Type',
                    labelStyle: TextStyle(color: Colors.grey[700]),
                    border: InputBorder.none,
                    icon: Icon(_getSelectedIcon(), color: Colors.indigoAccent),
                  ),
                  items: _transitTypes.map<DropdownMenuItem<String>>((type) {
                    return DropdownMenuItem<String>(
                      value: type['name'] as String,
                      child: Row(
                        children: [
                          Icon(type['icon'] as IconData, color: Colors.indigoAccent),
                          const SizedBox(width: 10),
                          Text(type['name'] as String,
                              style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedTransitType = value;
                    });
                  },
                  validator: (value) => value == null ? 'Required' : null,
                  dropdownColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saveCard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigoAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      widget.existingCard != null ? 'Update Card' : 'Add Card',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        prefixIcon: Icon(icon, color: Colors.indigoAccent),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      validator: validator,
    );
  }
}