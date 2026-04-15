import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';
import 'scan_screen.dart';
import '../services/translations.dart';

class MainScaffold extends StatefulWidget {
  final String currentScreen;
  const MainScaffold({super.key, required this.currentScreen});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late PageController _pageController;
  final List<String> _screens = [
    'dashboard',
    'history',
    'scan',
    'analytics',
    'profile'
  ];

  @override
  void initState() {
    super.initState();
    int initialIndex = _screens.indexOf(widget.currentScreen);
    if (widget.currentScreen == 'ocr') initialIndex = _screens.indexOf('scan');
    if (initialIndex == -1) initialIndex = 0;
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void didUpdateWidget(covariant MainScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentScreen != widget.currentScreen) {
      int index = _screens.indexOf(widget.currentScreen);
      if (widget.currentScreen == 'ocr') index = _screens.indexOf('scan');
      if (index != -1 &&
          _pageController.hasClients &&
          _pageController.page?.round() != index) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    final state = context.read<AppState>();
    if (state.currentScreen != _screens[index]) {
      state.setCurrentScreen(_screens[index], replace: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? AppColors.darkCard : AppColors.card;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final scrollPhysics = isIOS
        ? const BouncingScrollPhysics()
        : const NeverScrollableScrollPhysics();

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: scrollPhysics,
        onPageChanged: _onPageChanged,
        children: const [
          DashboardScreen(),
          HistoryScreen(),
          ScanScreen(),
          AnalyticsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _NavItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard,
                    label: Translations.t('nav_dashboard', state.language),
                    isActive: widget.currentScreen == 'dashboard',
                    onTap: () => state.setCurrentScreen('dashboard', replace: true)),
                _NavItem(
                    icon: Icons.history,
                    activeIcon: Icons.history,
                    label: Translations.t('nav_history', state.language),
                    isActive: widget.currentScreen == 'history',
                    onTap: () => state.setCurrentScreen('history', replace: true)),
                _ScanNavItem(
                    label: Translations.t('nav_scan', state.language),
                    isActive: widget.currentScreen == 'scan' || widget.currentScreen == 'ocr',
                    onTap: () => state.setCurrentScreen('scan', replace: true)),
                _NavItem(
                    icon: Icons.bar_chart_outlined,
                    activeIcon: Icons.bar_chart,
                    label: Translations.t('nav_analytics', state.language),
                    isActive: widget.currentScreen == 'analytics',
                    onTap: () => state.setCurrentScreen('analytics', replace: true)),
                _NavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: Translations.t('nav_profile', state.language),
                    isActive: widget.currentScreen == 'profile',
                    onTap: () => state.setCurrentScreen('profile', replace: true)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem(
      {required this.icon,
      required this.activeIcon,
      required this.label,
      required this.isActive,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const activeColor = AppColors.primary;
    final inactiveColor =
        isDark ? AppColors.darkMutedForeground : AppColors.mutedForeground;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? activeIcon : icon,
                color: isActive ? activeColor : inactiveColor, size: 22),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isActive ? activeColor : inactiveColor)),
          ],
        ),
      ),
    );
  }
}

class _ScanNavItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ScanNavItem(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3))
                ],
              ),
              child: const Icon(Icons.document_scanner,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.mutedForeground)),
          ],
        ),
      ),
    );
  }
}
