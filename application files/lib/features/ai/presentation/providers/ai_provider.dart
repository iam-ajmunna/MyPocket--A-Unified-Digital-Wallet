import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/chat_message_entity.dart';

class AiState {
  final List<ChatMessageEntity> messages;
  final bool isLoading;
  final String sessionId;
  final String? errorMessage;

  AiState({
    required this.messages,
    this.isLoading = false,
    required this.sessionId,
    this.errorMessage,
  });

  AiState copyWith({
    List<ChatMessageEntity>? messages,
    bool? isLoading,
    String? sessionId,
    String? errorMessage,
  }) {
    return AiState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      sessionId: sessionId ?? this.sessionId,
      errorMessage: errorMessage,
    );
  }
}

class AiNotifier extends StateNotifier<AiState> {
  final ApiClient _apiClient;
  final _uuid = const Uuid();

  AiNotifier(this._apiClient)
      : super(AiState(
          messages: [
            ChatMessageEntity(
              id: 'init_welcome',
              content:
                  'Hello! I\'m Moon 🌙, your MyPocket AI Assistant. Ask me about your stored bank cards, transit pass balances, certificates, or identity documents!',
              sender: MessageSender.moon,
              timestamp: DateTime.now(),
            ),
          ],
          sessionId: const Uuid().v4(),
        ));

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isLoading) return;

    final userMsgId = _uuid.v4();
    final userMsg = ChatMessageEntity(
      id: userMsgId,
      content: trimmed,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    final loadingMsgId = _uuid.v4();
    final loadingMsg = ChatMessageEntity(
      id: loadingMsgId,
      content: 'Thinking...',
      sender: MessageSender.moon,
      timestamp: DateTime.now(),
      isLoading: true,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg, loadingMsg],
      isLoading: true,
      errorMessage: null,
    );

    try {
      final response = await _apiClient.dio.post(
        '/ai/chat',
        data: {
          'message': trimmed,
          'sessionId': state.sessionId,
        },
      );

      final reply = response.data['reply'] as String? ?? 'No response received.';
      final returnedSessionId = response.data['sessionId'] as String? ?? state.sessionId;

      final moonMsg = ChatMessageEntity(
        id: loadingMsgId,
        content: reply,
        sender: MessageSender.moon,
        timestamp: DateTime.now(),
        isLoading: false,
      );

      final updatedMessages = state.messages.map((m) {
        if (m.id == loadingMsgId) return moonMsg;
        return m;
      }).toList();

      state = state.copyWith(
        messages: updatedMessages,
        isLoading: false,
        sessionId: returnedSessionId,
      );
    } catch (e) {
      final errorMsg = ChatMessageEntity(
        id: loadingMsgId,
        content: 'Sorry, I ran into an issue connecting. Please try again!',
        sender: MessageSender.moon,
        timestamp: DateTime.now(),
        isLoading: false,
      );

      final updatedMessages = state.messages.map((m) {
        if (m.id == loadingMsgId) return errorMsg;
        return m;
      }).toList();

      state = state.copyWith(
        messages: updatedMessages,
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void clearChat() {
    final newSessionId = _uuid.v4();
    _apiClient.dio.delete('/ai/session/${state.sessionId}');
    state = AiState(
      messages: [
        ChatMessageEntity(
          id: _uuid.v4(),
          content: 'Chat session cleared. How can I help you today? 🌙',
          sender: MessageSender.moon,
          timestamp: DateTime.now(),
        ),
      ],
      sessionId: newSessionId,
    );
  }
}

final aiNotifierProvider = StateNotifierProvider<AiNotifier, AiState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AiNotifier(apiClient);
});
