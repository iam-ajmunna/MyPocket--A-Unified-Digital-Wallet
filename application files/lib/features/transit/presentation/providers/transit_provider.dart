import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/transit_pass_entity.dart';

abstract class TransitRepository {
  Future<List<TransitPassEntity>> getTransitPasses();
  Future<TransitPassEntity> addTransitPass({
    required String name,
    required String cardNumber,
    required String transitType,
    required String expiryDate,
  });
  Future<TransitPassEntity> recharge(String id, double amount);
  Future<String> refreshQrToken(String id);
  Future<void> deleteTransitPass(String id);
}

class TransitRepositoryImpl implements TransitRepository {
  final ApiClient _apiClient;
  TransitRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<TransitPassEntity>> getTransitPasses() async {
    try {
      final response = await _apiClient.dio.get('/transit');
      final list = response.data as List;
      return list.map((e) => TransitPassEntity.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to fetch transit passes');
    }
  }

  @override
  Future<TransitPassEntity> addTransitPass({
    required String name,
    required String cardNumber,
    required String transitType,
    required String expiryDate,
  }) async {
    try {
      final response = await _apiClient.dio.post('/transit', data: {
        'name': name,
        'cardNumber': cardNumber,
        'transitType': transitType,
        'expiryDate': expiryDate,
      });
      return TransitPassEntity.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to add transit pass');
    }
  }

  @override
  Future<TransitPassEntity> recharge(String id, double amount) async {
    try {
      final response = await _apiClient.dio.post('/transit/$id/recharge', data: {'amount': amount});
      return TransitPassEntity.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Recharge failed');
    }
  }

  @override
  Future<String> refreshQrToken(String id) async {
    try {
      final response = await _apiClient.dio.post('/transit/$id/qr');
      return response.data['qrToken'] as String;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to refresh QR');
    }
  }

  @override
  Future<void> deleteTransitPass(String id) async {
    try {
      await _apiClient.dio.delete('/transit/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to delete transit pass');
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final transitRepositoryProvider = Provider<TransitRepository>((ref) {
  return TransitRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

class TransitState {
  final List<TransitPassEntity> passes;
  final bool isLoading;
  final String? error;
  const TransitState({this.passes = const [], this.isLoading = false, this.error});
  TransitState copyWith({List<TransitPassEntity>? passes, bool? isLoading, String? error}) =>
      TransitState(passes: passes ?? this.passes, isLoading: isLoading ?? this.isLoading, error: error);
}

class TransitNotifier extends StateNotifier<TransitState> {
  final TransitRepository _repo;
  TransitNotifier(this._repo) : super(const TransitState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final passes = await _repo.getTransitPasses();
      state = state.copyWith(passes: passes, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> add({
    required String name,
    required String cardNumber,
    required String transitType,
    required String expiryDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final pass = await _repo.addTransitPass(
        name: name, cardNumber: cardNumber, transitType: transitType, expiryDate: expiryDate,
      );
      state = state.copyWith(passes: [pass, ...state.passes], isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> recharge(String id, double amount) async {
    try {
      final updated = await _repo.recharge(id, amount);
      state = state.copyWith(
        passes: state.passes.map((p) => p.id == id ? updated : p).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refreshQr(String id) async {
    try {
      final newToken = await _repo.refreshQrToken(id);
      state = state.copyWith(
        passes: state.passes.map((p) => p.id == id ? p.copyWith(qrToken: newToken) : p).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repo.deleteTransitPass(id);
      state = state.copyWith(passes: state.passes.where((p) => p.id != id).toList());
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final transitNotifierProvider =
    StateNotifierProvider<TransitNotifier, TransitState>((ref) {
  return TransitNotifier(ref.watch(transitRepositoryProvider));
});
