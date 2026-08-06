import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationsState {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? errorMessage;

  NotificationsState({
    required this.notifications,
    required this.unreadCount,
    this.isLoading = false,
    this.errorMessage,
  });

  NotificationsState copyWith({
    List<NotificationEntity>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final ApiClient _apiClient;

  NotificationsNotifier(this._apiClient)
      : super(NotificationsState(notifications: [], unreadCount: 0)) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _apiClient.dio.get('/notifications');
      final list = (response.data['notifications'] as List)
          .map((json) => NotificationEntity.fromJson(json))
          .toList();
      final count = response.data['unreadCount'] as int? ?? 0;

      state = state.copyWith(
        notifications: list,
        unreadCount: count,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _apiClient.dio.patch('/notifications/$id/read');
      final updated = state.notifications.map((n) {
        if (n.id == id) {
          return NotificationEntity(
            id: n.id,
            title: n.title,
            body: n.body,
            type: n.type,
            isRead: true,
            scheduledFor: n.scheduledFor,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();

      final newUnread = (state.unreadCount - 1).clamp(0, 999);
      state = state.copyWith(notifications: updated, unreadCount: newUnread);
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiClient.dio.post('/notifications/read-all');
      final updated = state.notifications.map((n) {
        return NotificationEntity(
          id: n.id,
          title: n.title,
          body: n.body,
          type: n.type,
          isRead: true,
          scheduledFor: n.scheduledFor,
          createdAt: n.createdAt,
        );
      }).toList();

      state = state.copyWith(notifications: updated, unreadCount: 0);
    } catch (_) {}
  }

  Future<void> createCustomReminder({
    required String title,
    required String body,
    required String type,
    DateTime? scheduledFor,
  }) async {
    try {
      await _apiClient.dio.post(
        '/notifications/reminder',
        data: {
          'title': title,
          'body': body,
          'type': type,
          if (scheduledFor != null) 'scheduledFor': scheduledFor.toIso8601String(),
        },
      );
      loadNotifications();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> dismiss(String id) async {
    try {
      await _apiClient.dio.delete('/notifications/$id');
      final updated = state.notifications.where((n) => n.id != id).toList();
      state = state.copyWith(notifications: updated);
    } catch (_) {}
  }
}

final notificationsNotifierProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationsNotifier(apiClient);
});
