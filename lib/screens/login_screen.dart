import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_state.dart';
import '../theme.dart';
import '../services/translations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;
  Map<String, String> _errors = {};

  bool _validate() {
    final errors = <String, String>{};
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final lang = context.read<AppState>().language;

    if (email.isEmpty) {
      errors['email'] = Translations.t('email_required', lang);
    } else if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      errors['email'] = Translations.t('valid_email_required', lang);
    }
    if (password.isEmpty) {
      errors['password'] = Translations.t('password_required', lang);
    } else if (password.length < 6) {
      errors['password'] = Translations.t('password_min_length', lang);
    }
    setState(() => _errors = errors);
    return errors.isEmpty;
  }

  Future<void> _handleLogin(AppState state) async {
    if (!_validate()) return;
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    setState(() => _isLoading = true);
    try {
      await state.loginWithEmail(email, password);
    } on FirebaseAuthException catch (e) {
      String msg = 'Login failed.';
      if (e.code == 'user-not-found') {
        msg = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        msg = 'Incorrect password.';
      } else if (e.code == 'invalid-credential') {
        msg = 'Invalid credentials.';
      }
      setState(() => _errors = {'form': msg});
    } catch (e) {
      setState(
          () => _errors = {'form': 'An error occurred. Please try again.'});
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final cardColor = isDark ? AppColors.darkCard : AppColors.card;
    final fgColor = isDark ? AppColors.darkForeground : AppColors.foreground;
    final mutedColor =
        isDark ? AppColors.darkMutedForeground : AppColors.mutedForeground;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    final lang = state.language;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.topRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => state.setLanguage('English'),
                      child: Text('English',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: state.language == 'English'
                                  ? FontWeight.bold
                                  : FontWeight.w400,
                              color: state.language == 'English'
                                  ? AppColors.primary
                                  : mutedColor)),
                    ),
                    Text(' | ', style: TextStyle(color: mutedColor)),
                    GestureDetector(
                      onTap: () => state.setLanguage('Turkish'),
                      child: Text('Turkish',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: state.language == 'Turkish'
                                  ? FontWeight.bold
                                  : FontWeight.w400,
                              color: state.language == 'Turkish'
                                  ? AppColors.primary
                                  : mutedColor)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ExpenseIQ',
                          style: GoogleFonts.dmSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: fgColor)),
                      Text(Translations.t('smart_finance_tracking', lang),
                          style: GoogleFonts.inter(
                              fontSize: 12, color: mutedColor)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Feature pills
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _FeaturePill(
                      icon: Icons.document_scanner,
                      label: Translations.t('scan_receipts', lang),
                      color: AppColors.primary),
                  _FeaturePill(
                      icon: Icons.bar_chart,
                      label: Translations.t('track_spending', lang),
                      color: AppColors.secondary),
                  _FeaturePill(
                      icon: Icons.savings,
                      label: Translations.t('save_more', lang),
                      color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 32),
              // Login card
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Translations.t('login_welcome_back', lang),
                        style: GoogleFonts.dmSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: fgColor)),
                    const SizedBox(height: 4),
                    Text(Translations.t('login_subtitle', lang),
                        style:
                            GoogleFonts.inter(fontSize: 13, color: mutedColor)),
                    const SizedBox(height: 24),
                    if (_errors['form'] != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.destructive.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(_errors['form']!,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.destructive,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center),
                      ),
                    // Email
                    Text(Translations.t('email', lang),
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: fgColor)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.inter(fontSize: 14, color: fgColor),
                      decoration: InputDecoration(
                        hintText: 'you@example.com',
                        prefixIcon: Icon(Icons.mail_outline,
                            size: 18, color: mutedColor),
                        errorText: _errors['email'],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Password
                    Text(Translations.t('password', lang),
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: fgColor)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: !_showPassword,
                      style: GoogleFonts.inter(fontSize: 14, color: fgColor),
                      decoration: InputDecoration(
                        hintText: Translations.t('enter_details_manual', lang),
                        prefixIcon: Icon(Icons.lock_outline,
                            size: 18, color: mutedColor),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 18,
                              color: mutedColor),
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),
                        errorText: _errors['password'],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => state.setCurrentScreen('forgot_password'),
                        child: Text(
                            Translations.t('login_forgot_password', lang),
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _handleLogin(state),
                        icon: _isLoading 
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.login, size: 18),
                        label: Text(_isLoading ? 'Signing In...' : Translations.t('login_sign_in', lang)),
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => state.setCurrentScreen('register'),
                        icon: const Icon(Icons.person_add_outlined, size: 18),
                        label: Text(Translations.t('reg_create_account', lang),
                            style: TextStyle(color: fgColor)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: borderColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: Divider(color: borderColor)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('OR',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: mutedColor,
                                  fontWeight: FontWeight.w600)),
                        ),
                        Expanded(child: Divider(color: borderColor)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            await state.signInWithGoogle();
                          } catch (e) {
                            setState(() =>
                                _errors = {'form': 'Google Sign-In failed.'});
                          }
                        },
                        icon: ClipOval(
                          child: Image.asset('assets/google_logo.png',
                              width: 20, height: 20, fit: BoxFit.cover),
                        ),
                        label: Text('Sign in with Google',
                            style: TextStyle(color: fgColor)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: borderColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(Translations.t('login_no_account', lang),
                      style:
                          GoogleFonts.inter(fontSize: 13, color: mutedColor)),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => state.setCurrentScreen('register'),
                    child: Text(Translations.t('login_signup_free', lang),
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _FeaturePill(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w500, color: color)),
      ]),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  String? _error;
  bool _isSending = false;
  bool _isSent = false;

  Future<void> _handleReset(AppState state) async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      setState(() => _error = Translations.t('valid_email_required', state.language));
      return;
    }

    setState(() {
      _error = null;
      _isSending = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() {
        _isSending = false;
        _isSent = true;
      });
    } catch (e) {
      setState(() {
        _isSending = false;
        _error = 'Failed to send reset email. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final cardColor = isDark ? AppColors.darkCard : AppColors.card;
    final fgColor = isDark ? AppColors.darkForeground : AppColors.foreground;
    final mutedColor = isDark ? AppColors.darkMutedForeground : AppColors.mutedForeground;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final lang = state.language;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 48),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => state.goBack(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor)),
                      child: Icon(Icons.arrow_back, size: 18, color: fgColor),
                    ),
                  ),
                ]),
              ),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.all(24),
                child: _isSent
                    ? Column(
                        children: [
                          const Icon(Icons.mark_email_read, size: 48, color: AppColors.primary),
                          const SizedBox(height: 16),
                          Text(
                            'Check your email',
                            style: GoogleFonts.dmSans(
                                fontSize: 20, fontWeight: FontWeight.w600, color: fgColor),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We have sent password recovery instructions to your email.',
                            style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => state.setCurrentScreen('login'),
                              child: const Text('Return to Login'),
                            ),
                          ),
                        ],
                      )
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reset Password',
                        style: GoogleFonts.dmSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: fgColor)),
                    const SizedBox(height: 4),
                    Text('Enter your email to receive a password reset link.',
                        style:
                            GoogleFonts.inter(fontSize: 13, color: mutedColor)),
                    const SizedBox(height: 24),
                    if (_error != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.destructive.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(_error!,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.destructive,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center),
                      ),
                    Text(Translations.t('email', lang),
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: fgColor)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.inter(fontSize: 14, color: fgColor),
                      decoration: InputDecoration(
                        hintText: 'you@example.com',
                        prefixIcon: Icon(Icons.mail_outline,
                            size: 18, color: mutedColor),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSending ? null : () => _handleReset(state),
                        icon: _isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send, size: 18),
                        label: Text(_isSending ? 'Sending...' : 'Send Reset Link'),
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
