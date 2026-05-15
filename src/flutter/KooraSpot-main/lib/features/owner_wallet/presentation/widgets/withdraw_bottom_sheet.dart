import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/utils/ks_snackbar.dart';
import '../cubit/owner_wallet_cubit.dart';

/// Bottom sheet for submitting a withdrawal request.
class WithdrawBottomSheet extends StatefulWidget {
  final num availableBalance;

  const WithdrawBottomSheet({super.key, required this.availableBalance});

  @override
  State<WithdrawBottomSheet> createState() => _WithdrawBottomSheetState();
}

class _WithdrawBottomSheetState extends State<WithdrawBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _walletController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill amount with available balance
    if (widget.availableBalance > 0) {
      _amountController.text = widget.availableBalance.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _walletController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = num.tryParse(_amountController.text.trim());
    if (amount == null) return;

    context.read<OwnerWalletCubit>().withdraw(
          amount: amount,
          walletNumber: _walletController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OwnerWalletCubit, OwnerWalletState>(
      listener: (context, state) {
        if (state is OwnerWithdrawalSuccess) {
          Navigator.of(context).pop(); // close sheet
        } else if (state is OwnerWalletFailure) {
          KSSnackBar.error(context, state.message);
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: AppRadius.fullAll,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text('Withdraw Funds',
                    style: GoogleFonts.lexend(
                        fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  'Available: ${widget.availableBalance.toStringAsFixed(0)} EGP',
                  style: GoogleFonts.lexend(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),

                // Amount
                _buildLabel('AMOUNT (EGP)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Amount is required';
                    }
                    final amount = num.tryParse(v.trim());
                    if (amount == null || amount <= 0) {
                      return 'Enter a valid amount';
                    }
                    if (amount > widget.availableBalance) {
                      return 'Amount exceeds available balance';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter amount',
                    prefixIcon: const Icon(Icons.payments_outlined,
                        color: AppColors.textHint, size: 20),
                    border: OutlineInputBorder(
                        borderRadius: AppRadius.mdAll,
                        borderSide:
                            const BorderSide(color: AppColors.outlineVariant)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.mdAll,
                        borderSide:
                            const BorderSide(color: AppColors.outlineVariant)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.mdAll,
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2)),
                  ),
                ),
                const SizedBox(height: 16),

                // Wallet Number
                _buildLabel('WALLET NUMBER'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _walletController,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Wallet number is required';
                    }
                    if (v.trim().length < 10) {
                      return 'Enter a valid wallet number';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '01XXXXXXXXX',
                    prefixIcon: const Icon(Icons.account_balance_wallet_outlined,
                        color: AppColors.textHint, size: 20),
                    border: OutlineInputBorder(
                        borderRadius: AppRadius.mdAll,
                        borderSide:
                            const BorderSide(color: AppColors.outlineVariant)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.mdAll,
                        borderSide:
                            const BorderSide(color: AppColors.outlineVariant)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.mdAll,
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 2)),
                  ),
                ),
                const SizedBox(height: 28),

                // Submit button
                BlocBuilder<OwnerWalletCubit, OwnerWalletState>(
                  builder: (context, state) {
                    final isLoading = state is OwnerWalletLoaded &&
                        state.isWithdrawing;
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.mdAll),
                          elevation: 4,
                          shadowColor: AppColors.primaryShadow,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text('Submit Withdrawal',
                                style: GoogleFonts.lexend(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.lexend(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 0.96,
      ),
    );
  }
}
