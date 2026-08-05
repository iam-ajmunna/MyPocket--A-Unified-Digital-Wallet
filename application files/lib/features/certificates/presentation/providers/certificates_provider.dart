import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/certificate_entity.dart';

abstract class CertificatesRepository {
  Future<List<CertificateEntity>> getCertificates();
  Future<CertificateEntity> addCertificate({
    required String name,
    required String issuer,
    required String issueDate,
    required String category,
    String? subCategory,
  });
  Future<void> deleteCertificate(String id);
}

class CertificatesRepositoryImpl implements CertificatesRepository {
  final ApiClient _apiClient;
  CertificatesRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<CertificateEntity>> getCertificates() async {
    try {
      final response = await _apiClient.dio.get('/certificates');
      final list = response.data as List;
      return list.map((e) => CertificateEntity.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to fetch certificates');
    }
  }

  @override
  Future<CertificateEntity> addCertificate({
    required String name,
    required String issuer,
    required String issueDate,
    required String category,
    String? subCategory,
  }) async {
    try {
      final response = await _apiClient.dio.post('/certificates', data: {
        'name': name,
        'issuer': issuer,
        'issueDate': issueDate,
        'category': category,
        if (subCategory != null && subCategory.isNotEmpty) 'subCategory': subCategory,
      });
      return CertificateEntity.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to add certificate');
    }
  }

  @override
  Future<void> deleteCertificate(String id) async {
    try {
      await _apiClient.dio.delete('/certificates/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to delete certificate');
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final certificatesRepositoryProvider = Provider<CertificatesRepository>((ref) {
  return CertificatesRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

class CertificatesState {
  final List<CertificateEntity> certificates;
  final bool isLoading;
  final String? error;
  const CertificatesState({this.certificates = const [], this.isLoading = false, this.error});
  CertificatesState copyWith({List<CertificateEntity>? certificates, bool? isLoading, String? error}) =>
      CertificatesState(
        certificates: certificates ?? this.certificates,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class CertificatesNotifier extends StateNotifier<CertificatesState> {
  final CertificatesRepository _repo;
  CertificatesNotifier(this._repo) : super(const CertificatesState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final certs = await _repo.getCertificates();
      state = state.copyWith(certificates: certs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> add({
    required String name,
    required String issuer,
    required String issueDate,
    required String category,
    String? subCategory,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final cert = await _repo.addCertificate(
        name: name, issuer: issuer, issueDate: issueDate,
        category: category, subCategory: subCategory,
      );
      state = state.copyWith(certificates: [cert, ...state.certificates], isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repo.deleteCertificate(id);
      state = state.copyWith(certificates: state.certificates.where((c) => c.id != id).toList());
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final certificatesNotifierProvider =
    StateNotifierProvider<CertificatesNotifier, CertificatesState>((ref) {
  return CertificatesNotifier(ref.watch(certificatesRepositoryProvider));
});
