import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_event_ticket.dart';
import 'event_ticket.dart';

class PassesListScreen extends StatefulWidget {
  @override
  _PassesListScreenState createState() => _PassesListScreenState();
}

class _PassesListScreenState extends State<PassesListScreen> {
  List<EventTicket> _eventTickets = [];
  final Map<String, LinearGradient> _cardColors = {};
  final Map<String, bool> _buttonAnimations = {};

  final List<LinearGradient> _gradients = [
    LinearGradient(colors: [Color(0xFFF7971E), Color(0xFFFFD200)]),
    LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
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
    _loadEventTickets();
  }

  Future<void> _loadEventTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTickets = prefs.getStringList('eventTickets') ?? [];
    final savedColors = prefs.getString('eventTicketColors') ?? '';

    setState(() {
      _eventTickets = savedTickets.map((ticketStr) {
        final parts = ticketStr.split('|');
        return EventTicket(
          id: parts[0],
          eventName: parts[1],
          venue: parts[2],
          date: DateTime.parse(parts[3]),
          seat: parts[4],
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

      for (int i = 0; i < _eventTickets.length; i++) {
        if (!_cardColors.containsKey(_eventTickets[i].id)) {
          _cardColors[_eventTickets[i].id] = _gradients[i % _gradients.length];
        }
        _buttonAnimations[_eventTickets[i].id + '_delete'] = false;
      }
    });

    if (_cardColors.length > savedTickets.length) {
      _saveColors();
    }
  }

  Future<void> _saveEventTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final tickets = _eventTickets.map((ticket) =>
    '${ticket.id}|${ticket.eventName}|${ticket.venue}|${ticket.date.toIso8601String()}|${ticket.seat}'
    ).toList();
    await prefs.setStringList('eventTickets', tickets);
  }

  Future<void> _saveColors() async {
    final prefs = await SharedPreferences.getInstance();
    final colors = _cardColors.entries.map((entry) =>
    '${entry.key}:${entry.value.colors[0].value};${entry.value.colors[1].value}'
    ).join(',');
    await prefs.setString('eventTicketColors', colors);
  }

  Future<void> _saveAll() async {
    await _saveEventTickets();
    await _saveColors();
  }

  void _addEventTicket(EventTicket ticket) {
    setState(() {
      _eventTickets.add(ticket);
      _cardColors[ticket.id] = _gradients[_eventTickets.length % _gradients.length];
      _buttonAnimations[ticket.id + '_delete'] = false;
      _saveAll();
    });
  }

  void _updateEventTicket(EventTicket ticket) {
    setState(() {
      final index = _eventTickets.indexWhere((t) => t.id == ticket.id);
      if (index != -1) {
        _eventTickets[index] = ticket;
      }
      _saveAll();
    });
  }

  void _deleteEventTicket(String id) {
    setState(() {
      _eventTickets.removeWhere((ticket) => ticket.id == id);
      _cardColors.remove(id);
      _buttonAnimations.remove(id + '_delete');
      _saveAll();
    });
  }

  void _showDeleteDialog(EventTicket ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Delete Ticket', style: TextStyle(color: Colors.white)),
        content: Text('Delete ${ticket.eventName}?', style: TextStyle(color: Colors.white54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.purple)),
          ),
          TextButton(
            onPressed: () {
              _deleteEventTicket(ticket.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ticket deleted'),
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

  void _showTicketDetails(EventTicket ticket) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: _cardColors[ticket.id] ?? _gradients[0],
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
              _buildDetailRow(Icons.place, 'Venue', ticket.venue),
              SizedBox(height: 15),
              _buildDetailRow(Icons.calendar_today, 'Date', ticket.formattedDate),
              SizedBox(height: 15),
              _buildDetailRow(Icons.access_time, 'Time', ticket.formattedTime),
              SizedBox(height: 15),
              _buildDetailRow(Icons.chair, 'Seat', ticket.seat),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEventTicketScreen(
                          existingTicket: ticket,
                          onSave: _updateEventTicket,
                        ),
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
            ],
          ),
        ),
      ),
    );
  }

  void _animateButton(String ticketId, String buttonType) async {
    setState(() {
      _buttonAnimations[ticketId + '_' + buttonType] = true;
    });
    await HapticFeedback.lightImpact();
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      _buttonAnimations[ticketId + '_' + buttonType] = false;
    });
  }

  Map<String, List<EventTicket>> _groupTicketsByDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));

    Map<String, List<EventTicket>> grouped = {
      'Today': [],
      'Tomorrow': [],
      'Upcoming': [],
      'Past': [],
    };

    for (var ticket in _eventTickets) {
      final ticketDate = DateTime(ticket.date.year, ticket.date.month, ticket.date.day);

      if (ticketDate.isBefore(today)) {
        grouped['Past']!.add(ticket);
      } else if (ticketDate == today) {
        grouped['Today']!.add(ticket);
      } else if (ticketDate == tomorrow) {
        grouped['Tomorrow']!.add(ticket);
      } else {
        grouped['Upcoming']!.add(ticket);
      }
    }

    // Sort each section
    grouped.forEach((key, value) {
      value.sort((a, b) => a.date.compareTo(b.date));
    });

    return grouped;
  }

  List<Widget> _buildGroupedTickets() {
    final groupedTickets = _groupTicketsByDate();
    final List<Widget> widgets = [];

    // Define the order we want to display sections
    const sectionOrder = ['Today', 'Tomorrow', 'Upcoming', 'Past'];

    for (var section in sectionOrder) {
      final tickets = groupedTickets[section]!;
      if (tickets.isNotEmpty) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
            child: Text(
              section,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );

        widgets.addAll(
          tickets.map((ticket) => _buildTicketCard(ticket)).toList(),
        );
      }
    }

    return widgets;
  }

  Widget _buildTicketCard(EventTicket ticket) {
    final gradient = _cardColors[ticket.id] ?? _gradients[0];

    return Dismissible(
      key: Key(ticket.id),
      background: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.red),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          _showDeleteDialog(ticket);
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
            onTap: () => _showTicketDetails(ticket),
            onLongPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEventTicketScreen(
                    existingTicket: ticket,
                    onSave: _updateEventTicket,
                  ),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          ticket.eventName,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
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
                                _animateButton(ticket.id, 'delete');
                                _showDeleteDialog(ticket);
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 100),
                                curve: Curves.easeInOut,
                                transform: Matrix4.identity()
                                  ..scale(_buttonAnimations[ticket.id + '_delete'] ?? false ? 0.9 : 1.0),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                                Icons.place,
                                'Venue',
                                ticket.venue
                            ),
                            SizedBox(height: 12),
                            _buildInfoRow(
                                Icons.calendar_today,
                                'Date',
                                ticket.formattedDate
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                                Icons.access_time,
                                'Time',
                                ticket.formattedTime
                            ),
                            SizedBox(height: 12),
                            _buildInfoRow(
                                Icons.chair,
                                'Seat',
                                ticket.seat
                            ),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text('Event Tickets', style: GoogleFonts.poppins()),
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
      body: _eventTickets.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 60, color: Colors.purple),
            SizedBox(height: 20),
            Text(
              'No Event Tickets',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.white54,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Add your first event ticket',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildGroupedTickets(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEventTicketScreen(
                onSave: _addEventTicket,
              ),
            ),
          );
        },
        backgroundColor: Colors.purple,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
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
        ),
      ],
    );
  }
}