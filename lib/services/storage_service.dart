import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/debt.dart';

class StorageService {
  static Future<List<Debt>> loadDebts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('debts');
    if (data == null) return [];
    final List decoded = jsonDecode(data);
    return decoded.map((e) => Debt.fromJson(e)).toList();
  }

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_seen') ?? false;
  }

  static Future<void> saveDebts(List<Debt> debts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'debts', jsonEncode(debts.map((d) => d.toJson()).toList()));
    await prefs.setBool('onboarding_seen', true);
  }
}