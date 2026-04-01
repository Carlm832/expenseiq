import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app_state.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/pin_screen.dart';
import 'screens/main_scaffold.dart';
import 'screens/add_expense_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/email_verification_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  print('DEBUG: App started (main.dart)');
  WidgetsFlutterBinding.ensureInitialized();
  print('DEBUG: Initializing Firebase...');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('DEBUG: Firebase initialized successfully');
  } catch (e) {
    print('DEBUG: Firebase initialization error: $e');
  }
  await initializeDateFormatting();
  print('DEBUG: Date formatting initialized');

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const ExpenseIQApp(),
    ),
  );
}

/// Maps a language name to its BCP-47 locale tag.
Locale _localeFor(String language) {
  switch (language) {
    case 'Arabic':
      return const Locale('ar');
    case 'French':
      return const Locale('fr');
    case 'Korean':
      return const Locale('ko');
    case 'Russian':
      return const Locale('ru');
    case 'Turkish':
      return const Locale('tr');
    default:
      return const Locale('en');
  }
}

class ExpenseIQApp extends StatelessWidget {
  const ExpenseIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final locale = _localeFor(state.language);
    final isRtl = state.language == 'Arabic';

    return MaterialApp(
      title: 'ExpenseIQ',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
        Locale('ar'),
        Locale('fr'),
        Locale('ko'),
        Locale('ru'),
      ],
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Directionality(
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: child!,
          ),
        );
      },
      home: const AppRouter(),
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final screen = state.currentScreen;

    // Show the animated splash screen while Firebase auth is resolving
    if (state.isInitializing) return const SplashScreen();

    // If user has a PIN set and the app just launched, show PIN entry
    if (state.isLoggedIn && state.isPinLocked) return const PinEntryScreen();

    if (!state.isLoggedIn) {
      if (screen == 'register') return const RegisterScreen();
      if (screen == 'forgot_password') return const ForgotPasswordScreen();
      return const LoginScreen();
    }

    if (screen == 'email_verification') return const EmailVerificationScreen();

    Widget child;
    switch (screen) {
      case 'addExpense':
        child = const AddExpenseScreen();
      case 'notifications':
        child = const NotificationsScreen();
      case 'settings':
        child = const SettingsScreen();
      case 'appearance':
        child = const AppearanceScreen();
      case 'budget':
        child = const BudgetScreen();
      case 'help':
        child = const HelpScreen();
      case 'contact_us':
        child = const ContactUsScreen();
      case 'privacy':
        child = const PrivacyScreen();
      case 'edit_profile':
        child = const EditProfileScreen();
      case 'setup_pin':
        child = const PinSetupScreen();
      case 'setup_2fa':
        child = const TwoFactorSetupScreen();
      default:
        child = MainScaffold(currentScreen: screen);
    }

    return child;
  }
}
