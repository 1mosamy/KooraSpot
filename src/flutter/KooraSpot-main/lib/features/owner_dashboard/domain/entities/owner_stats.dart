import 'package:equatable/equatable.dart';

/// Owner dashboard stats.
class OwnerStats extends Equatable {
  final int todayBookings;
  final double weeklyRevenue;
  final String currency;
  final int courtsCount;

  const OwnerStats({
    required this.todayBookings,
    required this.weeklyRevenue,
    this.currency = 'EGP',
    required this.courtsCount,
  });

  /// Total earned (alias for weeklyRevenue which is now totalBookingsAmount).
  double get totalEarned => weeklyRevenue;

  String get formattedRevenue {
    // Show decimals only when non-zero fraction
    final isWhole = weeklyRevenue == weeklyRevenue.truncateToDouble();
    final formatted = isWhole
        ? weeklyRevenue.toInt().toString()
        : weeklyRevenue.toStringAsFixed(2);
    return '$formatted $currency';
  }

  @override
  List<Object?> get props => [todayBookings, weeklyRevenue, courtsCount];
}
