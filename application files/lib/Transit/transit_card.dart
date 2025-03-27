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