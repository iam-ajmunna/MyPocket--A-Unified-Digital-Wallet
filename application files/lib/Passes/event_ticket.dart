import 'package:intl/intl.dart';

class EventTicket {
  final String id;
  final String eventName;
  final String venue;
  final DateTime date;
  final String seat;

  EventTicket({
    required this.id,
    required this.eventName,
    required this.venue,
    required this.date,
    required this.seat,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventName': eventName,
      'venue': venue,
      'date': date.toIso8601String(),
      'seat': seat,
    };
  }

  factory EventTicket.fromMap(Map<String, dynamic> map) {
    return EventTicket(
      id: map['id'],
      eventName: map['eventName'],
      venue: map['venue'],
      date: DateTime.parse(map['date']),
      seat: map['seat'],
    );
  }
}