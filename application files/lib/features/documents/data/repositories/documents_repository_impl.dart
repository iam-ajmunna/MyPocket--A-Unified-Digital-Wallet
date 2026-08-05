import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/repositories/documents_repository.dart';

class DocumentsRepositoryImpl implements DocumentsRepository {
  final ApiClient _apiClient;

  DocumentsRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<DocumentEntity>> getDocuments() async {
    try {
      final response = await _apiClient.dio.get('/documents');
      final list = response.data as List;
      return list.map((item) => DocumentEntity.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to fetch documents');
    }
  }

  @override
  Future<DocumentEntity> addNid({
    required String nidNumber,
    required String fullName,
    required String dateOfBirth,
    required String fatherName,
    required String motherName,
    required String address,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/documents/nid',
        data: {
          'nidNumber': nidNumber,
          'fullName': fullName,
          'dateOfBirth': dateOfBirth,
          'fatherName': fatherName,
          'motherName': motherName,
          'address': address,
        },
      );
      return DocumentEntity.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to add NID');
    }
  }

  @override
  Future<DocumentEntity> addPassport({
    required String passportNumber,
    required String fullName,
    required String countryCode,
    required String dateOfBirth,
    required String expiryDate,
    required String issueDate,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/documents/passport',
        data: {
          'passportNumber': passportNumber,
          'fullName': fullName,
          'countryCode': countryCode,
          'dateOfBirth': dateOfBirth,
          'expiryDate': expiryDate,
          'issueDate': issueDate,
        },
      );
      return DocumentEntity.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to add Passport');
    }
  }

  @override
  Future<DocumentEntity> revealDocument(String documentId) async {
    try {
      final response = await _apiClient.dio.post('/documents/$documentId/reveal');
      return DocumentEntity.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to reveal document');
    }
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    try {
      await _apiClient.dio.delete('/documents/$documentId');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Failed to delete document');
    }
  }
}
