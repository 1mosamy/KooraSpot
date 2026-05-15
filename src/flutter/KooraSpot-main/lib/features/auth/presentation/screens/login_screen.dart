import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/utils/validators.dart';
import '../cubit/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          if (state.user.isOwner) {
            context.go('/owner/dashboard');
          } else {
            context.go('/player/home');
          }
        } else if (state is AuthFailure) {
          final raw = state.message.toLowerCase();
          final isUnverified = raw.contains('verify') ||
              raw.contains('not verified') ||
              raw.contains('email verification') ||
              raw.contains('confirm your email');
          if (isUnverified) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: const Text('Please verify your email before logging in.'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'Verify',
                    textColor: Colors.white,
                    onPressed: () {
                      final email = _emailController.text.trim();
                      if (email.isNotEmpty) {
                        context.push('/verify-register-otp', extra: email);
                      }
                    },
                  ),
                ),
              );
          } else {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: const Text('Invalid email or password'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
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
          child: Stack(
            children: [
              // Decorative blurred circles
              Positioned(
                top: -80,
                left: -80,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: -120,
                right: -60,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.05),
                  ),
                ),
              ),

              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                                        color: AppColors.primary
                                            .withValues(alpha: 0.2),
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
                                        color: AppColors.primary
                                            .withValues(alpha: 0.4),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                              const Center(
                                child: Icon(
                                  Icons.stadium_rounded,
                                  size: 52,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Wordmark
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                            children: const [
                              TextSpan(
                                text: 'Koora',
                                style: TextStyle(color: AppColors.onSurface),
                              ),
                              TextSpan(
                                text: 'Spot',
                                style: TextStyle(color: AppColors.primary),
                              ),
                            ],
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
                                // Email
                                Text(
                                  'EMAIL ADDRESS',
                                  style: GoogleFonts.lexend(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: Validators.email,
                                  decoration: InputDecoration(
                                    hintText: 'email@example.com',
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                      color: AppColors.textHint,
                                      size: 20,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: AppRadius.mdAll,
                                      borderSide: const BorderSide(
                                          color: AppColors.inputBorder),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Password
                                Text(
                                  'PASSWORD',
                                  style: GoogleFonts.lexend(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  validator: Validators.password,
                                  decoration: InputDecoration(
                                    hintText: '••••••••',
                                    prefixIcon: const Icon(
                                      Icons.lock_outline,
                                      color: AppColors.textHint,
                                      size: 20,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: AppColors.textHint,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      }),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: AppRadius.mdAll,
                                      borderSide: const BorderSide(
                                          color: AppColors.inputBorder),
                                    ),
                                  ),
                                ),

                                // Forgot password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () =>
                                        context.push('/forgot-password'),
                                    child: Text(
                                      'Forgot Password?',
                                      style: GoogleFonts.lexend(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Login button
                                BlocBuilder<AuthCubit, AuthState>(
                                  builder: (context, state) {
                                    final isLoading = state is AuthLoading;
                                    return SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton(
                                        onPressed:
                                            isLoading ? null : _submit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: AppRadius.mdAll,
                                          ),
                                          elevation: 4,
                                          shadowColor:
                                              AppColors.primaryShadow,
                                        ),
                                        child: isLoading
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Text(
                                                'Login',
                                                style: GoogleFonts.lexend(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                ),
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

                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/register'),
                              child: Text(
                                'Register here',
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
