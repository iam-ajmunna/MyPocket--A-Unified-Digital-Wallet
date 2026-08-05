import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../entities/bank_card_entity.dart';
import '../entities/mfs_account_entity.dart';
import '../repositories/cards_mfs_repository.dart';

class CardsMfsRepositoryImpl implements CardsMfsRepository {
  final ApiClient _apiClient;

  CardsMfsRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<BankCardEntity>> getCards() async {
    try {
      final response = await _apiClient.dio.get('/cards');
      final list = response.data as List;
      return list.map((item) => BankCardEntity.fromJson(item)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to fetch cards');
    }
  }

  @override
  Future<BankCardEntity> createCard({
    required String bankName,
    required String lastFourDigits,
    required String expiryDate,
    required String cardholderName,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/cards',
        data: {
          'bankName': bankName,
          'lastFourDigits': lastFourDigits,
          'expiryDate': expiryDate,
          'cardholderName': cardholderName,
        },
      );
      return BankCardEntity.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to create card');
    }
  }

  @override
  Future<BankCardEntity> confirmCard(String cardId) async {
    try {
      final response = await _apiClient.dio.post('/cards/$cardId/confirm');
      return BankCardEntity.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to confirm card');
    }
  }

  @override
  Future<void> deleteCard(String cardId) async {
    try {
      await _apiClient.dio.delete('/cards/$cardId');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to delete card');
    }
  }

  @override
  Future<List<MfsAccountEntity>> getMfsAccounts() async {
    try {
      final response = await _apiClient.dio.get('/mfs');
      final list = response.data as List;
      return list.map((item) => MfsAccountEntity.fromJson(item)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to fetch MFS accounts');
    }
  }

  @override
  Future<MfsAccountEntity> createMfsAccount({
    required String provider,
    required String accountNumber,
    required String accountName,
    bool smartSync = false,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/mfs',
        data: {
          'provider': provider,
          'accountNumber': accountNumber,
          'accountName': accountName,
          'smartSync': smartSync,
        },
      );
      return MfsAccountEntity.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to create MFS entry');
    }
  }

  @override
  Future<MfsAccountEntity> confirmMfsAccount(String mfsId) async {
    try {
      final response = await _apiClient.dio.post('/mfs/$mfsId/confirm');
      return MfsAccountEntity.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to confirm MFS entry');
    }
  }

  @override
  Future<void> deleteMfsAccount(String mfsId) async {
    try {
      await _apiClient.dio.delete('/mfs/$mfsId');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to delete MFS entry');
    }
  }
}
