import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  // Auth
  bool _isLoggedIn = false;
  String _userName = '';
  String _userEmail = '';
  String _profileImage = '';

  // Navigation stack
  List<String> _screenHistory = ['login'];

  // Expenses
  List<Expense> _expenses = List.from(kDefaultExpenses);

  // Notifications
  List<AppNotification> _notifications = List.from(kDefaultNotifications);

  // Budgets
  List<Budget> _budgets = List.from(kDefaultBudgets);

  // Theme
  bool _isDarkMode = false;

  // Expense detail
  Expense? _selectedExpense;
  bool _showExpenseDetail = false;

  // Settings & Localization
  String _language = 'English';
  String _currency = 'TRY (₺)';
  bool _pushNotificationsEnabled = true;

  // OCR args
  Map<String, dynamic>? _screenArgs;

  // Overall Budget
  double _overallBudget = 2500.0;
  bool _hasSeenBudgetWarningThisMonth = false;

  // Syncing logic for Dashboard month selection (added by collaborator)
  String _selectedMonth = DateTime.now().toString().substring(0, 7);

  // Firestore DB
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get profileImage => _profileImage;
  String get currentScreen => _screenHistory.last;
  List<Expense> get expenses => _expenses;
  List<AppNotification> get notifications => _notifications;
  List<Budget> get budgets => _budgets;
  bool get isDarkMode => _isDarkMode;
  Expense? get selectedExpense => _selectedExpense;
  bool get showExpenseDetail => _showExpenseDetail;
  int get unreadCount => _notifications.where((n) => !n.read).length;
  bool get hasSeenBudgetWarningThisMonth => _hasSeenBudgetWarningThisMonth;
  String get selectedMonth => _selectedMonth;

  String get language => _language;
  String get currency => _currency;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  Map<String, dynamic>? get screenArgs => _screenArgs;
  double get overallBudget => _overallBudget;
  String get currencySymbol =>
      _currency.contains('(') ? _currency.split('(')[1].split(')')[0] : '₺';

  AppState() {
    _loadFromPrefs();
    _initAuthListener();
  }

  void _initAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _isLoggedIn = true;
        _userName = user.displayName ?? '';
        _userEmail = user.email ?? '';
        _profileImage = user.photoURL ?? '';

        _syncDataFromFirestore(user.uid);

        if (_screenHistory.last == 'login' ||
            _screenHistory.last == 'register') {
          _screenHistory = ['dashboard'];
        }
      } else {
        _isLoggedIn = false;
        _userName = '';
        _userEmail = '';
        _profileImage = '';
        _expenses = [];
        _budgets = [];
        if (_screenHistory.last != 'login' &&
            _screenHistory.last != 'register') {
          _screenHistory = ['login'];
        }
      }
      notifyListeners();
    });
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _userName = prefs.getString('userName') ?? '';
    _userEmail = prefs.getString('userEmail') ?? '';
    _profileImage = prefs.getString('profileImage') ?? '';
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _language = prefs.getString('language') ?? 'English';
    _currency = prefs.getString('currency') ?? 'TRY (₺)';
    _pushNotificationsEnabled =
        prefs.getBool('pushNotificationsEnabled') ?? true;
    _overallBudget = prefs.getDouble('overallBudget') ?? 2500.0;
    _hasSeenBudgetWarningThisMonth =
        prefs.getBool('hasSeenBudgetWarningThisMonth') ?? false;
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'expenses', jsonEncode(_expenses.map((e) => e.toJson()).toList()));

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'expenses': _expenses.map((e) => e.toJson()).toList(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> _saveBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'budgets', jsonEncode(_budgets.map((b) => b.toJson()).toList()));

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).set({
        'budgets': _budgets.map((b) => b.toJson()).toList(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> _syncDataFromFirestore(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('expenses')) {
          final List<dynamic> exps = data['expenses'];
          _expenses = exps.map((e) => Expense.fromJson(e)).toList();
        }
        if (data.containsKey('budgets')) {
          final List<dynamic> bdgs = data['budgets'];
          _budgets = bdgs.map((b) => Budget.fromJson(b)).toList();
        }
        notifyListeners();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error syncing from Firestore: $e');
    }
  }

  void setCurrentScreen(String screen) {
    _screenHistory = [..._screenHistory, screen];
    notifyListeners();
  }

  void goBack() {
    if (_screenHistory.length > 1) {
      _screenHistory = _screenHistory.sublist(0, _screenHistory.length - 1);
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User canceled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      // ignore: avoid_print
      print('Google sign in error: $e');
      rethrow;
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      // ignore: avoid_print
      print('Login error: $e');
      rethrow;
    }
  }

  Future<void> registerWithEmail(
      String name, String email, String password) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        // Refresh state
        _userName = name;
        notifyListeners();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Registration error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      // ignore: avoid_print
      print('Logout error: $e');
    }
    _isLoggedIn = false;
    _screenHistory = ['login'];
    SharedPreferences.getInstance().then((p) => p.setBool('isLoggedIn', false));
    notifyListeners();
  }


  void setUserName(String name) {
    _userName = name;
    notifyListeners();
    SharedPreferences.getInstance().then((p) => p.setString('userName', name));
  }

  void setUserEmail(String email) {
    _userEmail = email;
    notifyListeners();
    SharedPreferences.getInstance()
        .then((p) => p.setString('userEmail', email));
  }

  void setProfileImage(String img) {
    _profileImage = img;
    notifyListeners();
    SharedPreferences.getInstance()
        .then((p) => p.setString('profileImage', img));

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _db
          .collection('users')
          .doc(user.uid)
          .set({'profileImage': img}, SetOptions(merge: true));
    }
  }

  void addExpense(Expense expense) {
    _expenses = [expense, ..._expenses];
    _saveExpenses();
    notifyListeners();
  }

  void editExpense(String id, Expense updated) {
    _expenses = _expenses.map((e) => e.id == id ? updated : e).toList();
    _saveExpenses();
    notifyListeners();
  }

  void deleteExpense(String id) {
    _expenses = _expenses.where((e) => e.id != id).toList();
    _saveExpenses();
    notifyListeners();
  }

  void markNotificationRead(String id) {
    for (var n in _notifications) {
      if (n.id == id) n.read = true;
    }
    notifyListeners();
  }

  void setBudget(String category, double limit) {
    final idx = _budgets.indexWhere((b) => b.category == category);
    if (idx >= 0) {
      _budgets[idx].limit = limit;
    } else {
      _budgets = [..._budgets, Budget(category: category, limit: limit)];
    }
    _saveBudgets();
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    SharedPreferences.getInstance()
        .then((p) => p.setBool('isDarkMode', _isDarkMode));
    notifyListeners();
  }

  void setSelectedExpense(Expense? expense) {
    _selectedExpense = expense;
    notifyListeners();
  }

  void setShowExpenseDetail(bool show) {
    _showExpenseDetail = show;
    notifyListeners();
  }

  // Stored user accounts for legacy login validation (optional, can be removed once fully migrated to Firebase)
  List<Map<String, String>> _registeredUsers = [];

  void addRegisteredUser(String name, String email, String password) {
    _registeredUsers = [
      ..._registeredUsers,
      {'name': name, 'email': email, 'password': password}
    ];
  }

  bool validateLogin(String email, String password) {
    return _registeredUsers.any(
      (u) =>
          u['email']!.toLowerCase() == email.toLowerCase() &&
          u['password'] == password,
    );
  }

  String? getNameForEmail(String email) {
    final user = _registeredUsers.firstWhere(
      (u) => u['email']!.toLowerCase() == email.toLowerCase(),
      orElse: () => {},
    );
    return user.isEmpty ? null : user['name'];
  }

  bool isEmailRegistered(String email) {
    return _registeredUsers
        .any((u) => u['email']!.toLowerCase() == email.toLowerCase());
  }

  // New Settings Setters
  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    notifyListeners();
  }

  Future<void> setCurrency(String curr) async {
    _currency = curr;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', curr);
    notifyListeners();
  }

  Future<void> setPushNotificationsEnabled(bool enabled) async {
    _pushNotificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pushNotificationsEnabled', enabled);
    notifyListeners();
  }

  Future<void> setOverallBudget(double amount) async {
    _overallBudget = amount;
    _hasSeenBudgetWarningThisMonth = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('overallBudget', amount);
    await prefs.setBool('hasSeenBudgetWarningThisMonth', false);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _db
          .collection('users')
          .doc(user.uid)
          .set({'overallBudget': amount}, SetOptions(merge: true));
    }
    notifyListeners();
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _expenses = [];
    _notifications = [];
    _overallBudget = 0.0;

    _isLoggedIn = false;
    _userName = '';
    _userEmail = '';
    _profileImage = '';

    _language = 'English';
    _currency = 'TRY (₺)';
    _pushNotificationsEnabled = true;
    _isDarkMode = false;

    _screenHistory = ['login'];
    notifyListeners();
  }

  String formatCurrency(double amount) {
    return formatCurrencyWithSymbol(amount);
  }

  void setSelectedMonth(String month) {
    _selectedMonth = month;
    notifyListeners();
  }

  void setScreenArgs(Map<String, dynamic>? args) {
    _screenArgs = args;
    notifyListeners();
  }

  String formatCurrencyWithSymbol(double amount) {
    return '$currencySymbol${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}';
  }
}
