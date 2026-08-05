class CertificateEntity {
  final String id;
  final String name;
  final String issuer;
  final String issueDate;
  final String category;
  final String? subCategory;
  final DateTime createdAt;

  const CertificateEntity({
    required this.id,
    required this.name,
    required this.issuer,
    required this.issueDate,
    required this.category,
    this.subCategory,
    required this.createdAt,
  });

  String get displayCategory {
    switch (category) {
      case 'ACADEMIC': return 'Academic';
      case 'OLYMPIAD': return 'Olympiad';
      case 'QUIZCOMP': return 'Quiz Competition';
      case 'BIZCOMP': return 'Business Competition';
      case 'SPORTS': return 'Sports';
      case 'SKILLS': return 'General Skills';
      default: return category;
    }
  }

  String get displaySubCategory {
    switch (subCategory) {
      case 'SSC': return 'SSC';
      case 'HSC': return 'HSC';
      case 'UNDERGRAD': return 'Under Graduate';
      case 'GRAD': return 'Graduate';
      case 'PHD': return 'PhD';
      case 'POSTDOC': return 'Post Doctorate';
      default: return subCategory ?? '';
    }
  }

  factory CertificateEntity.fromJson(Map<String, dynamic> json) {
    return CertificateEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      issuer: json['issuer'] as String,
      issueDate: json['issueDate'] as String,
      category: json['category'] as String,
      subCategory: json['subCategory'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
