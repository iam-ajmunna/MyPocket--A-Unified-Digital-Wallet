import '../entities/bank_card_entity.dart';
import '../entities/mfs_account_entity.dart';

abstract class CardsMfsRepository {
  Future<List<BankCardEntity>> getCards();
  Future<BankCardEntity> addCard({
    required String bankName,
    required String cardHolderName,
    required String cardNumber,
    required String expiryMonthYear,
  });
  Future<void> deleteCard(String cardId);

  Future<List<MfsAccountEntity>> getMfsAccounts();
  Future<MfsAccountEntity> addMfsAccount({
    required String providerName,
    required String accountNumber,
  });
  Future<void> deleteMfsAccount(String mfsId);
}
