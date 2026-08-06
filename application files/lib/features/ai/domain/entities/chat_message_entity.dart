enum MessageSender { user, moon }

class ChatMessageEntity {
  final String id;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessageEntity({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.isLoading = false,
  });

  ChatMessageEntity copyWith({
    String? id,
    String? content,
    MessageSender? sender,
    DateTime? timestamp,
    bool? isLoading,
  }) {
    return ChatMessageEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
