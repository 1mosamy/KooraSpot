import '../../data/models/owner_wallet_models.dart';

/// Owner wallet repository interface.
abstract class OwnerWalletRepository {
  /// Fetches the wallet summary (balance, earnings, commission, withdrawn).
  Future<OwnerWalletSummary> getSummary();

  /// Submits a withdrawal request.
  Future<void> withdraw({required num amount, required String walletNumber});

  /// Fetches the list of withdrawal records.
  Future<List<OwnerWithdrawalModel>> getWithdrawals();
}
