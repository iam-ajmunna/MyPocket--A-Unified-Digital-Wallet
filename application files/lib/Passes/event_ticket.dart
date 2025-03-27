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

  String get formattedDate => DateFormat('MMM dd, yyyy').format(date);
  String get formattedTime => DateFormat('hh:mm a').format(date);

  EventTicket copyWith({
    String? id,
    String? eventName,
    String? venue,
    DateTime? date,
    String? seat,
  }) {
    return EventTicket(
      id: id ?? this.id,
      eventName: eventName ?? this.eventName,
      venue: venue ?? this.venue,
      date: date ?? this.date,
      seat: seat ?? this.seat,
    );
  }
}