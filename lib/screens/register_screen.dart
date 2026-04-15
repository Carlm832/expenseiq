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
  bool _isLoading = false;
  Map<String, String> _errors = {};

  bool _validate(AppState state) {
    final errors = <String, String>{};
    final lang = state.language;

    if (_nameCtrl.text.trim().isEmpty) {
      errors['name'] = Translations.t('name_required', lang);
    }
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      errors['email'] = Translations.t('email_required', lang);
    } else if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      errors['email'] = Translations.t('valid_email_required', lang);
    }
    
    if (_passwordCtrl.text.isEmpty) {
      errors['password'] = Translations.t('password_required', lang);
    } else if (_passwordCtrl.text.length < 6) {
      errors['password'] = Translations.t('password_min_length', lang);
    }
    if (_passwordCtrl.text != _confirmCtrl.text) {
      errors['confirmPassword'] = Translations.t('passwords_dont_match', lang);
    }
    final budgetVal = double.tryParse(_budgetCtrl.text.trim()) ?? 0;
    if (budgetVal <= 0) {
      errors['budget'] = Translations.t('set_valid_budget', lang);
    }

    setState(() => _errors = errors);
    return errors.isEmpty;
  }

  Future<void> _handleRegister(AppState state) async {
    if (!_validate(state)) return;

    setState(() => _isLoading = true);
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
      setState(() => _errors = {'form': 'An unexpected error occurred.'});
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = state.language;
    final fgColor = isDark ? AppColors.darkForeground : AppColors.foreground;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [const Color(0xFF0F172A), const Color(0xFF1E293B)] 
              : [const Color(0xFFF8FAFC), const Color(0xFFEEF2FF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => state.setCurrentScreen('login'),
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: fgColor, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildRegisterCard(state, isDark, lang),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterCard(AppState state, bool isDark, String lang) {
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final fgColor = isDark ? AppColors.darkForeground : AppColors.foreground;
    final mutedColor = isDark ? AppColors.darkMutedForeground : AppColors.mutedForeground;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 30, offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Translations.t('reg_create_account', lang),
            style: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.bold, color: fgColor)),
          const SizedBox(height: 8),
          Text(Translations.t('reg_subtitle', lang),
            style: GoogleFonts.inter(fontSize: 14, color: mutedColor)),
          const SizedBox(height: 32),
          
          if (_errors['form'] != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.destructive.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_errors['form']!, style: GoogleFonts.inter(color: AppColors.destructive, fontSize: 13, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 24),
          ],

          _buildTextField(
            label: Translations.t('full_name', lang),
            controller: _nameCtrl,
            hint: 'John Doe',
            icon: Icons.person_outline_rounded,
            error: _errors['name'],
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: Translations.t('email', lang),
            controller: _emailCtrl,
            hint: 'you@example.com',
            icon: Icons.alternate_email_rounded,
            error: _errors['email'],
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: Translations.t('password', lang),
            controller: _passwordCtrl,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            showPassword: _showPassword,
            onToggleVisibility: () => setState(() => _showPassword = !_showPassword),
            error: _errors['password'],
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: Translations.t('reg_confirm_password', lang),
            controller: _confirmCtrl,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            showPassword: _showPassword,
            error: _errors['confirmPassword'],
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: Translations.t('monthly_budget', lang),
            controller: _budgetCtrl,
            hint: 'e.g. 5000',
            icon: Icons.account_balance_wallet_outlined,
            error: _errors['budget'],
            isDark: isDark,
            type: TextInputType.number,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _handleRegister(state),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Text(Translations.t('reg_create_account', lang), style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool? showPassword,
    VoidCallback? onToggleVisibility,
    String? error,
    required bool isDark,
    TextInputType? type,
  }) {
    final fgColor = isDark ? AppColors.darkForeground : AppColors.foreground;
    final mutedColor = isDark ? AppColors.darkMutedForeground : AppColors.mutedForeground;
    final inputBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: fgColor)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword && (showPassword == false),
          keyboardType: type,
          style: GoogleFonts.inter(fontSize: 15, color: fgColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: mutedColor, fontSize: 14),
            prefixIcon: Icon(icon, size: 20, color: mutedColor),
            suffixIcon: isPassword && onToggleVisibility != null ? IconButton(
              icon: Icon(showPassword! ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20, color: mutedColor),
              onPressed: onToggleVisibility,
            ) : null,
            filled: true,
            fillColor: inputBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            errorText: error,
            errorStyle: GoogleFonts.inter(fontSize: 12),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
