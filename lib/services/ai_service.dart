import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/debt.dart';
import '../config.dart';
import 'package:flutter/foundation.dart';

class AiService {
  // Сортирует долги одного типа по приоритету через Gemini
  static Future<List<Debt>> sortDebtsByRisk(List<Debt> debts) async {
    if (debts.length <= 1) return debts;

    final debtDescriptions = debts.asMap().entries.map((e) {
      final d = e.value;
        return '${e.key}:${d.rate}%,${d.nextPayment},${d.consequences}';

    }).join('\n');

final prompt = 'Долги по приоритету от опасного к безопасному. Учти %%, дату, последствия. Верни только номера через запятую.\n$debtDescriptions';


    try {
  final client = http.Client();
  try {
    final response = await client.post(
      Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=$geminiApiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      }),
    ).timeout(const Duration(seconds: 15));

    debugPrint('Gemini статус: ${response.statusCode}');
    debugPrint('Gemini тело: ${response.body}');


    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text =
          data['candidates'][0]['content']['parts'][0]['text'] as String;
      debugPrint('Gemini ответил: $text');

      final indices = text
          .trim()
          .split(',')
          .map((s) => int.tryParse(s.trim()))
          .whereType<int>()
          .toList();

      if (indices.length == debts.length) {
        return indices.map((i) => debts[i]).toList();
      }
    }
  } finally {
    client.close();
  }
} catch (e) {
  debugPrint('Gemini ошибка: $e');
}

    return debts;
  }
}