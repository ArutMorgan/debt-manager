import 'package:flutter/material.dart';
enum DebtType { bank, microloan, person, company }

extension DebtTypeLabel on DebtType {
  String get label {
    switch (this) {
      case DebtType.bank:
        return 'Банк';
      case DebtType.microloan:
        return 'Микрозайм';
      case DebtType.person:
        return 'Физлицо';
      case DebtType.company:
        return 'Юрлицо';
    }
  }

  int get priority {
    switch (this) {
      case DebtType.microloan:
        return 1;
      case DebtType.bank:
        return 2;
      case DebtType.company:
        return 3;
      case DebtType.person:
        return 4;
    }
  }

  Color get color {
    switch (this) {
      case DebtType.microloan:
        return Colors.red;
      case DebtType.bank:
        return Colors.orange;
      case DebtType.company:
        return Colors.blue;
      case DebtType.person:
        return Colors.green;
    }
  }
}

class Debt {
  final String id;
  String creditor;
  DebtType type;
  double amount;
  double rate;
  String lastPayment;
  String nextPayment;
  String agreement;
  String lastContact;
  String consequences;

  Debt({
    String? id,
    required this.creditor,
    required this.type,
    required this.amount,
    required this.rate,
    required this.lastPayment,
    required this.nextPayment,
    required this.agreement,
    required this.lastContact,
    required this.consequences,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
        'id': id,
        'creditor': creditor,
        'type': type.index,
        'amount': amount,
        'rate': rate,
        'lastPayment': lastPayment,
        'nextPayment': nextPayment,
        'agreement': agreement,
        'lastContact': lastContact,
        'consequences': consequences,
      };

  factory Debt.fromJson(Map<String, dynamic> json) => Debt(
        id: json['id'] as String?,
        creditor: json['creditor'],
        type: DebtType.values[json['type'] ?? 0],
        amount: (json['amount'] as num).toDouble(),
        rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
        lastPayment: json['lastPayment'] ?? '',
        nextPayment: json['nextPayment'] ?? '',
        agreement: json['agreement'] ?? '',
        lastContact: json['lastContact'] ?? '',
        consequences: json['consequences'] ?? '',
      );
}
