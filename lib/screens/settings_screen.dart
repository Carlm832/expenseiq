import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_state.dart';
import '../theme.dart';
import '../services/translations.dart';
import '../services/bio_service.dart';

Widget _buildSimpleScreen(BuildContext context, String title, String subtitle,
    List<Widget> children) {
  final state = context.read<AppState>();
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
  final fgColor = isDark ? AppColors.darkForeground : AppColors.foreground;
  final mutedColor =
      isDark ? AppColors.darkMutedForeground : AppColors.mutedForeground;
  final cardColor = isDark ? AppColors.darkCard : AppColors.card;
  final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

  return Scaffold(
    backgroundColor: bgColor,
    body: SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
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
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: GoogleFonts.dmSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: fgColor)),
              if (subtitle.isNotEmpty)
                Text(subtitle,
                    style: GoogleFonts.inter(fontSize: 12, color: mutedColor)),
            ]),
          ]),
        ),
        Expanded(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: children),
        )),
      ]),
    ),
  );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor = isDark ? AppColors.darkForeground : AppColors.foreground;
    final mutedColor =
        isDark ? AppColors.darkMutedForeground : AppColors.mutedForeground;
    final cardColor = isDark ? AppColors.darkCard : AppColors.card;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return _buildSimpleScreen(
        context,
        Translations.t('settings_title', state.language),
        Translations.t('settings_subtitle', state.language), [
      Container(
        decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor)),
        child: Column(children: [
          _SettingsTile(
              icon: Icons.language,
              label: Translations.t('language', state.language),
              value: state.language,
              fgColor: fgColor,
              mutedColor: mutedColor,
              borderColor: borderColor,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title:
                        Text(Translations.t('select_language', state.language)),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ('English', 'English'),
                          ('Turkish', 'Türkçe'),
                          ('Arabic', 'العربية'),
                          ('French', 'Français'),
                          ('Korean', '한국어'),
                          ('Russian', 'Русский'),
                        ]
                            .map((entry) => ListTile(
                                  title: Text(entry.$1),
                                  subtitle: entry.$1 != entry.$2
                                      ? Text(entry.$2,
                                          style: TextStyle(
                                              color: mutedColor, fontSize: 12))
                                      : null,
                                  selected: state.language == entry.$1,
                                  onTap: () {
                                    state.setLanguage(entry.$1);
                                    Navigator.pop(ctx);
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                );
              }),
          _SettingsTile(
              icon: Icons.currency_exchange,
              label: Translations.t('currency', state.language),
              value: state.currency,
              fgColor: fgColor,
              mutedColor: mutedColor,
              borderColor: borderColor,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title:
                        Text(Translations.t('select_currency', state.language)),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: ['TRY (₺)', 'USD (\$)', 'EUR (€)', 'GBP (£)', 'JPY (¥)', 'AUD (\$)', 'CAD (\$)', 'CHF (Fr)', 'CNY (¥)']
                            .map((curr) => ListTile(
                                  title: Text(curr),
                                  selected: state.currency == curr,
                                  onTap: () {
                                    state.setCurrency(curr);
                                    Navigator.pop(ctx);
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                );
              }),
          _SettingsTile(
              icon: Icons.refresh,
              label: Translations.t('refresh_rates', state.language),
              value: '',
              fgColor: fgColor,
              mutedColor: mutedColor,
              borderColor: borderColor,
              onTap: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(Translations.t('updating_rates', state.language))),
                );
                await state.refreshRates();
              }),
          _SettingsTile(
              icon: Icons.notifications_outlined,
              label: Translations.t('push_notifications', state.language),
              value: state.pushNotificationsEnabled
                  ? Translations.t('on', state.language)
                  : Translations.t('off', state.language),
              fgColor: fgColor,
              mutedColor: mutedColor,
              borderColor: borderColor,
              onTap: () {
                state.setPushNotificationsEnabled(
                    !state.pushNotificationsEnabled);
              }),
          _SettingsTile(
              icon: Icons.backup_outlined,
              label: Translations.t('backup_data', state.language),
              value: '',
              fgColor: fgColor,
              mutedColor: mutedColor,
              borderColor: borderColor,
              onTap: () => state.backupData()),
          _SettingsTile(
              icon: Icons.delete_outline,
              label: Translations.t('clear_all_data', state.language),
              value: '',
              fgColor: fgColor,
              mutedColor: mutedColor,
              borderColor: borderColor,
              isDestructive: true,
              onTap: () {
                final user = FirebaseAuth.instance.currentUser;
                final isPasswordUser = user != null && user.providerData.any((p) => p.providerId == 'password');
                final passwordCtrl = TextEditingController();

                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(Translations.t(
                        'clear_data_confirm_title', state.language)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Translations.t(
                            'clear_data_confirm_msg', state.language)),
                        if (isPasswordUser) ...[
                          const SizedBox(height: 16),
                          Text('Enter Password to Confirm:', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: fgColor)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: passwordCtrl,
                            obscureText: true,
                            decoration: const InputDecoration(hintText: 'Your password'),
                          ),
                        ],
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(Translations.t('cancel', state.language)),
                      ),
                      TextButton(
                        onPressed: () async {
                          try {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(Translations.t('deleting_data', state.language))),
                            );
                            
                            await state.clearAllData(password: isPasswordUser ? passwordCtrl.text : null);
                            
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                            }
                          } on FirebaseAuthException catch (e) {
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Authentication Error: ${e.message}')),
                              );
                            }
                          } catch (e) {
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}')),
                              );
                            }
                          }
                        },
                        child: Text(Translations.t('delete', state.language),
                            style:
                                const TextStyle(color: AppColors.destructive)),
                      ),
                    ],
                  ),
                );
              }),
        ]),
      ),
    ]);
  }
}

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor = isDark ? AppColors.darkForeground : AppColors.foreground;
    final mutedColor =
        isDark ? AppColors.darkMutedForeground : AppColors.mutedForeground;
    final cardColor = isDark ? AppColors.darkCard : AppColors.card;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    return _buildSimpleScreen(
        context,
        Translations.t('appearance_title', state.language),
        Translations.t('dark_mode_subtitle', state.language), [
      Container(
        decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor)),
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(Translations.t('dark_mode', state.language),
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: fgColor)),
                Text(Translations.t('dark_mode_subtitle', state.language),
                    style: GoogleFonts.inter(fontSize: 12, color: mutedColor)),
              ])),
          Switch(
              value: state.isDarkMode,
              onChanged: (_) => state.toggleDarkMode(),
              activeColor: AppColors.primary),
        ]),
      ),
    ]);
  }
}

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});
  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    final overallBudget = state.getConvertedOverallBudget();
    _ctrl.text =
        overallBudget > 0 ? overallBudget.toStringAsFixed(0) : '';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor = isDark ? AppColors.darkForeground : AppColors.foreground;
    final cardColor = isDark ? AppColors.darkCard : AppColors.card;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final lang = state.language;

    return _buildSimpleScreen(
        context,
        Translations.t('budget_manager_title', state.language),
        Translations.t('set_monthly_limit', state.language), [
      Container(
        decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor)),
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Expanded(
              child: Text(Translations.t('monthly_budget', state.language),
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: fgColor))),
          SizedBox(
            width: 120,
            child: TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: context.read<AppState>().currencySymbol,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              onSubmitted: (v) => state
                  .setOverallBudget(double.tryParse(v) ?? state.overallBudget),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 24),
      
      // Warning Thresholds
      Row(children: [
        Expanded(child: Text(Translations.t('warning_thresholds', lang),
          style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700, color: fgColor))),
        IconButton(
          onPressed: () => _showAddThresholdDialog(context),
          icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
        ),
      ]),
      const SizedBox(height: 12),
      
      if (state.budgetWarningIntervals.isEmpty)
        Center(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(Translations.t('no_data', lang), 
            style: GoogleFonts.inter(color: fgColor.withOpacity(0.5))),
        ))
      else
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: state.budgetWarningIntervals.map((t) => Chip(
            label: Text('$t%'),
            backgroundColor: AppColors.primary.withOpacity(0.1),
            labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
            onDeleted: () {
               final newList = List<int>.from(state.budgetWarningIntervals)..remove(t);
               state.setBudgetWarningIntervals(newList);
            },
            deleteIconColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            side: BorderSide.none,
          )).toList(),
        ),

      const SizedBox(height: 32),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            final limit = double.tryParse(_ctrl.text) ?? 0;
            state.setOverallBudget(limit);
            state.goBack();
          },
          child: Text(Translations.t('save_budget', state.language)),
        ),
      ),
    ]);
  }

  void _showAddThresholdDialog(BuildContext context) {
    final state = context.read<AppState>();
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(Translations.t('add_threshold', state.language)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: Translations.t('enter_threshold_hint', state.language),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(Translations.t('cancel', state.language))),
          TextButton(
            onPressed: () {
              final val = int.tryParse(ctrl.text);
              if (val != null && val > 0 && val <= 100) {
                if (!state.budgetWarningIntervals.contains(val)) {
                  final newList = [...state.budgetWarningIntervals, val];
                  state.setBudgetWarningIntervals(newList);
                  Navigator.pop(ctx);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(Translations.t('threshold_already_exists', state.language)))
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(Translations.t('invalid_threshold', state.language)))
                );
              }
            },
            child: Text(Translations.t('save', state.language)),
          ),
        ],
      ),
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor = isDark ? AppColors.darkForeground : AppColors.foreground;
    final mutedColor =
        isDark ? AppColors.darkMutedForeground : AppColors.mutedForeground;
    final cardColor = isDark ? AppColors.darkCard : AppColors.card;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final state = context.read<AppState>();
    final lang = state.language;

    final faqs = [
      ('How do I capture a receipt?', 'Tap the floating "+" button on the dashboard and select the camera or gallery icon.'),
      ('Can I export my data?', 'Yes! Go to the Analytics screen and use the Export PDF or Export CSV buttons at the top.'),
      ('How does currency conversion work?', 'ExpenseIQ fetches real-time rates. You can change your display currency in Settings.'),
      ('Is my data stored online?', 'Your data is saved locally and synced to your secure Firebase account if you are signed in.'),
    ];

    return _buildSimpleScreen(
        context,
        Translations.t('help_support_title', lang),
        Translations.t('get_assistance', lang), [
      ...faqs.map((faq) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor)),
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(faq.$1,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: fgColor)),
                    const SizedBox(height: 6),
                    Text(faq.$2,
                        style:
                            GoogleFonts.inter(fontSize: 12, color: mutedColor)),
                  ]),
            ),
          )),
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            context.read<AppState>().setCurrentScreen('contact_us');
          },
          icon: const Icon(Icons.support_agent, size: 18),
          label: Text(Translations.t('contact_us', lang)),
        ),
      ),
    ]);
  }
}

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _isSending = false;
  String? _selectedSuggestion;

  final List<(String, String)> _suggestions = [
    ('How to add an expense?', 'Tap the floating "+" button on the dashboard to quickly add any expense.'),
    ('Currency update frequency?', 'Exchange rates are updated every 24 hours automatically.'),
    ('Exporting reports?', 'You can export PDF/CSV from the top of the Analytics screen.'),
    ('Changing language?', 'Go to Profile -> Settings -> Language to switch between English and Turkish.'),
  ];

  Future<void> _sendMessage() async {
    if (_subjectCtrl.text.trim().isEmpty || _messageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(Translations.t(
                'fill_all_fields', context.read<AppState>().language))),
      );
      return;
    }

    setState(() => _isSending = true);

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isSending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(Translations.t(
              'message_sent_success', context.read<AppState>().language))),
    );

    context.read<AppState>().goBack();
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor = isDark ? AppColors.darkForeground : AppColors.foreground;
    final cardColor = isDark ? AppColors.darkCard : AppColors.card;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    final lang = context.read<AppState>().language;
    return _buildSimpleScreen(context, Translations.t('contact_us_title', lang),
        Translations.t('send_message_subtitle', lang), [
      Text('Suggested Solutions', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: fgColor)),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _suggestions.map((s) => ChoiceChip(
          label: Text(s.$1, style: GoogleFonts.inter(fontSize: 11)),
          selected: _selectedSuggestion == s.$1,
          onSelected: (selected) {
            setState(() {
              _selectedSuggestion = selected ? s.$1 : null;
              if (selected) {
                _subjectCtrl.text = s.$1;
              }
            });
          },
          selectedColor: AppColors.primary.withOpacity(0.1),
          checkmarkColor: AppColors.primary,
        )).toList(),
      ),
      if (_selectedSuggestion != null) ...[
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Instant Solution:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary)),
              const SizedBox(height: 4),
              Text(_suggestions.firstWhere((s) => s.$1 == _selectedSuggestion).$2,
                  style: GoogleFonts.inter(fontSize: 12, color: fgColor)),
            ],
          ),
        ),
      ],
      const SizedBox(height: 24),
      Container(
        decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor)),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(Translations.t('subject', lang),
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w500, color: fgColor)),
          const SizedBox(height: 6),
          TextField(
            controller: _subjectCtrl,
            decoration: InputDecoration(
                hintText: Translations.t('regarding_hint', lang)),
          ),
          const SizedBox(height: 16),
          Text(Translations.t('message', lang),
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w500, color: fgColor)),
          const SizedBox(height: 6),
          TextField(
            controller: _messageCtrl,
            maxLines: 5,
            decoration: InputDecoration(
                hintText: Translations.t('describe_issue_hint', lang)),
          ),
        ]),
      ),
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSending ? null : _sendMessage,
          child: _isSending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(Translations.t('send_message', lang)),
        ),
      ),
    ]);
  }
}

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _isPasswordUser = false;

  @override
  void initState() {
    super.initState();
    _checkPasswordUser();
  }

  void _checkPasswordUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _isPasswordUser = user.providerData.any((p) => p.providerId == 'password');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor = isDark ? AppColors.darkForeground : AppColors.foreground;
    final mutedColor =
        isDark ? AppColors.darkMutedForeground : AppColors.mutedForeground;
    final cardColor = isDark ? AppColors.darkCard : AppColors.card;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final lang = state.language;
    return _buildSimpleScreen(context, Translations.t('privacy_title', lang),
        Translations.t('data_protection', lang), [
      Container(
        decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor)),
        child: Column(children: [
          _SettingsTile(
              icon: Icons.fingerprint,
              label: 'Biometric Security',
              value: state.isBiometricEnabled ? 'Enabled' : 'Disabled',
              fgColor: fgColor,
              mutedColor: mutedColor,
              borderColor: borderColor,
              onTap: () async {
                final success = await BioService().authenticate();
                if (success) {
                  state.setBiometricEnabled(!state.isBiometricEnabled);
                }
              }),
          _SettingsTile(
              icon: Icons.pin_outlined,
              label: 'App PIN',
              value: state.hasPin ? 'Enabled' : 'Disabled',
              fgColor: fgColor,
              mutedColor: mutedColor,
              borderColor: borderColor,
              onTap: () {
                if (state.hasPin) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Manage PIN'),
                      content: const Text(
                          'What would you like to do with your PIN?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            state.setCurrentScreen('setup_pin');
                          },
                          child: const Text('Change PIN'),
                        ),
                        TextButton(
                          onPressed: () {
                            state.clearPin();
                            Navigator.pop(ctx);
                          },
                          child: const Text('Remove PIN',
                              style: TextStyle(
                                  color: AppColors.destructive)),
                        ),
                      ],
                    ),
                  );
                } else {
                  state.setCurrentScreen('setup_pin');
                }
              }),
          _SettingsTile(
              icon: Icons.lock_outline,
              label: 'Two-Factor Authentication (2FA)',
              value: 'Coming Soon',
              fgColor: fgColor,
              mutedColor: mutedColor,
              borderColor: borderColor,
              onTap: () {
                state.setCurrentScreen('setup_2fa');
              }),
          _SettingsTile(
              icon: Icons.vpn_key_outlined,
              label: _isPasswordUser ? 'Account Password' : 'Set Account Password',
              value: _isPasswordUser ? 'Enabled' : 'Not Set',
              fgColor: fgColor,
              mutedColor: mutedColor,
              borderColor: borderColor,
              onTap: () {
                if (_isPasswordUser) {
                  state.setCurrentScreen('edit_profile');
                } else {
                  final passwordCtrl = TextEditingController();
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Set Password'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                              'Setting a password allows you to log in with your email directly.'),
                          const SizedBox(height: 16),
                          TextField(
                            controller: passwordCtrl,
                            obscureText: true,
                            decoration:
                                const InputDecoration(hintText: 'New password'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            try {
                              if (passwordCtrl.text.isEmpty) return;
                              await state.linkPassword(passwordCtrl.text);
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Password securely linked!')),
                                );
                                _checkPasswordUser();
                              }
                            } catch (e) {
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Error: ${e.toString().replaceAll("Exception: ", "")}')),
                                );
                              }
                            }
                          },
                          child: const Text('Set Password'),
                        ),
                      ],
                    ),
                  );
                }
              }),
        ]),
      ),
      const SizedBox(height: 24),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          Translations.t('privacy_policy_text', lang),
          style: GoogleFonts.inter(fontSize: 13, color: mutedColor, height: 1.6),
        ),
      ),
    ]);
  }
}

// PaymentMethodsScreen removed as per user request

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  final TextEditingController _currentPasswordCtrl = TextEditingController();
  final TextEditingController _newPasswordCtrl = TextEditingController();
  bool _isSaving = false;
  bool _isPasswordUser = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _nameCtrl = TextEditingController(text: state.userName);
    _emailCtrl = TextEditingController(text: state.userEmail);
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _isPasswordUser = user.providerData.any((p) => p.providerId == 'password');
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor = isDark ? AppColors.darkForeground : AppColors.foreground;
    final cardColor = isDark ? AppColors.darkCard : AppColors.card;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final lang = state.language;
    return _buildSimpleScreen(
        context,
        Translations.t('edit_profile_title', lang),
        Translations.t('update_info_subtitle', lang), [
      Container(
        decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor)),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(Translations.t('full_name', lang),
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w500, color: fgColor)),
          const SizedBox(height: 6),
          TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(hintText: 'John Doe')),
          const SizedBox(height: 16),
          Text(Translations.t('email', lang),
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w500, color: fgColor)),
          const SizedBox(height: 6),
          TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'you@example.com')),
          
          if (_isPasswordUser) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text('Change Password', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: fgColor)),
            const SizedBox(height: 16),
            Text('Current Password',
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w500, color: fgColor)),
            const SizedBox(height: 6),
            TextField(
                controller: _currentPasswordCtrl,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Current password')),
            const SizedBox(height: 16),
            Text('New Password',
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w500, color: fgColor)),
            const SizedBox(height: 6),
            TextField(
                controller: _newPasswordCtrl,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'New password')),
          ],
        ]),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSaving ? null : () async {
            setState(() => _isSaving = true);
            try {
              if (_isPasswordUser && _currentPasswordCtrl.text.isNotEmpty && _newPasswordCtrl.text.isNotEmpty) {
                await state.updatePassword(_currentPasswordCtrl.text, _newPasswordCtrl.text);
              }
              
              if (_nameCtrl.text != state.userName) {
                await state.setUserName(_nameCtrl.text.trim());
              }
              if (_emailCtrl.text != state.userEmail) {
                await state.setUserEmail(_emailCtrl.text.trim());
              }
              if (!mounted) return;
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully!')),
              );
              state.goBack();
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}')),
                );
              }
            } finally {
              if (context.mounted) setState(() => _isSaving = false);
            }
          },
          child: _isSaving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(Translations.t('save_changes', lang)),
        ),
      ),
    ]);
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color fgColor;
  final Color mutedColor;
  final Color borderColor;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.fgColor,
    required this.mutedColor,
    required this.borderColor,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Icon(icon,
                size: 18,
                color: isDestructive ? AppColors.destructive : mutedColor),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color:
                            isDestructive ? AppColors.destructive : fgColor))),
            if (value.isNotEmpty)
              Text(value,
                  style: GoogleFonts.inter(fontSize: 12, color: mutedColor)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 16, color: mutedColor),
          ]),
        ),
        Divider(height: 1, color: borderColor, indent: 16),
      ]),
    );
  }
}

class TwoFactorSetupScreen extends StatefulWidget {
  const TwoFactorSetupScreen({super.key});

  @override
  State<TwoFactorSetupScreen> createState() => _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends State<TwoFactorSetupScreen> {
  bool _isSuccess = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor = isDark ? AppColors.darkForeground : AppColors.foreground;
    final mutedColor =
        isDark ? AppColors.darkMutedForeground : AppColors.mutedForeground;
    final cardColor = isDark ? AppColors.darkCard : AppColors.card;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    if (_isSuccess) {
      return _buildSimpleScreen(context, '2FA Enabled', '', [
        const Center(
          child: Icon(Icons.check_circle_outline,
              size: 80, color: AppColors.secondary),
        ),
        const SizedBox(height: 24),
        Text(
          'Two-Factor Authentication is now active.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.w600, color: fgColor),
        ),
        const SizedBox(height: 12),
        Text(
          'Your account is now more secure. You will be asked for a verification code when signing in from new devices.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 13, color: mutedColor),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => state.goBack(),
            child: const Text('Back to Security'),
          ),
        ),
      ]);
    }

    return _buildSimpleScreen(context, 'Set up 2FA',
        'Secure your account with an Authenticator app', [
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(children: [
          const Icon(Icons.phonelink_lock, size: 48, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Step 1: Install an Authenticator App',
            style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.bold, color: fgColor),
          ),
          const SizedBox(height: 8),
          Text(
            'Download Google Authenticator or Authy from the App Store or Play Store.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 12, color: mutedColor),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          Text(
            'Step 2: Scan this QR Code',
            style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.bold, color: fgColor),
          ),
          const SizedBox(height: 16),
          // QR Code Placeholder
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Center(
              child: Icon(Icons.qr_code_2, size: 120, color: Colors.black),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Secret: JBSWY3DPEHPK3PXP', // Mock secret
            style: GoogleFonts.jetBrainsMono(
                fontSize: 12, fontWeight: FontWeight.bold, color: mutedColor),
          ),
          const SizedBox(height: 24),
          Text(
            'Once scanned, enter the 6-digit code from your app below to verify.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 11, color: mutedColor),
          ),
        ]),
      ),
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            await state.set2faEnabled(true);
            setState(() => _isSuccess = true);
          },
          child: const Text('Verify & Enable 2FA'),
        ),
      ),
    ]);
  }
}
