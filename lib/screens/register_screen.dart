import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_state.dart';
import '../theme.dart';
import '../services/translations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  bool _showPassword = false;
  Map<String, String> _errors = {};

  bool _validate(AppState state) {
    final errors = <String, String>{};
    if (_nameCtrl.text.trim().isEmpty) {
      errors['name'] = Translations.t('name_required', state.language);
    }
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      errors['email'] = Translations.t('email_required', state.language);
    } else if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      errors['email'] = Translations.t('valid_email_required', state.language);
    } else if (state.isEmailRegistered(email)) {
      errors['email'] = Translations.t('email_registered', state.language);
    }
    if (_passwordCtrl.text.isEmpty) {
      errors['password'] = Translations.t('password_required', state.language);
    } else if (_passwordCtrl.text.length < 6) {
      errors['password'] =
          Translations.t('password_min_length', state.language);
    }
    if (_passwordCtrl.text != _confirmCtrl.text) {
      errors['confirmPassword'] =
          Translations.t('passwords_dont_match', state.language);
    }
    final budgetVal = double.tryParse(_budgetCtrl.text.trim()) ?? 0;
    if (budgetVal <= 0) {
      errors['budget'] = Translations.t('set_valid_budget', state.language);
    }

    setState(() => _errors = errors);
    return errors.isEmpty;
  }

  Future<void> _handleRegister(AppState state) async {
    if (!_validate(state)) return;

    try {
      final budgetVal = double.parse(_budgetCtrl.text.trim());
      await state.registerWithEmail(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      await state.setOverallBudget(budgetVal);
    } on FirebaseAuthException catch (e) {
      String msg = 'Registration failed.';
      if (e.code == 'email-already-in-use') {
        msg = 'This email is already in use.';
      } else if (e.code == 'weak-password') {
        msg = 'The password is too weak.';
      }
      setState(() => _errors = {'form': msg});
    } catch (e) {
      setState(
          () => _errors = {'form': 'An error occurred. Please try again.'});
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
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
            children: [
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () =>
                      context.read<AppState>().setCurrentScreen('login'),
                  icon: Icon(Icons.arrow_back, size: 16, color: mutedColor),
                  label: Text(Translations.t('reg_back_to_signin', lang),
                      style:
                          GoogleFonts.inter(fontSize: 13, color: mutedColor)),
                ),
              ),
              const SizedBox(height: 16),
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
                    Row(children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.person_add,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Translations.t('reg_create_account', lang),
                                style: GoogleFonts.dmSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: fgColor)),
                            Text(Translations.t('reg_subtitle', lang),
                                style: GoogleFonts.inter(
                                    fontSize: 11, color: mutedColor)),
                          ]),
                    ]),
                    const SizedBox(height: 24),
                    _buildField(
                        Translations.t('full_name', lang),
                        _nameCtrl,
                        'John Doe',
                        Icons.person_outline,
                        false,
                        mutedColor,
                        fgColor,
                        _errors['name']),
                    const SizedBox(height: 16),
                    _buildField(
                        Translations.t('email', lang),
                        _emailCtrl,
                        'you@example.com',
                        Icons.mail_outline,
                        false,
                        mutedColor,
                        fgColor,
                        _errors['email'],
                        type: TextInputType.emailAddress),
                    const SizedBox(height: 16),
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
                        hintText: Translations.t('password_min_length', lang),
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
                    const SizedBox(height: 16),
                    Text(Translations.t('reg_confirm_password', lang),
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: fgColor)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _confirmCtrl,
                      obscureText: !_showPassword,
                      style: GoogleFonts.inter(fontSize: 14, color: fgColor),
                      decoration: InputDecoration(
                        hintText: Translations.t('reg_confirm_password', lang),
                        prefixIcon: Icon(Icons.lock_outline,
                            size: 18, color: mutedColor),
                        errorText: _errors['confirmPassword'],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                        Translations.t('monthly_budget', lang),
                        _budgetCtrl,
                        'e.g. 5000',
                        Icons.account_balance_wallet_outlined,
                        false,
                        mutedColor,
                        fgColor,
                        _errors['budget'],
                        type: TextInputType.number),
                    const SizedBox(height: 24),
                    if (_errors['form'] != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(_errors['form']!,
                            style: GoogleFonts.inter(
                                fontSize: 13, color: AppColors.destructive)),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleRegister(state),
                        icon: const Icon(Icons.person_add, size: 18),
                        label: Text(Translations.t('reg_create_account', lang)),
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(Translations.t('reg_already_have_account', lang),
                      style:
                          GoogleFonts.inter(fontSize: 13, color: mutedColor)),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () =>
                        context.read<AppState>().setCurrentScreen('login'),
                    child: Text(Translations.t('login_sign_in', lang),
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

  Widget _buildField(String label, TextEditingController ctrl, String hint,
      IconData icon, bool obscure, Color muted, Color fg, String? error,
      {TextInputType? type}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w500, color: fg)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: type,
        style: GoogleFonts.inter(fontSize: 14, color: fg),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 18, color: muted),
          errorText: error,
        ),
      ),
    ]);
  }
}
