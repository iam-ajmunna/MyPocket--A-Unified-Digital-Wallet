import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/documents_repository_impl.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/repositories/documents_repository.dart';

// ─── Repository Provider ─────────────────────────────────────────────────────
final documentsRepositoryProvider = Provider<DocumentsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DocumentsRepositoryImpl(apiClient: apiClient);
});

// ─── State ────────────────────────────────────────────────────────────────────
class DocumentsState {
  final List<DocumentEntity> documents;
  final bool isLoading;
  final String? error;

  const DocumentsState({
    this.documents = const [],
    this.isLoading = false,
    this.error,
  });

  DocumentsState copyWith({
    List<DocumentEntity>? documents,
    bool? isLoading,
    String? error,
  }) {
    return DocumentsState(
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────
class DocumentsNotifier extends StateNotifier<DocumentsState> {
  final DocumentsRepository _repository;

  DocumentsNotifier(this._repository) : super(const DocumentsState());

  Future<void> loadDocuments() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final docs = await _repository.getDocuments();
      state = state.copyWith(documents: docs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addNid({
    required String nidNumber,
    required String fullName,
    required String dateOfBirth,
    required String fatherName,
    required String motherName,
    required String address,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final doc = await _repository.addNid(
        nidNumber: nidNumber,
        fullName: fullName,
        dateOfBirth: dateOfBirth,
        fatherName: fatherName,
        motherName: motherName,
        address: address,
      );
      state = state.copyWith(
        documents: [doc, ...state.documents],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> addPassport({
    required String passportNumber,
    required String fullName,
    required String countryCode,
    required String dateOfBirth,
    required String expiryDate,
    required String issueDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final doc = await _repository.addPassport(
        passportNumber: passportNumber,
        fullName: fullName,
        countryCode: countryCode,
        dateOfBirth: dateOfBirth,
        expiryDate: expiryDate,
        issueDate: issueDate,
      );
      state = state.copyWith(
        documents: [doc, ...state.documents],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> revealDocument(String documentId) async {
    try {
      final revealed = await _repository.revealDocument(documentId);
      final updated = state.documents.map((d) {
        return d.id == documentId ? revealed : d;
      }).toList();
      state = state.copyWith(documents: updated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      await _repository.deleteDocument(documentId);
      final updated = state.documents.where((d) => d.id != documentId).toList();
      state = state.copyWith(documents: updated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final documentsNotifierProvider =
    StateNotifierProvider<DocumentsNotifier, DocumentsState>((ref) {
  final repository = ref.watch(documentsRepositoryProvider);
  return DocumentsNotifier(repository);
});
