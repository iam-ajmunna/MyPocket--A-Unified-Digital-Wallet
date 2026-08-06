import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../../cards_mfs/presentation/screens/cards_mfs_screen.dart';
import '../../../documents/presentation/screens/documents_vault_screen.dart';
import '../../../transit/presentation/screens/transit_vault_screen.dart';
import '../../../certificates/presentation/screens/certificates_vault_screen.dart';
import '../../../ai/presentation/widgets/moon_floating_bubble.dart';
import '../../../notifications/presentation/screens/notifications_center_screen.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../ai/presentation/screens/moon_chat_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_elevation.dart';

class CleanDashboardScreen extends ConsumerWidget {
  const CleanDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final notifState = ref.watch(notificationsNotifierProvider);
    final user = authState.user;
    final colors = Theme.of(context).extension<AppColorsExtension>() ?? AppColorsExtension.dark;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/MyWallet White Logo.png',
              height: 32,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/MyWalletLogo.png', height: 32, fit: BoxFit.contain);
              },
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'MyPocket',
              style: AppTypography.headlineMedium(colors.textPrimary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications_none_rounded, color: colors.textSecondary, size: 26),
                if (notifState.unreadCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${notifState.unreadCount > 9 ? '9+' : notifState.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsCenterScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout_rounded, color: colors.error),
            tooltip: 'Sign Out',
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Commercial Fintech Hero Card (Wise / Revolut / Google Wallet Benchmark)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.primary, colors.primaryVariant, const Color(0xFF0369A1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: AppRadius.radiusXl,
                      boxShadow: AppElevation.high,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              child: Text(
                                user?.fullName.isNotEmpty == true
                                    ? user!.fullName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Available Balance',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '৳ 48,250.00',
                                    style: AppTypography.tabularBalance(Colors.white, fontSize: 26),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colors.secondaryAccent.withOpacity(0.25),
                                borderRadius: AppRadius.radiusMd,
                                border: Border.all(color: colors.secondaryAccent.withOpacity(0.5)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.shield_rounded, color: Colors.white, size: 13),
                                  SizedBox(width: 4),
                                  Text(
                                    'AES-256',
                                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Divider(color: Colors.white.withOpacity(0.2)),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              user?.fullName ?? 'Valued User',
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Quick Action Grid (DESIGN_AGENTS.md Standard)
                  Text(
                    'Quick Actions',
                    style: AppTypography.titleLarge(colors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickActionButton(
                        context,
                        icon: Icons.credit_card_rounded,
                        label: 'Cards & MFS',
                        color: colors.primary,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CardsMfsScreen()),
                          );
                        },
                      ),
                      _buildQuickActionButton(
                        context,
                        icon: Icons.badge_rounded,
                        label: 'ID Vault',
                        color: colors.secondaryAccent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DocumentsVaultScreen()),
                          );
                        },
                      ),
                      _buildQuickActionButton(
                        context,
                        icon: Icons.directions_subway_rounded,
                        label: 'Transit',
                        color: colors.warning,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TransitVaultScreen()),
                          );
                        },
                      ),
                      _buildQuickActionButton(
                        context,
                        icon: Icons.workspace_premium_rounded,
                        label: 'Certificates',
                        color: colors.info,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CertificatesVaultScreen()),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Wallet Features Overview Tiles
                  Text(
                    'Digital Wallet Vaults',
                    style: AppTypography.titleLarge(colors.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  _buildVaultTile(
                    context,
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'Cards & MFS Account Vault',
                    subtitle: 'bKash, Nagad, Upay & VISA/Mastercard reference cards',
                    color: colors.primary,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CardsMfsScreen()));
                    },
                  ),
                  _buildVaultTile(
                    context,
                    icon: Icons.fingerprint_rounded,
                    title: 'Secure Document Vault',
                    subtitle: 'Envelope-encrypted Smart NID & Passport storage',
                    color: colors.secondaryAccent,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const DocumentsVaultScreen()));
                    },
                  ),
                  _buildVaultTile(
                    context,
                    icon: Icons.subway_rounded,
                    title: 'Transit Pass Manager',
                    subtitle: 'Dhaka MRT Pass, Bus & Railway boarding QR tokens',
                    color: colors.warning,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TransitVaultScreen()));
                    },
                  ),
                  _buildVaultTile(
                    context,
                    icon: Icons.verified_user_rounded,
                    title: 'Academic & Skill Certificates',
                    subtitle: 'Verified credentials, SSC/HSC & Olympiad awards',
                    color: colors.info,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CertificatesVaultScreen()));
                    },
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Moon AI Mascot Assistant Bubble Overlay
          Positioned(
            right: 20,
            bottom: 30,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MoonChatScreen()),
                );
              },
              child: const MoonFloatingBubble(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).extension<AppColorsExtension>() ?? AppColorsExtension.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusLg,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: AppRadius.radiusLg,
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.bodySmall(colors.textPrimary).copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildVaultTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).extension<AppColorsExtension>() ?? AppColorsExtension.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusLg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: colors.glassBorder),
            boxShadow: AppElevation.low,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelLarge(colors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall(colors.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
