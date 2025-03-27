import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'event_ticket.dart';

class AddEventTicketScreen extends StatefulWidget {
  final EventTicket? existingTicket;
  final Function(EventTicket) onSave;

  AddEventTicketScreen({this.existingTicket, required this.onSave});

  @override
  _AddEventTicketScreenState createState() => _AddEventTicketScreenState();
}

class _AddEventTicketScreenState extends State<AddEventTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _eventNameController;
  late TextEditingController _venueController;
  late TextEditingController _dateController;
  late TextEditingController _seatController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _eventNameController = TextEditingController(
        text: widget.existingTicket?.eventName ?? '');
    _venueController = TextEditingController(
        text: widget.existingTicket?.venue ?? '');
    _dateController = TextEditingController(
        text: widget.existingTicket != null
            ? DateFormat('yyyy-MM-dd').format(widget.existingTicket!.date)
            : '');
    _seatController = TextEditingController(
        text: widget.existingTicket?.seat ?? '');
    _selectedDate = widget.existingTicket?.date;
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _venueController.dispose();
    _dateController.dispose();
    _seatController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(), // Prevent selecting dates before today
      lastDate: DateTime(2100),
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    // Additional validation to ensure date isn't in the past
    if (_selectedDate!.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date in the future')),
      );
      return;
    }

    final newTicket = EventTicket(
      id: widget.existingTicket?.id ?? DateTime.now().toString(),
      eventName: _eventNameController.text,
      venue: _venueController.text,
      date: _selectedDate!,
      seat: _seatController.text,
    );

    widget.onSave(newTicket);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(
          widget.existingTicket != null ? 'Edit Ticket' : 'Add Event Ticket',
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
                controller: _eventNameController,
                label: 'Event Name',
                icon: Icons.event,
                validator: (value) =>
                value!.isEmpty ? 'Please enter event name' : null,
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _venueController,
                label: 'Venue',
                icon: Icons.place,
                validator: (value) =>
                value!.isEmpty ? 'Please enter venue' : null,
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: _dateController,
                    label: 'Date',
                    icon: Icons.calendar_today,
                    validator: (value) =>
                    value!.isEmpty ? 'Please select date' : null,
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildTextField(
                controller: _seatController,
                label: 'Seat',
                icon: Icons.chair,
                validator: (value) =>
                value!.isEmpty ? 'Please enter seat info' : null,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Save Ticket',
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
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.white),
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