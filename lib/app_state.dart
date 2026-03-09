import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  // Auth
  bool _isLoggedIn = false;
  String _userName = '';
  String _userEmail = '';
  String _profileImage = '';

  // Navigation stack
  List<String> _screenHistory = ['splash'];

  // Expenses
  List<Expense> _expenses = List.from(kRecentExpenses);

  // Notifications
  final List<AppNotification> _notifications = List.from(kDefaultNotifications);

  // Budgets
  double _overallBudget = 0.0;
  bool _hasSeenBudgetWarningThisMonth = false;
  String _selectedMonth =
      DateTime.now().toString().substring(0, 7); // YYYY-MM format

  // Theme
  bool _isDarkMode = false;

  // Expense detail
  Expense? _selectedExpense;
  bool _showExpenseDetail = false;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get profileImage => _profileImage;
  String get currentScreen => _screenHistory.last;
  List<Expense> get expenses => _expenses;
  List<AppNotification> get notifications => _notifications;
  double get overallBudget => _overallBudget;
  String get selectedMonth => _selectedMonth;
  bool get hasSeenBudgetWarningThisMonth => _hasSeenBudgetWarningThisMonth;
  bool get isDarkMode => _isDarkMode;
  Expense? get selectedExpense => _selectedExpense;
  bool get showExpenseDetail => _showExpenseDetail;
  int get unreadCount => _notifications.where((n) => !n.read).length;

  AppState() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _userName = prefs.getString('userName') ?? '';
    _userEmail = prefs.getString('userEmail') ?? '';
    _profileImage = prefs.getString('profileImage') ?? '';
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;

    final expensesJson = prefs.getString('expenses');
    if (expensesJson != null) {
      final List<dynamic> decoded = jsonDecode(expensesJson);
      _expenses = decoded.map((e) => Expense.fromJson(e)).toList();
    }

    _overallBudget = prefs.getDouble('overallBudget') ?? 0.0;
    _hasSeenBudgetWarningThisMonth =
        prefs.getBool('budgetWarning_${DateTime.now().month}') ?? false;

    notifyListeners();
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'expenses', jsonEncode(_expenses.map((e) => e.toJson()).toList()));
  }

  Future<void> _saveBudget() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('overallBudget', _overallBudget);
  }

  Future<void> _markWarningSeen() async {
    _hasSeenBudgetWarningThisMonth = true;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('budgetWarning_${DateTime.now().month}', true);
    notifyListeners();
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

  void login(String name, String email) {
    _userName = name;
    _userEmail = email;
    _isLoggedIn = true;
    _screenHistory = ['dashboard'];
    _saveUserData();
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _screenHistory = ['login'];
    SharedPreferences.getInstance().then((p) => p.setBool('isLoggedIn', false));
    notifyListeners();
  }

  void register(String name, String email) {
    login(name, email);
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', _isLoggedIn);
    prefs.setString('userName', _userName);
    prefs.setString('userEmail', _userEmail);
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

  void setOverallBudget(double limit) {
    _overallBudget = limit;
    _saveBudget();
    _checkBudgetWarning();
    notifyListeners();
  }

  void setSelectedMonth(String yearMonth) {
    _selectedMonth = yearMonth;
    notifyListeners();
  }

  void _checkBudgetWarning() {
    if (_overallBudget <= 0 || _hasSeenBudgetWarningThisMonth) return;

    final currentMonthExpenses = _expenses.where(
        (e) => e.date.startsWith(DateTime.now().toString().substring(0, 7)));

    final spentThisMonth =
        currentMonthExpenses.fold(0.0, (s, e) => s + e.amount);

    if (spentThisMonth >= _overallBudget * 0.9) {
      _hasSeenBudgetWarningThisMonth = true;
      _markWarningSeen();
      _notifications.insert(
          0,
          AppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Budget Warning',
            message:
                'You have spent ${((spentThisMonth / _overallBudget) * 100).toStringAsFixed(0)}% of your monthly budget.',
            time: 'Just now',
            read: false,
            type: 'warning',
          ));
      notifyListeners();
    }
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

  // Stored user accounts for login validation
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
}
