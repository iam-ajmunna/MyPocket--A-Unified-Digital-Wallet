import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'transit_card.dart';

class AddTransitCardScreen extends StatefulWidget {
  final TransitCard? existingCard;
  final Function(TransitCard) onSave;

  AddTransitCardScreen({this.existingCard, required this.onSave});

  @override
  _AddTransitCardScreenState createState() => _AddTransitCardScreenState();
}

class _AddTransitCardScreenState extends State<AddTransitCardScreen> {
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
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.purple,
              onPrimary: Colors.white,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[900],
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
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(
          widget.existingCard != null ? 'Edit Transit Card' : 'Add Transit Card',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Card Name',
                icon: Icons.credit_card,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _numberController,
                label: 'Card Number',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () => _selectExpiryDate(context),
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: _expiryController,
                    label: 'Expiry Date',
                    icon: Icons.calendar_today,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonFormField<String>(
                  value: _selectedTransitType,
                  decoration: InputDecoration(
                    labelText: 'Transit Type',
                    labelStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                    icon: Icon(_getSelectedIcon(), color: Colors.purple),
                  ),
                  items: _transitTypes.map<DropdownMenuItem<String>>((type) {
                    return DropdownMenuItem<String>(
                      value: type['name'] as String,
                      child: Row(
                        children: [
                          Icon(type['icon'] as IconData, color: Colors.white),
                          SizedBox(width: 10),
                          Text(type['name'] as String,
                              style: TextStyle(color: Colors.white)),
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
                  dropdownColor: Colors.grey[900],
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Save Card',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
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
      style: TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.purple),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.purple.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.purple),
        ),
      ),
      validator: validator,
    );
  }
}