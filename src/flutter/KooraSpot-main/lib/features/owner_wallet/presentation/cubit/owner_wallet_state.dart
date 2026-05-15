part of 'owner_wallet_cubit.dart';

sealed class OwnerWalletState extends Equatable {
  const OwnerWalletState();
  @override
  List<Object?> get props => [];
}

class OwnerWalletInitial extends OwnerWalletState {
  const OwnerWalletInitial();
}

class OwnerWalletLoading extends OwnerWalletState {
  const OwnerWalletLoading();
}

class OwnerWalletLoaded extends OwnerWalletState {
  final OwnerWalletSummary summary;
  final List<WalletTransaction> transactions;
  final bool isWithdrawing;

  const OwnerWalletLoaded({
    required this.summary,
    required this.transactions,
    this.isWithdrawing = false,
  });

  OwnerWalletLoaded copyWith({
    OwnerWalletSummary? summary,
    List<WalletTransaction>? transactions,
    bool? isWithdrawing,
  }) {
    return OwnerWalletLoaded(
      summary: summary ?? this.summary,
      transactions: transactions ?? this.transactions,
      isWithdrawing: isWithdrawing ?? this.isWithdrawing,
    );
  }

  @override
  List<Object?> get props => [summary, transactions, isWithdrawing];
}

class OwnerWalletFailure extends OwnerWalletState {
  final String message;
  const OwnerWalletFailure({required this.message});
  @override
  List<Object?> get props => [message];
}

/// Transient state emitted on successful withdrawal, before loadWallet refreshes.
class OwnerWithdrawalSuccess extends OwnerWalletState {
  const OwnerWithdrawalSuccess();
}
