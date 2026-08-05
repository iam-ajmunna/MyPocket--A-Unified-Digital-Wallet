import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/repositories/cards_mfs_repository_impl.dart';
import '../../domain/entities/bank_card_entity.dart';
import '../../domain/entities/mfs_account_entity.dart';
import '../../domain/repositories/cards_mfs_repository.dart';

final cardsMfsRepositoryProvider = Provider<CardsMfsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CardsMfsRepositoryImpl(apiClient: apiClient);
});

class CardsMfsState {
  final bool isLoading;
  final List<BankCardEntity> cards;
  final List<MfsAccountEntity> mfsAccounts;
  final String? errorMessage;

  CardsMfsState({
    this.isLoading = false,
    this.cards = const [],
    this.mfsAccounts = const [],
    this.errorMessage,
  });

  CardsMfsState copyWith({
    bool? isLoading,
    List<BankCardEntity>? cards,
    List<MfsAccountEntity>? mfsAccounts,
    String? errorMessage,
  }) {
    return CardsMfsState(
      isLoading: isLoading ?? this.isLoading,
      cards: cards ?? this.cards,
      mfsAccounts: mfsAccounts ?? this.mfsAccounts,
      errorMessage: errorMessage,
    );
  }
}

class CardsMfsNotifier extends StateNotifier<CardsMfsState> {
  final CardsMfsRepository _repository;

  CardsMfsNotifier(this._repository) : super(CardsMfsState()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final results = await Future.wait([
        _repository.getCards(),
        _repository.getMfsAccounts(),
      ]);
      state = state.copyWith(
        isLoading: false,
        cards: results[0] as List<BankCardEntity>,
        mfsAccounts: results[1] as List<MfsAccountEntity>,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> addCard(String bankName, String lastFourDigits, String expiryDate, String cardholderName) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.createCard(
        bankName: bankName,
        lastFourDigits: lastFourDigits,
        expiryDate: expiryDate,
        cardholderName: cardholderName,
      );
      await loadAll();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> confirmCard(String cardId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.confirmCard(cardId);
      await loadAll();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> addMfs(String provider, String accountNumber, String accountName, {bool smartSync = false}) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.createMfsAccount(
        provider: provider,
        accountNumber: accountNumber,
        accountName: accountName,
        smartSync: smartSync,
      );
      await loadAll();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> confirmMfs(String mfsId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.confirmMfsAccount(mfsId);
      await loadAll();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> deleteCard(String cardId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.deleteCard(cardId);
      await loadAll();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> deleteMfs(String mfsId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.deleteMfsAccount(mfsId);
      await loadAll();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString().replaceAll('Exception: ', ''));
    }
  }
}

final cardsMfsNotifierProvider = StateNotifierProvider<CardsMfsNotifier, CardsMfsState>((ref) {
  final repository = ref.watch(cardsMfsRepositoryProvider);
  return CardsMfsNotifier(repository);
});
