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

class CleanDashboardScreen extends ConsumerStatefulWidget {
  const CleanDashboardScreen({super.key});

  @override
  ConsumerState<CleanDashboardScreen> createState() => _CleanDashboardScreenState();
}

class _CleanDashboardScreenState extends ConsumerState<CleanDashboardScreen> {
  final PageController _cardPageController = PageController(viewportFraction: 0.9);
  int _currentCardIndex = 0;
  bool _isBalanceVisible = true;

  @override
  void dispose() {
    _cardPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final notifState = ref.watch(notificationsNotifierProvider);
    final user = authState.user;
    final colors = Theme.of(context).extension<AppColorsExtension>() ?? AppColorsExtension.dark;

    return Scaffold(
      backgroundColor: const Color(0xFF070A11), // Deep Obsidian Apple Midnight
      appBar: AppBar(
        backgroundColor: const Color(0xFF070A11),
        elevation: 0,
        titleSpacing: AppSpacing.md,
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
            const SizedBox(width: 10),
            const Text(
              'MyPocket',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_rounded, color: Color(0xFF94A3B8), size: 24),
                if (notifState.unreadCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: Text(
                        '${notifState.unreadCount > 9 ? '9+' : notifState.unreadCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsCenterScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFF87171)),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // 1. Net Worth Balance Bar (Executive Apple Wallet Style)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'NET WORTH BALANCE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isBalanceVisible = !_isBalanceVisible;
                                    });
                                  },
                                  child: Icon(
                                    _isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: const Color(0xFF64748B),
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isBalanceVisible ? '৳ 1,48,250.00' : '৳ ••••••••',
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontFeatures: [FontFeature.tabularFigures()],
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 14),
                              SizedBox(width: 4),
                              Text(
                                'AES-256 Secured',
                                style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. Interactive 3D Apple Wallet Bank Card Carousel
                  SizedBox(
                    height: 205,
                    child: PageView(
                      controller: _cardPageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentCardIndex = index;
                        });
                      },
                      children: [
                        _buildAppleCard(
                          title: 'PRIME PLATINUM VISA',
                          cardNumber: '•••• •••• •••• 8842',
                          expiry: '08/29',
                          holder: user?.fullName.toUpperCase() ?? 'MD. TANVIR HOSSAIN',
                          gradient: const [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
                          accentColor: const Color(0xFF38BDF8),
                          logoText: 'VISA',
                        ),
                        _buildAppleCard(
                          title: 'BKASH PREMIUM VAULT',
                          cardNumber: '•••• •••• •••• 0171',
                          expiry: '01712345678',
                          holder: 'PERSONAL ACCOUNT',
                          gradient: const [Color(0xFFBE185D), Color(0xFF831843), Color(0xFF4C0519)],
                          accentColor: const Color(0xFFF472B6),
                          logoText: 'bKash',
                        ),
                        _buildAppleCard(
                          title: 'NAGAD SMART WALLET',
                          cardNumber: '•••• •••• •••• 0182',
                          expiry: '01812345678',
                          holder: 'MERCHANT ACCOUNT',
                          gradient: const [Color(0xFFC2410C), Color(0xFF9A3412), Color(0xFF431407)],
                          accentColor: const Color(0xFFFB923C),
                          logoText: 'NAGAD',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Carousel Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentCardIndex == index ? 24 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentCardIndex == index ? const Color(0xFF38BDF8) : const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  // 3. Sleek Quick Action Bar (Apple / Revolut Style)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildExecutiveActionButton(
                          icon: Icons.send_rounded,
                          label: 'Send',
                          color: const Color(0xFF38BDF8),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const CardsMfsScreen()));
                          },
                        ),
                        _buildExecutiveActionButton(
                          icon: Icons.qr_code_scanner_rounded,
                          label: 'Receive QR',
                          color: const Color(0xFF10B981),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const CardsMfsScreen()));
                          },
                        ),
                        _buildExecutiveActionButton(
                          icon: Icons.directions_subway_rounded,
                          label: 'Transit',
                          color: const Color(0xFFF59E0B),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const TransitVaultScreen()));
                          },
                        ),
                        _buildExecutiveActionButton(
                          icon: Icons.badge_rounded,
                          label: 'ID Vault',
                          color: const Color(0xFFA855F7),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const DocumentsVaultScreen()));
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 4. Commercial Vault Modules (Frosted Glass Cards)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'SECURE DIGITAL VAULTS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        _buildExecutiveVaultTile(
                          icon: Icons.credit_card_rounded,
                          title: 'Cards & MFS Accounts',
                          subtitle: 'bKash, Nagad, Upay & VISA Cards',
                          countText: '3 Accounts',
                          color: const Color(0xFF38BDF8),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const CardsMfsScreen()));
                          },
                        ),
                        _buildExecutiveVaultTile(
                          icon: Icons.fingerprint_rounded,
                          title: 'Government Identity Vault',
                          subtitle: 'Encrypted Smart NID & Passport',
                          countText: 'Biometric Protected',
                          color: const Color(0xFF10B981),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const DocumentsVaultScreen()));
                          },
                        ),
                        _buildExecutiveVaultTile(
                          icon: Icons.subway_rounded,
                          title: 'Dhaka MRT Transit Pass',
                          subtitle: 'Metro Rail & Bus Boarding QR Tokens',
                          countText: '৳ 350.00 Active',
                          color: const Color(0xFFF59E0B),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const TransitVaultScreen()));
                          },
                        ),
                        _buildExecutiveVaultTile(
                          icon: Icons.workspace_premium_rounded,
                          title: 'Academic & Skill Certificates',
                          subtitle: 'SSC/HSC, Olympiad & Skill Credentials',
                          countText: 'Verified Storage',
                          color: const Color(0xFFA855F7),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const CertificatesVaultScreen()));
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Moon AI Assistant Floating Mascot Overlay
          Positioned(
            right: 20,
            bottom: 30,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MoonChatScreen()));
              },
              child: const MoonFloatingBubble(),
            ),
          ),
        ],
      ),
    );
  }

  /// Apple Wallet 3D Card Widget
  Widget _buildAppleCard({
    required String title,
    required String cardNumber,
    required String expiry,
    required String holder,
    required List<Color> gradient,
    required Color accentColor,
    required String logoText,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.5),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header: Brand & NFC Wave
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: accentColor,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.wifi_rounded, color: Colors.white.withOpacity(0.7), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    logoText,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // EMV Chip Graphic
          Container(
            width: 42,
            height: 30,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFDE047), Color(0xFFCA8A04)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.black26),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(width: 1, color: Colors.black26),
                Container(width: 1, color: Colors.black26),
              ],
            ),
          ),

          // Card Number
          Text(
            cardNumber,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: Colors.white,
            ),
          ),

          // Cardholder Name & Expiry
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CARD HOLDER',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.5)),
                  ),
                  Text(
                    holder,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXPIRES / ACC',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.5)),
                  ),
                  Text(
                    expiry,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExecutiveActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFCBD5E1)),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutiveVaultTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String countText,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  countText,
                  style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF475569), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
