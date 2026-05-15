import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/utils/ks_snackbar.dart';
import '../cubit/auth_cubit.dart';

/// Screen for verifying the OTP sent to the user's email after registration.
class VerifyRegisterOtpScreen extends StatefulWidget {
  final String email;

  const VerifyRegisterOtpScreen({super.key, required this.email});

  @override
  State<VerifyRegisterOtpScreen> createState() =>
      _VerifyRegisterOtpScreenState();
}

class _VerifyRegisterOtpScreenState extends State<VerifyRegisterOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verify() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().verifyRegisterEmail(
            email: widget.email,
            otpCode: _otpController.text.trim(),
          );
    }
  }

  void _resend() {
    context.read<AuthCubit>().resendVerificationOtp(widget.email);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is EmailVerificationSuccess) {
          KSSnackBar.success(context, 'Email verified successfully. Please login.');
          context.go('/login');
        } else if (state is EmailVerificationFailure) {
          KSSnackBar.error(
            context,
            state.message.isNotEmpty
                ? state.message
                : 'Invalid or expired OTP. Please try again.',
          );
        } else if (state is ResendOtpSuccess) {
          KSSnackBar.success(context, 'Verification OTP resent to your email.');
        } else if (state is ResendOtpFailure) {
          KSSnackBar.error(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                AppColors.primary.withValues(alpha: 0.12),
                Colors.white,
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo / Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mark_email_read_outlined,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Verify Your Email',
                      style: GoogleFonts.lexend(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the OTP sent to',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.email,
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.xlAll,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 30,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'OTP CODE',
                              style: GoogleFonts.lexend(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'OTP code is required';
                                }
                                if (v.trim().length < 4) {
                                  return 'Enter a valid OTP code';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'Enter 6-digit code',
                                counterText: '',
                                prefixIcon: const Icon(
                                  Icons.pin_outlined,
                                  color: AppColors.textHint,
                                  size: 20,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.mdAll,
                                  borderSide: const BorderSide(
                                      color: AppColors.inputBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: AppRadius.mdAll,
                                  borderSide: const BorderSide(
                                      color: AppColors.outlineVariant),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: AppRadius.mdAll,
                                  borderSide: const BorderSide(
                                      color: AppColors.primary, width: 2),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Verify button
                            BlocBuilder<AuthCubit, AuthState>(
                              builder: (context, state) {
                                final isLoading =
                                    state is EmailVerificationLoading;
                                return SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _verify,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: AppRadius.mdAll,
                                      ),
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
                                        : Text(
                                            'Verify',
                                            style: GoogleFonts.lexend(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 16),

                            // Resend OTP
                            Center(
                              child: BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, state) {
                                  final isResending = state is ResendOtpLoading;
                                  return TextButton(
                                    onPressed: isResending ? null : _resend,
                                    child: isResending
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.primary,
                                            ),
                                          )
                                        : Text(
                                            'Resend OTP',
                                            style: GoogleFonts.lexend(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Back to Login
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_back,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'Back to Login',
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
