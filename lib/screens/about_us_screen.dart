import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../services/translations.dart';
import '../theme.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lang = state.language;
    const primaryColor = AppColors.primary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          Translations.t('about_us_nav', lang),
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryColor),
          onPressed: () => state.setCurrentScreen('profile'),
        ),
      ),
      body: Stack(
        children: [
          // Background Aesthetic
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 300,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.05),
              ),
            ),
          ),

          FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
              child: Column(
                children: [
                  // Welcome Header
                  _buildAnimatedItem(
                    index: 0,
                    child: Text(
                      Translations.t('about_us_welcome', lang),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // App Logo with subtle glow
                  _buildAnimatedItem(
                    index: 1,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.15),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/logo.png',
                        height: 80,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.account_balance_wallet,
                          size: 50,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Mission Section
                  _buildAnimatedItem(
                    index: 2,
                    child: _PremiumCard(
                      isDark: isDark,
                      primaryColor: primaryColor,
                      child: Column(
                        children: [
                          Text(
                            Translations.t('about_expenseiq', lang),
                            style: GoogleFonts.dmSans(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            Translations.t('expenseiq_mission', lang),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: isDark ? Colors.white70 : Colors.black87,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Main Features Section (Moved here)
                  _buildAnimatedItem(
                    index: 3,
                    child: Text(
                      Translations.t('main_features', lang),
                      style: GoogleFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildAnimatedItem(
                    index: 4,
                    child: _PremiumCard(
                      isDark: isDark,
                      primaryColor: primaryColor,
                      child: Column(
                        children: [
                          _buildFeatureItem(
                            icon: Icons.document_scanner_outlined,
                            title: Translations.t('scan_receipts', lang),
                            description: Translations.t('scan_receipts_desc', lang),
                            primaryColor: primaryColor,
                            isDark: isDark,
                            onTap: () => _showFeatureDialog(
                              context,
                              Translations.t('scan_receipts', lang),
                              Translations.t('scan_receipts_details', lang),
                              Icons.document_scanner_outlined,
                              primaryColor,
                              isDark,
                            ),
                          ),
                          _buildFeatureItem(
                            icon: Icons.analytics_outlined,
                            title: Translations.t('track_spending', lang),
                            description: Translations.t('track_spending_desc', lang),
                            primaryColor: primaryColor,
                            isDark: isDark,
                            onTap: () => _showFeatureDialog(
                              context,
                              Translations.t('track_spending', lang),
                              Translations.t('track_spending_details', lang),
                              Icons.analytics_outlined,
                              primaryColor,
                              isDark,
                            ),
                          ),
                          _buildFeatureItem(
                            icon: Icons.account_balance_wallet_outlined,
                            title: Translations.t('budget_manager', lang),
                            description: Translations.t('budget_manager_desc', lang),
                            primaryColor: primaryColor,
                            isDark: isDark,
                            onTap: () => _showFeatureDialog(
                              context,
                              Translations.t('budget_manager', lang),
                              Translations.t('budget_manager_details', lang),
                              Icons.account_balance_wallet_outlined,
                              primaryColor,
                              isDark,
                            ),
                          ),
                          _buildFeatureItem(
                            icon: Icons.savings_outlined,
                            title: Translations.t('save_more', lang),
                            description: Translations.t('save_more_desc', lang),
                            primaryColor: primaryColor,
                            isDark: isDark,
                            onTap: () => _showFeatureDialog(
                              context,
                              Translations.t('save_more', lang),
                              Translations.t('save_more_details', lang),
                              Icons.savings_outlined,
                              primaryColor,
                              isDark,
                            ),
                          ),
                          _buildFeatureItem(
                            icon: Icons.ios_share_outlined,
                            title: Translations.t('export_data', lang),
                            description: Translations.t('export_data_desc', lang),
                            primaryColor: primaryColor,
                            isDark: isDark,
                            isLast: true,
                            onTap: () => _showFeatureDialog(
                              context,
                              Translations.t('export_data', lang),
                              Translations.t('export_data_details', lang),
                              Icons.ios_share_outlined,
                              primaryColor,
                              isDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 56),

                  // Team Members
                  _buildAnimatedItem(
                    index: 5,
                    child: Text(
                      Translations.t('meet_our_team', lang),
                      style: GoogleFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildTeamList(lang, primaryColor, isDark),

                  const SizedBox(height: 56),

                  // Dean Academic Mentorship Spotlight
                  _buildAnimatedItem(
                    index: 10,
                    child: Text(
                      Translations.t('academic_mentorship', lang),
                      style: GoogleFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildDeanSpotlight(lang, primaryColor, isDark),
                  const SizedBox(height: 56),

                  // Contact Button (Integrated Theme Style)
                  _buildAnimatedItem(
                    index: 12,
                    child: ElevatedButton.icon(
                      onPressed: () => state.setCurrentScreen('contact_us'),
                      icon: const Icon(Icons.mail_outline),
                      label: Text(Translations.t('contact_the_team', lang)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 8,
                        shadowColor: primaryColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamList(String lang, Color primaryColor, bool isDark) {
    final members = [
      (key: 'eric', img: 'assets/eric.jpg'),
      (key: 'carlton', img: 'assets/carlton.jpg'),
      (key: 'abdoulie', img: 'assets/abdoulie.jpg'),
      (key: 'nynthia', img: 'assets/nynthia.jpg'),
    ];

    return Column(
      children: List.generate(members.length, (i) {
        final m = members[i];
        return _buildAnimatedItem(
          index: 4 + i,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _PremiumMemberCard(
              name: Translations.t('member_${m.key}_name', lang),
              role: Translations.t('member_${m.key}_role', lang),
              bio: Translations.t('member_${m.key}_bio', lang),
              email: Translations.t('member_${m.key}_email', lang),
              imagePath: m.img,
              primaryColor: primaryColor,
              isDark: isDark,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDeanSpotlight(String lang, Color primaryColor, bool isDark) {
    return _buildAnimatedItem(
      index: 9,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: isDark 
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [Colors.white, const Color(0xFFF8FAFC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Highly framed portrait
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: isDark ? 0.3 : 0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                // Triple Border Frame
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.asset(
                        'assets/dean.jpg',
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 110,
                          height: 110,
                          color: Colors.grey[200],
                          child: Icon(Icons.school, size: 50, color: primaryColor),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              Translations.t('dean_title', lang),
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              Translations.t('dean_desc', lang),
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: primaryColor.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            Text(
              Translations.t('special_thanks_dean', lang),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.7,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeatureDialog(
    BuildContext context,
    String title,
    String details,
    IconData icon,
    Color primaryColor,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primaryColor, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              details,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: primaryColor.withValues(alpha: 0.2)),
                ),
              ),
              child: Text(
                'Got it',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color primaryColor,
    required bool isDark,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black54,
                          height: 1.4,
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
    );
  }

  Widget _buildAnimatedItem({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 100)),
      curve: Curves.easeOutQuart,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _PremiumCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final Color primaryColor;

  const _PremiumCard({
    required this.child,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _PremiumMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final String bio;
  final String email;
  final String imagePath;
  final Color primaryColor;
  final bool isDark;

  const _PremiumMemberCard({
    required this.name,
    required this.role,
    required this.bio,
    required this.email,
    required this.imagePath,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return _PremiumCard(
      isDark: isDark,
      primaryColor: primaryColor,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor.withValues(alpha: 0.3), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: Image.asset(
                imagePath,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[200],
                  child: Icon(Icons.person, size: 30, color: primaryColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.dmSans(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  bio,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.4,
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
