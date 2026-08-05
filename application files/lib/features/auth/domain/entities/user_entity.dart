class UserEntity {
  final String id;
  final String email;
  final String phone;
  final String fullName;
  final DateTime? createdAt;

  UserEntity({
    required this.id,
    required this.email,
    required this.phone,
    required this.fullName,
    this.createdAt,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      fullName: json['fullName'] as String,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
    );
  }
}
