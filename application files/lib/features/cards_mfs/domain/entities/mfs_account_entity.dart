class MfsAccountEntity {
  final String id;
  final String provider; // bKash, Nagad, Upay
  final String accountNumber;
  final String accountName;
  final String? qrCodeToken;
  final bool smartSync;
  final bool isImmutable;
  final DateTime? confirmedAt;

  MfsAccountEntity({
    required this.id,
    required this.provider,
    required this.accountNumber,
    required this.accountName,
    this.qrCodeToken,
    required this.smartSync,
    required this.isImmutable,
    this.confirmedAt,
  });

  factory MfsAccountEntity.fromJson(Map<String, dynamic> json) {
    return MfsAccountEntity(
      id: json['id'] as String,
      provider: json['provider'] as String,
      accountNumber: json['accountNumber'] as String,
      accountName: json['accountName'] as String,
      qrCodeToken: json['qrCodeToken'] as String?,
      smartSync: json['smartSync'] as bool? ?? false,
      isImmutable: json['isImmutable'] as bool? ?? false,
      confirmedAt: json['confirmedAt'] != null ? DateTime.parse(json['confirmedAt'] as String) : null,
    );
  }
}
