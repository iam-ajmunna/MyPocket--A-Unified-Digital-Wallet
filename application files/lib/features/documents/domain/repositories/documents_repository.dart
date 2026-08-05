import '../entities/document_entity.dart';

abstract class DocumentsRepository {
  Future<List<DocumentEntity>> getDocuments();
  Future<DocumentEntity> addNid({
    required String nidNumber,
    required String fullName,
    required String dateOfBirth,
    required String fatherName,
    required String motherName,
    required String address,
  });
  Future<DocumentEntity> addPassport({
    required String passportNumber,
    required String fullName,
    required String countryCode,
    required String dateOfBirth,
    required String expiryDate,
    required String issueDate,
  });
  Future<DocumentEntity> revealDocument(String documentId);
  Future<void> deleteDocument(String documentId);
}
