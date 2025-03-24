class Transaction {
  final String id;
  final String type;
  final double amount;
  final DateTime date;
  final String status;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.status,
  });

  // Convert Transaction to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status,
    };
  }

  // Create a Transaction from a Map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      type: map['type'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      status: map['status'],
    );
  }
}