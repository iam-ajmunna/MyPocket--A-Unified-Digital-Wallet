import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storageService;

  AuthRepositoryImpl({
    required ApiClient apiClient,
    required SecureStorageService storageService,
  })  : _apiClient = apiClient,
        _storageService = storageService;

  @override
  Future<UserEntity> register({
    required String email,
    required String phone,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/register',
        data: {
          'email': email,
          'phone': phone,
          'password': password,
          'fullName': fullName,
        },
      );

      final userJson = response.data['user'];
      final tokens = response.data['tokens'];

      await _storageService.saveAuthTokens(
        accessToken: tokens['accessToken'],
        refreshToken: tokens['refreshToken'],
      );

      return UserEntity.fromJson(userJson);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Registration failed';
      throw Exception(message);
    }
  }

  @override
  Future<UserEntity> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {
          'identifier': identifier,
          'password': password,
        },
      );

      final userJson = response.data['user'];
      final tokens = response.data['tokens'];

      await _storageService.saveAuthTokens(
        accessToken: tokens['accessToken'],
        refreshToken: tokens['refreshToken'],
      );

      return UserEntity.fromJson(userJson);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Login failed';
      throw Exception(message);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
    } catch (_) {}
    await _storageService.clearAuth();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final response = await _apiClient.dio.get('/users/profile');
      return UserEntity.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }
}
