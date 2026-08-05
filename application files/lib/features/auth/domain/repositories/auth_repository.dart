import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> register({
    required String email,
    required String phone,
    required String password,
    required String fullName,
  });

  Future<UserEntity> login({
    required String identifier,
    required String password,
  });

  Future<void> logout();

  Future<UserEntity?> getCurrentUser();
}
