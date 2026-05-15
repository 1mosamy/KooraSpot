import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/constants/app_strings.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/utils/validators.dart';
import '../cubit/auth_cubit.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = 'Player';
  String? _selectedCity;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().register(
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
            role: _selectedRole,
            city: _selectedCity ?? '',
            phoneNumber: _phoneController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthRegistered) {
          if (state.needsOtpVerification) {
            // ── OTP verification required ────────────────
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Account created. Please verify your email.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF016D47),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(milliseconds: 2500),
                ),
              );
            Future.delayed(const Duration(milliseconds: 700), () {
              if (context.mounted) {
                context.push('/verify-register-otp', extra: state.email);
              }
            });
          } else {
            // ── No OTP needed → go to login ──────────────
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Account created successfully. Please login.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF016D47),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(milliseconds: 2500),
                ),
              );
            Future.delayed(const Duration(milliseconds: 700), () {
              if (context.mounted) {
                context.go('/login');
              }
            });
          }
        } else if (state is AuthFailure) {
          // ── Error ─────────────────────────────────────────
          final raw = state.message.toLowerCase();
          final isDuplicateEmail = raw.contains('invalid') ||
              raw.contains('already') ||
              raw.contains('exist') ||
              raw.contains('duplicate') ||
              raw.contains('taken') ||
              raw.contains('registered');
          final message = isDuplicateEmail
              ? 'This email is already registered. Please login instead.'
              : state.message.isNotEmpty
                  ? state.message
                  : 'Registration failed. Please try again.';

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFFBA1A1A),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                duration: const Duration(seconds: 4),
              ),
            );
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  children: [
                    // Logo
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Transform.rotate(
                              angle: 0.05,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Transform.rotate(
                              angle: -0.05,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.4),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          const Center(
                            child: Icon(Icons.stadium_rounded, size: 52, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5),
                        children: const [
                          TextSpan(text: 'Koora', style: TextStyle(color: AppColors.onSurface)),
                          TextSpan(text: 'Spot', style: TextStyle(color: AppColors.primary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.joinNetwork,
                      style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),

                    // Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.xlAll,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 30, offset: const Offset(0, 8)),
                        ],
                        border: Border.all(color: AppColors.surfaceContainerLow),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Role toggle
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: AppRadius.mdAll,
                                border: Border.all(color: AppColors.surfaceContainerHigh),
                              ),
                              child: Row(
                                children: [
                                  _buildRoleTab('Player'),
                                  _buildRoleTab('Owner'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Full Name
                            _buildLabel('FULL NAME'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _fullNameController,
                              validator: (v) => Validators.required(v, 'Full name'),
                              decoration: _inputDecoration('Enter your full name', Icons.person_outline),
                            ),
                            const SizedBox(height: 16),

                            // Email
                            _buildLabel('EMAIL ADDRESS'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email,
                              decoration: _inputDecoration('you@example.com', Icons.email_outlined),
                            ),
                            const SizedBox(height: 16),

                            // Phone Number
                            _buildLabel('PHONE NUMBER'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              validator: Validators.phoneRequired,
                              decoration: _inputDecoration('01XXXXXXXXX', Icons.phone_outlined),
                            ),
                            const SizedBox(height: 16),

                            // Password
                            _buildLabel('PASSWORD'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              validator: Validators.password,
                              decoration: _inputDecoration('Create a strong password', Icons.lock_outline).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textHint, size: 20),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Confirm Password
                            _buildLabel('CONFIRM PASSWORD'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirm,
                              validator: (v) => Validators.confirmPassword(v, _passwordController.text),
                              decoration: _inputDecoration('Repeat your password', Icons.lock_reset_outlined).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textHint, size: 20),
                                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // City dropdown
                            _buildLabel('CITY'),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedCity,
                              validator: Validators.city,
                              decoration: _inputDecoration('Select your city', Icons.location_on_outlined),
                              items: AppStrings.cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
                              onChanged: (v) => setState(() => _selectedCity = v),
                            ),
                            const SizedBox(height: 24),

                            // Register button
                            BlocBuilder<AuthCubit, AuthState>(
                              builder: (context, state) {
                                final isLoading = state is AuthRegistering;
                                return SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
                                      elevation: 4,
                                      shadowColor: AppColors.primaryShadow,
                                    ),
                                    child: isLoading
                                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text('Register', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w700)),
                                              const SizedBox(width: 8),
                                              const Icon(Icons.arrow_forward, size: 20),
                                            ],
                                          ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account? ', style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textSecondary)),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text('Login here', style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        ),
                      ],
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

  Widget _buildRoleTab(String role) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: AppRadius.smAll,
            boxShadow: isSelected
                ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          child: Center(
            child: Text(
              role,
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
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

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
      border: OutlineInputBorder(borderRadius: AppRadius.mdAll, borderSide: const BorderSide(color: AppColors.outlineVariant)),
      enabledBorder: OutlineInputBorder(borderRadius: AppRadius.mdAll, borderSide: const BorderSide(color: AppColors.outlineVariant)),
      focusedBorder: OutlineInputBorder(borderRadius: AppRadius.mdAll, borderSide: const BorderSide(color: AppColors.primary, width: 2)),
    );
  }
}
