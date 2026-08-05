class DocumentEntity {
  final String id;
  final String docType; // 'NID' | 'PASSPORT'
  final String docNumberMasked;
  final DateTime? confirmedAt;
  final DateTime createdAt;

  // Only populated after biometric reveal
  final Map<String, dynamic>? details;

  const DocumentEntity({
    required this.id,
    required this.docType,
    required this.docNumberMasked,
    this.confirmedAt,
    required this.createdAt,
    this.details,
  });

  bool get isNid => docType == 'NID';
  bool get isPassport => docType == 'PASSPORT';
  bool get isConfirmed => confirmedAt != null;

  DocumentEntity copyWith({Map<String, dynamic>? details}) {
    return DocumentEntity(
      id: id,
      docType: docType,
      docNumberMasked: docNumberMasked,
      confirmedAt: confirmedAt,
      createdAt: createdAt,
      details: details ?? this.details,
    );
  }

  factory DocumentEntity.fromJson(Map<String, dynamic> json) {
    return DocumentEntity(
      id: json['id'] as String,
      docType: json['docType'] as String,
      docNumberMasked: json['docNumberMasked'] as String,
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      details: json['details'] as Map<String, dynamic>?,
    );
  }
}
