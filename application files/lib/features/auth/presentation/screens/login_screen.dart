import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_elevation.dart';

class CleanLoginScreen extends ConsumerStatefulWidget {
  const CleanLoginScreen({super.key});

  @override
  ConsumerState<CleanLoginScreen> createState() => _CleanLoginScreenState();
}

class _CleanLoginScreenState extends ConsumerState<CleanLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController(text: 'user@example.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      ref.read(authNotifierProvider.notifier).login(
            _identifierController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final colors = Theme.of(context).extension<AppColorsExtension>() ?? AppColorsExtension.dark;

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: colors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Brand Logo Header with Proportional Alignment
                  Center(
                    child: Image.asset(
                      'assets/MyWallet White Logo.png',
                      height: 120,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset('assets/MyWalletLogo.png', height: 110, fit: BoxFit.contain);
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),

                  // Brand Title & Tagline
                  Text(
                    'MyPocket',
                    textAlign: TextAlign.center,
                    style: AppTypography.displayLarge(colors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Unified Commercial Digital Wallet',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium(colors.textSecondary),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Glassmorphic Login Card (Wise & Revolut Inspired)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: AppRadius.radiusXl,
                      border: Border.all(color: colors.glassBorder, width: 1.5),
                      boxShadow: AppElevation.medium,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sign In to Your Wallet',
                          style: AppTypography.titleLarge(colors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enter your phone number or email address',
                          style: AppTypography.bodySmall(colors.textMuted),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Identifier Input (Phone or Email)
                        TextFormField(
                          controller: _identifierController,
                          keyboardType: TextInputType.emailAddress,
                          style: AppTypography.bodyMedium(colors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Email or Phone Number',
                            labelStyle: AppTypography.bodyMedium(colors.textSecondary),
                            prefixIcon: Icon(Icons.person_outline_rounded, color: colors.primary),
                            filled: true,
                            fillColor: colors.surfaceVariant.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.radiusMd,
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.radiusMd,
                              borderSide: BorderSide(color: colors.primary, width: 1.5),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email or phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Password Input
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: AppTypography.bodyMedium(colors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: AppTypography.bodyMedium(colors.textSecondary),
                            prefixIcon: Icon(Icons.lock_outline_rounded, color: colors.primary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                color: colors.textMuted,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: colors.surfaceVariant.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.radiusMd,
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.radiusMd,
                              borderSide: BorderSide(color: colors.primary, width: 1.5),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Login Action Button (Trust Teal Blue)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
                              elevation: 4,
                              shadowColor: colors.primary.withOpacity(0.4),
                            ),
                            onPressed: authState.isLoading ? null : _handleLogin,
                            child: authState.isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Text(
                                    'Unlock Wallet',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Register Redirection Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have a MyPocket account? ',
                        style: AppTypography.bodySmall(colors.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CleanRegisterScreen()),
                          );
                        },
                        child: Text(
                          'Register Now',
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
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
      ),
    );
  }
}
