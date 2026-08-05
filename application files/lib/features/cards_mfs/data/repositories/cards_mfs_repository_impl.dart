import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/bank_card_entity.dart';
import '../../domain/entities/mfs_account_entity.dart';
import '../../domain/repositories/cards_mfs_repository.dart';

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
  Future<BankCardEntity> addCard({
    required String bankName,
    required String cardHolderName,
    required String cardNumber,
    required String expiryMonthYear,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/cards',
        data: {
          'bankName': bankName,
          'cardHolderName': cardHolderName,
          'cardNumber': cardNumber,
          'expiryMonthYear': expiryMonthYear,
        },
      );
      return BankCardEntity.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to add bank card');
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
  Future<MfsAccountEntity> addMfsAccount({
    required String providerName,
    required String accountNumber,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/mfs',
        data: {
          'provider': providerName,
          'accountNumber': accountNumber,
        },
      );
      return MfsAccountEntity.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to add MFS account');
    }
  }

  @override
  Future<void> deleteMfsAccount(String mfsId) async {
    try {
      await _apiClient.dio.delete('/mfs/$mfsId');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to delete MFS account');
    }
  }
}
