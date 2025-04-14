import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../Home/WalletScreen.dart';
import 'event_ticket.dart';

class PassesListScreen extends StatefulWidget {
  const PassesListScreen({Key? key}) : super(key: key);

  @override
  _PassesListScreenState createState() => _PassesListScreenState();
}

class _PassesListScreenState extends State<PassesListScreen> {
  List<EventTicket> _eventTickets = [];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTickets = prefs.getStringList('eventTickets') ?? [];

    setState(() {
      _eventTickets = savedTickets.map((ticketStr) {
        final data = json.decode(ticketStr);
        return EventTicket.fromMap(data);
      }).toList();
    });
  }

  Future<void> _saveTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final tickets = _eventTickets.map((ticket) => json.encode(ticket.toMap())).toList();
    await prefs.setStringList('eventTickets', tickets);
  }

  void _showTicketDetails(EventTicket ticket) {
    final ticketData = '''Event Ticket Details:
Name: ${ticket.eventName}
Venue: ${ticket.venue}
Date: ${DateFormat('MMM dd, yyyy').format(ticket.date)}
Time: ${DateFormat('hh:mm a').format(ticket.date)}
Seat: ${ticket.seat}''';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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
                    ticket.eventName,
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
                    data: ticketData,
                    version: QrVersions.auto,
                    size: 150,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildDetailRow('Venue', ticket.venue),
              SizedBox(height: 15),
              _buildDetailRow(
                  'Date & Time',
                  '${DateFormat('MMM dd, yyyy').format(ticket.date)} at ${DateFormat('hh:mm a').format(ticket.date)}'
              ),
              SizedBox(height: 15),
              _buildDetailRow('Seat', ticket.seat),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showEditTicketDialog(context, ticket);
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
                        'Edit Ticket',
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
                  'Scan QR code for ticket verification',
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

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Ticket"),
        content: Text("Are you sure you want to delete this ticket?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  void _deleteTicket(int index) {
    setState(() {
      _eventTickets.removeAt(index);
      _saveTickets();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Ticket deleted"),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildDetailItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withOpacity(0.8)),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  void _showAddTicketDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddEventTicketDialog(
        onSave: (newTicket) {
          setState(() {
            _eventTickets.add(newTicket);
            _saveTickets();
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEditTicketDialog(BuildContext context, EventTicket ticket) {
    final _formKey = GlobalKey<FormState>();
    final _eventNameController = TextEditingController(text: ticket.eventName);
    final _venueController = TextEditingController(text: ticket.venue);
    final _dateController = TextEditingController(
        text: DateFormat('MMM dd, yyyy').format(ticket.date));
    final _seatController = TextEditingController(text: ticket.seat);
    DateTime _selectedDate = ticket.date;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Edit Event Ticket',
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
                  controller: _eventNameController,
                  label: 'Event Name',
                  icon: Icons.event,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _venueController,
                  label: 'Venue',
                  icon: Icons.location_on,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(DateTime.now().year + 1),
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() {
                        _selectedDate = picked;
                        _dateController.text = DateFormat('MMM dd, yyyy').format(picked);
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: _buildTextField(
                      controller: _dateController,
                      label: 'Date',
                      icon: Icons.calendar_today,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _seatController,
                  label: 'Seat Number',
                  icon: Icons.chair,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final updatedTicket = EventTicket(
                            id: ticket.id,
                            eventName: _eventNameController.text,
                            venue: _venueController.text,
                            date: _selectedDate,
                            seat: _seatController.text,
                          );
                          _updateTicket(ticket, updatedTicket);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Save Changes',
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
      ),
    );
  }

  void _updateTicket(EventTicket oldTicket, EventTicket newTicket) {
    setState(() {
      final index = _eventTickets.indexWhere((t) => t.id == oldTicket.id);
      if (index != -1) {
        _eventTickets[index] = newTicket;
        _saveTickets();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Ticket updated"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.confirmation_num, size: 60, color: Colors.purple),
          SizedBox(height: 20),
          Text(
            'No Event Tickets',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Add your first event ticket',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(EventTicket ticket, int index) {
    return GestureDetector(
      onTap: () => _showTicketDetails(ticket),
      child: Dismissible(
        key: Key(ticket.id),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red[400],
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          child: Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          return await _showDeleteConfirmation(context);
        },
        onDismissed: (direction) {
          _deleteTicket(index);
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.eventName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      ticket.venue,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailItem(
                          icon: Icons.calendar_today,
                          text: DateFormat('MMM dd, yyyy').format(ticket.date),
                        ),
                        _buildDetailItem(
                          icon: Icons.access_time,
                          text: DateFormat('hh:mm a').format(ticket.date),
                        ),
                        _buildDetailItem(
                          icon: Icons.chair,
                          text: ticket.seat,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.white),
                  onPressed: () async {
                    bool confirm = await _showDeleteConfirmation(context);
                    if (confirm) {
                      _deleteTicket(index);
                    }
                  },
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
      style: const TextStyle(color: Colors.black),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Event Tickets',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => WalletScreen()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: _eventTickets.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _eventTickets.length,
        itemBuilder: (ctx, index) => _buildTicketCard(_eventTickets[index], index),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigoAccent,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddTicketDialog(context),
      ),
    );
  }
}

class AddEventTicketDialog extends StatefulWidget {
  final Function(EventTicket) onSave;

  const AddEventTicketDialog({Key? key, required this.onSave}) : super(key: key);

  @override
  _AddEventTicketDialogState createState() => _AddEventTicketDialogState();
}

class _AddEventTicketDialogState extends State<AddEventTicketDialog> {
  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
  final _venueController = TextEditingController();
  final _dateController = TextEditingController();
  final _seatController = TextEditingController();
  DateTime? _selectedDate;

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
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
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
        _selectedDate = picked;
        _dateController.text = DateFormat('MMM dd, yyyy').format(picked);
      });
    }
  }

  void _saveTicket() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select date')),
      );
      return;
    }

    final newTicket = EventTicket(
      id: DateTime.now().toString(),
      eventName: _eventNameController.text,
      venue: _venueController.text,
      date: _selectedDate!,
      seat: _seatController.text,
    );

    widget.onSave(newTicket);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(
        'Add Event Ticket',
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
                controller: _eventNameController,
                label: 'Event Name',
                icon: Icons.event,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _venueController,
                label: 'Venue',
                icon: Icons.location_on,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: _buildTextField(
                    controller: _dateController,
                    label: 'Date',
                    icon: Icons.calendar_today,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _seatController,
                label: 'Seat Number',
                icon: Icons.chair,
                validator: (value) => value!.isEmpty ? 'Required' : null,
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
                    onPressed: _saveTicket,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigoAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
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
      style: const TextStyle(color: Colors.black),
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