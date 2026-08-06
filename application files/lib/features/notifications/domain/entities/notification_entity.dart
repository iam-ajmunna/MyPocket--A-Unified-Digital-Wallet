class NotificationEntity {
  final String id;
  final String title;
  final String body;
  final String type; // EXPIRY_WARNING, DUE_PAYMENT, SMART_SYNC, ANNOUNCEMENT, CUSTOM
  final bool isRead;
  final DateTime? scheduledFor;
  final DateTime createdAt;

  NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    this.scheduledFor,
    required this.createdAt,
  });

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String? ?? 'CUSTOM',
      isRead: json['isRead'] as bool? ?? false,
      scheduledFor: json['scheduledFor'] != null ? DateTime.parse(json['scheduledFor'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
