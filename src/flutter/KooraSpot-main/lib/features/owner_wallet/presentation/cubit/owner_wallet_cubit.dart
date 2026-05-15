import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bookings/domain/repositories/booking_repository.dart';
import '../../../owner_fields/domain/repositories/owner_fields_repository.dart';
import '../../data/models/owner_wallet_models.dart';
import '../../domain/repositories/owner_wallet_repository.dart';

part 'owner_wallet_state.dart';

class OwnerWalletCubit extends Cubit<OwnerWalletState> {
  final OwnerWalletRepository _walletRepository;
  final OwnerFieldsRepository _fieldsRepository;
  final BookingRepository _bookingRepository;

  OwnerWalletCubit({
    required OwnerWalletRepository walletRepository,
    required OwnerFieldsRepository fieldsRepository,
    required BookingRepository bookingRepository,
  })  : _walletRepository = walletRepository,
        _fieldsRepository = fieldsRepository,
        _bookingRepository = bookingRepository,
        super(const OwnerWalletInitial());

  Future<void> loadWallet() async {
    emit(const OwnerWalletLoading());
    try {
      // Load summary, withdrawals, and booking history in parallel
      final results = await Future.wait([
        _walletRepository.getSummary(),
        _walletRepository.getWithdrawals(),
        _loadBookingTransactions(),
      ]);

      final summary = results[0] as OwnerWalletSummary;
      final withdrawals = results[1] as List<OwnerWithdrawalModel>;
      final bookingTransactions = results[2] as List<WalletTransaction>;

      // Map withdrawals to transactions
      final withdrawalTransactions = withdrawals.map((w) {
        DateTime? date;
        if (w.createdAt != null) {
          date = DateTime.tryParse(w.createdAt!);
        }
        return WalletTransaction(
          type: WalletTransactionType.withdrawal,
          title: 'Withdrawal',
          subtitle: '${w.walletNumber ?? 'Wallet'}${w.status != null ? ' • ${w.status}' : ''}',
          date: date,
          amount: w.amount,
          isPositive: false,
        );
      }).toList();

      // Merge and sort by date descending
      final allTransactions = [...bookingTransactions, ...withdrawalTransactions];
      allTransactions.sort((a, b) {
        if (a.date == null && b.date == null) return 0;
        if (a.date == null) return 1;
        if (b.date == null) return -1;
        return b.date!.compareTo(a.date!);
      });

      emit(OwnerWalletLoaded(
        summary: summary,
        transactions: allTransactions,
      ));
    } catch (e) {
      emit(OwnerWalletFailure(
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  /// Loads booking earnings from all owner fields.
  Future<List<WalletTransaction>> _loadBookingTransactions() async {
    final transactions = <WalletTransaction>[];
    try {
      final fields = await _fieldsRepository.getOwnerFields();
      for (final field in fields) {
        try {
          final fieldId = int.tryParse(field.id);
          if (fieldId == null) continue;
          final bookings = await _bookingRepository.getFieldBookings(fieldId);
          for (final booking in bookings) {
            // Exclude cancelled bookings
            if (booking.status.toLowerCase() == 'cancelled') continue;

            DateTime? date;
            if (booking.bookingDate.isNotEmpty) {
              date = DateTime.tryParse(booking.bookingDate);
            }

            transactions.add(WalletTransaction(
              type: WalletTransactionType.booking,
              title: booking.playerName.isNotEmpty
                  ? booking.playerName
                  : 'Booking #${booking.id}',
              subtitle:
                  '${field.name} • ${booking.bookingDate}',
              date: date,
              amount: booking.totalPrice,
              isPositive: true,
            ));
          }
        } catch (_) {
          // Skip field if its bookings fail — show partial data
        }
      }
    } catch (_) {
      // If fields fail entirely, return empty — summary still shows
    }
    return transactions;
  }

  Future<void> withdraw({
    required num amount,
    required String walletNumber,
  }) async {
    final currentState = state;
    if (currentState is! OwnerWalletLoaded) return;

    emit(currentState.copyWith(isWithdrawing: true));
    try {
      await _walletRepository.withdraw(
        amount: amount,
        walletNumber: walletNumber,
      );
      emit(const OwnerWithdrawalSuccess());
      // Refresh everything after withdrawal
      await loadWallet();
    } catch (e) {
      // Restore loaded state and surface error
      emit(currentState.copyWith(isWithdrawing: false));
      emit(OwnerWalletFailure(
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
