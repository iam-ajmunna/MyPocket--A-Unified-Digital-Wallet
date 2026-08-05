class TransitPassEntity {
  final String id;
  final String name;
  final String lastFourDigits;
  final String transitType;
  final String expiryDate;
  final double balance;
  final String? qrToken;
  final DateTime createdAt;

  const TransitPassEntity({
    required this.id,
    required this.name,
    required this.lastFourDigits,
    required this.transitType,
    required this.expiryDate,
    required this.balance,
    this.qrToken,
    required this.createdAt,
  });

  String get maskedNumber => '•••• •••• $lastFourDigits';
  String get formattedBalance => 'Tk ${balance.toStringAsFixed(2)}';

  bool get isExpired {
    try {
      return DateTime.parse(expiryDate).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  TransitPassEntity copyWith({double? balance, String? qrToken}) {
    return TransitPassEntity(
      id: id,
      name: name,
      lastFourDigits: lastFourDigits,
      transitType: transitType,
      expiryDate: expiryDate,
      balance: balance ?? this.balance,
      qrToken: qrToken ?? this.qrToken,
      createdAt: createdAt,
    );
  }

  factory TransitPassEntity.fromJson(Map<String, dynamic> json) {
    return TransitPassEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      lastFourDigits: json['lastFourDigits'] as String,
      transitType: json['transitType'] as String,
      expiryDate: json['expiryDate'] as String,
      balance: (json['balance'] as num).toDouble(),
      qrToken: json['qrToken'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
