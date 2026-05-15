import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/utils/ks_snackbar.dart';
import '../../data/models/owner_wallet_models.dart';
import '../cubit/owner_wallet_cubit.dart';
import '../widgets/withdraw_bottom_sheet.dart';

class OwnerEarningsScreen extends StatefulWidget {
  const OwnerEarningsScreen({super.key});

  @override
  State<OwnerEarningsScreen> createState() => _OwnerEarningsScreenState();
}

class _OwnerEarningsScreenState extends State<OwnerEarningsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OwnerWalletCubit>().loadWallet();
  }

  void _openWithdrawSheet(OwnerWalletSummary summary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<OwnerWalletCubit>(),
        child: WithdrawBottomSheet(availableBalance: summary.availableBalance),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('Earnings',
            style: GoogleFonts.lexend(
                fontSize: 20, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: BlocConsumer<OwnerWalletCubit, OwnerWalletState>(
        listener: (context, state) {
          if (state is OwnerWithdrawalSuccess) {
            KSSnackBar.success(
                context, 'Withdrawal request submitted successfully.');
          } else if (state is OwnerWalletFailure) {
            KSSnackBar.error(context, state.message);
          }
        },
        buildWhen: (_, curr) =>
            curr is OwnerWalletLoading ||
            curr is OwnerWalletLoaded ||
            curr is OwnerWalletFailure,
        builder: (context, state) {
          if (state is OwnerWalletLoading) {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is OwnerWalletLoaded) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () =>
                  context.read<OwnerWalletCubit>().loadWallet(),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ── Available Balance Card ──────────────
                  _BalanceCard(summary: state.summary),

                  const SizedBox(height: 14),

                  // ── Two small cards row ─────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _SmallStatCard(
                          icon: Icons.trending_up_rounded,
                          label: 'Total Earned',
                          value:
                              '${state.summary.totalBookingsAmount.toStringAsFixed(0)} EGP',
                          iconColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SmallStatCard(
                          icon: Icons.percent_rounded,
                          label: 'Platform Fee 10%',
                          value:
                              '${state.summary.platformCommission.toStringAsFixed(0)} EGP',
                          iconColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Withdraw button ─────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: state.summary.availableBalance > 0
                          ? () => _openWithdrawSheet(state.summary)
                          : null,
                      icon: const Icon(Icons.account_balance_wallet_outlined,
                          size: 20),
                      label: Text('Withdraw Funds',
                          style: GoogleFonts.lexend(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.3),
                        disabledForegroundColor: Colors.white70,
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.mdAll),
                        elevation: 4,
                        shadowColor: AppColors.primaryShadow,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Transaction History ─────────────────
                  Text('Transaction History',
                      style: GoogleFonts.lexend(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),

                  if (state.transactions.isEmpty)
                    _EmptyTransactions()
                  else
                    ...state.transactions.map(_buildTransactionTile),
                ],
              ),
            );
          }

          if (state is OwnerWalletFailure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text('Failed to load earnings',
                      style: GoogleFonts.lexend(
                          fontSize: 16, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                          fontSize: 13, color: AppColors.textHint)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<OwnerWalletCubit>().loadWallet(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildTransactionTile(WalletTransaction tx) {
    final isBooking = tx.type == WalletTransactionType.booking;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isBooking
                  ? AppColors.successLight
                  : AppColors.errorContainer,
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(
              isBooking ? Icons.payments_outlined : Icons.arrow_downward,
              color: isBooking ? AppColors.primary : AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.title,
                    style: GoogleFonts.lexend(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(tx.subtitle,
                    style: GoogleFonts.lexend(
                        fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          // Amount
          Text(
            '${tx.isPositive ? '+' : '-'}${tx.amount.toStringAsFixed(0)} EGP',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: tx.isPositive ? AppColors.primary : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Available Balance Card ─────────────────────────────

class _BalanceCard extends StatelessWidget {
  final OwnerWalletSummary summary;
  const _BalanceCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: AppRadius.mdAll,
            ),
            child: const Icon(Icons.account_balance_wallet,
                color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Available Balance',
                    style: GoogleFonts.lexend(
                        fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  '${summary.availableBalance.toStringAsFixed(0)} EGP',
                  style: GoogleFonts.lexend(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small Stat Card ─────────────────────────────────────

class _SmallStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _SmallStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: GoogleFonts.lexend(
                  fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.lexend(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ── Empty Transactions ──────────────────────────────────

class _EmptyTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 56, color: AppColors.textHint.withValues(alpha: 0.4)),
          const SizedBox(height: 14),
          Text('No transactions yet',
              style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(
            'Your bookings and withdrawals\nwill appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
                fontSize: 13, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}
