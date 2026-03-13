import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService {
  static const String _baseUrl = 'https://open.er-api.com/v6/latest';
  static const String _storageKey = 'cached_exchange_rates';
  static const String _timestampKey = 'rates_last_updated';

  // Default rates fallback (relative to TRY)
  static const Map<String, double> _defaultRates = {
    'TRY': 1.0,
    'USD': 0.029, // ~34.5 TRY
    'EUR': 0.027, // ~37.0 TRY
    'GBP': 0.023, // ~43.5 TRY
  };

  Map<String, double> _rates = {};

  Map<String, double> get rates => _rates.isEmpty ? _defaultRates : _rates;

  Future<void> init() async {
    await _loadCachedRates();
    // Try to update if older than 24 hours
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getInt(_timestampKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (now - lastUpdate > 24 * 60 * 60 * 1000) {
      await fetchLatestRates();
    }
  }

  Future<void> _loadCachedRates() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_storageKey);
    if (cached != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(cached);
        _rates = decoded.map((key, value) => MapEntry(key, (value as num).toDouble()));
      } catch (e) {
        _rates = {};
      }
    }
  }

  Future<void> fetchLatestRates() async {
    try {
      // We use TRY as base because it's the default app currency
      final response = await http.get(Uri.parse('$_baseUrl/TRY'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] == 'success') {
          final Map<String, dynamic> fetchedRates = data['rates'];
          _rates = fetchedRates.map((key, value) => MapEntry(key, (value as num).toDouble()));
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_storageKey, jsonEncode(_rates));
          await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
        }
      }
    } catch (e) {
      // Fallback is handled by getter
    }
  }

  double convert(double amount, String from, String to) {
    if (from == to) return amount;
    
    final currentRates = rates;
    if (!currentRates.containsKey(from) || !currentRates.containsKey(to)) {
      return amount; // Cannot convert
    }

    // Convert to TRY (base) then to target
    final amountInBase = amount / currentRates[from]!;
    return amountInBase * currentRates[to]!;
  }
  
  String getCurrencySymbol(String currency) {
    switch (currency) {
      case 'TRY (₺)':
      case 'TRY':
        return '₺';
      case 'USD (\$)':
      case 'USD':
        return '\$';
      case 'EUR (€)':
      case 'EUR':
        return '€';
      case 'GBP (£)':
      case 'GBP':
        return '£';
      default:
        return currency;
    }
  }

  String cleanCurrencyCode(String currency) {
    if (currency.contains('(')) {
      return currency.split('(')[0].trim();
    }
    return currency;
  }
}
