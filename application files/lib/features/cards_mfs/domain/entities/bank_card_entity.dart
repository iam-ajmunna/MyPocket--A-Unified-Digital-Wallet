class BankCardEntity {
  final String id;
  final String bankName;
  final String lastFourDigits;
  final bool isImmutable;
  final DateTime? confirmedAt;

  BankCardEntity({
    required this.id,
    required this.bankName,
    required this.lastFourDigits,
    required this.isImmutable,
    this.confirmedAt,
  });

  factory BankCardEntity.fromJson(Map<String, dynamic> json) {
    return BankCardEntity(
      id: json['id'] as String,
      bankName: json['bankName'] as String,
      lastFourDigits: json['lastFourDigits'] as String,
      isImmutable: json['isImmutable'] as bool? ?? false,
      confirmedAt: json['confirmedAt'] != null ? DateTime.parse(json['confirmedAt'] as String) : null,
    );
  }
}
