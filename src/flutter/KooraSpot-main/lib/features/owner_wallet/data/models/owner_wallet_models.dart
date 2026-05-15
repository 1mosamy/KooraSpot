/// Wallet summary returned by GET /OwnerWallet/summary.
class OwnerWalletSummary {
  final num totalBookingsAmount;
  final num platformCommission;
  final num totalWithdrawn;
  final num availableBalance;

  const OwnerWalletSummary({
    required this.totalBookingsAmount,
    required this.platformCommission,
    required this.totalWithdrawn,
    required this.availableBalance,
  });

  factory OwnerWalletSummary.fromJson(Map<String, dynamic> json) {
    // Support common backend naming variants
    final total = (json['totalBookingsAmount'] ??
            json['totalEarnings'] ??
            json['totalEarned'] ??
            json['totalBookingAmount'] ??
            0) as num;
    final commission = (json['platformCommission'] ??
            json['commission'] ??
            json['appCommission'] ??
            0) as num;
    final withdrawn = (json['totalWithdrawn'] ??
            json['withdrawn'] ??
            0) as num;
    final balance = (json['availableBalance'] ??
            json['balance'] ??
            0) as num;

    return OwnerWalletSummary(
      totalBookingsAmount: total,
      platformCommission: commission != 0 ? commission : total * 0.10,
      totalWithdrawn: withdrawn,
      availableBalance: balance != 0
          ? balance
          : total - (commission != 0 ? commission : total * 0.10) - withdrawn,
    );
  }

  /// Empty summary for initial/loading state.
  static const empty = OwnerWalletSummary(
    totalBookingsAmount: 0,
    platformCommission: 0,
    totalWithdrawn: 0,
    availableBalance: 0,
  );
}

/// Single withdrawal record from GET /OwnerWallet/withdrawals.
class OwnerWithdrawalModel {
  final int? id;
  final num amount;
  final String? walletNumber;
  final String? status;
  final String? createdAt;

  const OwnerWithdrawalModel({
    this.id,
    required this.amount,
    this.walletNumber,
    this.status,
    this.createdAt,
  });

  factory OwnerWithdrawalModel.fromJson(Map<String, dynamic> json) {
    return OwnerWithdrawalModel(
      id: json['id'] as int?,
      amount: (json['amount'] ?? 0) as num,
      walletNumber: json['walletNumber'] as String? ?? json['wallet'] as String?,
      status: json['status'] as String?,
      createdAt: json['createdAt'] as String? ?? json['date'] as String?,
    );
  }
}

/// Unified transaction item for the history list.
enum WalletTransactionType { booking, withdrawal }

class WalletTransaction {
  final WalletTransactionType type;
  final String title;
  final String subtitle;
  final DateTime? date;
  final num amount;
  final bool isPositive;

  const WalletTransaction({
    required this.type,
    required this.title,
    required this.subtitle,
    this.date,
    required this.amount,
    required this.isPositive,
  });
}
