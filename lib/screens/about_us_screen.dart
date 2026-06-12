import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_state.dart';
import '../services/translations.dart';
import '../utils/app_version.dart';
import '../theme.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _version = info.version;
      _buildNumber =
          logicalBuildNumber(info.buildNumber).toString();
    });
  }

  Future<void> _openWebsite() async {
    final uri = Uri.parse('https://expenseiqapp.com/#developer');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = state.language;
    const primaryColor = AppColors.primary;
    final fgColor = isDark ? AppColors.darkForeground : AppColors.foreground;
    final mutedColor =
        isDark ? AppColors.darkMutedForeground : AppColors.mutedForeground;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          Translations.t('about_us_nav', lang),
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: fgColor,
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
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white,
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
                    height: 72,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.account_balance_wallet,
                      size: 48,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'ExpenseIQ',
                  style: GoogleFonts.dmSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: fgColor,
                  ),
                ),
                if (_version.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${Translations.t('app_version_label', lang)} $_version · ${Translations.t('build_label', lang)} $_buildNumber',
                    style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
                  ),
                ],
                const SizedBox(height: 28),
                _AboutCard(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Translations.t('about_expenseiq', lang),
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        Translations.t('about_app_summary', lang),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          height: 1.6,
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _AboutCard(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Translations.t('main_features', lang),
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: fgColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _FeatureRow(
                        icon: Icons.document_scanner_outlined,
                        title: Translations.t('scan_receipts', lang),
                        subtitle: Translations.t('scan_receipts_desc', lang),
                        color: primaryColor,
                        fgColor: fgColor,
                        mutedColor: mutedColor,
                      ),
                      _FeatureRow(
                        icon: Icons.analytics_outlined,
                        title: Translations.t('track_spending', lang),
                        subtitle: Translations.t('track_spending_desc', lang),
                        color: primaryColor,
                        fgColor: fgColor,
                        mutedColor: mutedColor,
                      ),
                      _FeatureRow(
                        icon: Icons.account_balance_wallet_outlined,
                        title: Translations.t('budget_manager', lang),
                        subtitle: Translations.t('budget_manager_desc', lang),
                        color: primaryColor,
                        fgColor: fgColor,
                        mutedColor: mutedColor,
                      ),
                      _FeatureRow(
                        icon: Icons.ios_share_outlined,
                        title: Translations.t('export_data', lang),
                        subtitle: Translations.t('export_data_desc', lang),
                        color: primaryColor,
                        fgColor: fgColor,
                        mutedColor: mutedColor,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _AboutCard(
                  isDark: isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.public, color: primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            Translations.t('about_team_on_web_title', lang),
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: fgColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        Translations.t('about_team_on_web_body', lang),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          height: 1.55,
                          color: mutedColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _openWebsite,
                          icon: const Icon(Icons.open_in_new, size: 18),
                          label: Text(Translations.t('visit_website', lang)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(
                              color: primaryColor.withValues(alpha: 0.35),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => state.setCurrentScreen('contact_us'),
                    icon: const Icon(Icons.support_agent_outlined),
                    label: Text(Translations.t('contact_us', lang)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
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

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.isDark, required this.child});

  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.fgColor,
    required this.mutedColor,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color fgColor;
  final Color mutedColor;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: fgColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    height: 1.4,
                    color: mutedColor,
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
