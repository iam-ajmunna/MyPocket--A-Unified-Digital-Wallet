import 'entities/bank_card_entity.dart';
import 'entities/mfs_account_entity.dart';

abstract class CardsMfsRepository {
  Future<List<BankCardEntity>> getCards();
  Future<BankCardEntity> createCard({
    required String bankName,
    required String lastFourDigits,
    required String expiryDate,
    required String cardholderName,
  });
  Future<BankCardEntity> confirmCard(String cardId);
  Future<void> deleteCard(String cardId);

  Future<List<MfsAccountEntity>> getMfsAccounts();
  Future<MfsAccountEntity> createMfsAccount({
    required String provider,
    required String accountNumber,
    required String accountName,
    bool smartSync = false,
  });
  Future<MfsAccountEntity> confirmMfsAccount(String mfsId);
  Future<void> deleteMfsAccount(String mfsId);
}
