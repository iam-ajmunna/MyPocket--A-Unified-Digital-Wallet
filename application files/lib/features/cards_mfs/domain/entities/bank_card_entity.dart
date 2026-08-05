class BankCardEntity {
  final String id;
  final String bankName;
  final String lastFourDigits;
  final String cardHolderName;
  final String expiryMonthYear;
  final bool isImmutable;
  final DateTime? confirmedAt;

  String get last4Digits => lastFourDigits;

  BankCardEntity({
    required this.id,
    required this.bankName,
    required this.lastFourDigits,
    this.cardHolderName = 'Valued Cardholder',
    this.expiryMonthYear = '12/28',
    required this.isImmutable,
    this.confirmedAt,
  });

  factory BankCardEntity.fromJson(Map<String, dynamic> json) {
    return BankCardEntity(
      id: json['id'] as String,
      bankName: json['bankName'] as String,
      lastFourDigits: json['lastFourDigits'] as String? ?? '1234',
      cardHolderName: json['cardHolderName'] as String? ?? 'Valued Cardholder',
      expiryMonthYear: json['expiryMonthYear'] as String? ?? '12/28',
      isImmutable: json['isImmutable'] as bool? ?? false,
      confirmedAt: json['confirmedAt'] != null ? DateTime.parse(json['confirmedAt'] as String) : null,
    );
  }
}
