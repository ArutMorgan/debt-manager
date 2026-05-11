import 'package:flutter/material.dart';
import '../models/debt.dart';

class AddDebtSheet extends StatefulWidget {
  final Debt? existing;
  final Future<void> Function(Debt) onSave;

  const AddDebtSheet({super.key, this.existing, required this.onSave});

  @override
  State<AddDebtSheet> createState() => _AddDebtSheetState();
}

class _AddDebtSheetState extends State<AddDebtSheet> {
  int _step = 0;
  DebtType _type = DebtType.bank;

  late TextEditingController creditorCtrl;
  late TextEditingController amountCtrl;
  late TextEditingController rateCtrl;
  late TextEditingController lastPaymentCtrl;
  late TextEditingController nextPaymentCtrl;
  late TextEditingController agreementCtrl;
  late TextEditingController lastContactCtrl;
  late TextEditingController consequencesCtrl;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    creditorCtrl = TextEditingController(text: e?.creditor ?? '');
    amountCtrl = TextEditingController(
        text: e != null ? e.amount.toString() : '');
    rateCtrl = TextEditingController(
        text: e != null ? e.rate.toString() : '');
    lastPaymentCtrl = TextEditingController(text: e?.lastPayment ?? '');
    nextPaymentCtrl = TextEditingController(text: e?.nextPayment ?? '');
    agreementCtrl = TextEditingController(text: e?.agreement ?? '');
    lastContactCtrl = TextEditingController(text: e?.lastContact ?? '');
    consequencesCtrl =
        TextEditingController(text: e?.consequences ?? '');
    if (e != null) _type = e.type;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom +
              bottomPadding +
              24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _step == 0
                      ? (widget.existing == null
                          ? 'Новый долг'
                          : 'Редактировать')
                      : 'Подробности',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 4),
            Row(children: [
              _stepDot(0),
              const SizedBox(width: 8),
              _stepDot(1)
            ]),
            const SizedBox(height: 16),
            if (_step == 0) ...[
              TextField(
                  controller: creditorCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Кому должен',
                      border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Сумма (₽)',
                      border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                  controller: rateCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Процент (%)',
                      border: OutlineInputBorder())),
              const SizedBox(height: 12),
              const Text('Тип долга',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: DebtType.values.map((t) {
                  final selected = _type == t;
                  return ChoiceChip(
                    label: Text(t.label),
                    selected: selected,
                    selectedColor: t.color.withOpacity(0.2),
                    onSelected: (_) => setState(() => _type = t),
                  );
                }).toList(),
              ),
            ] else ...[
              TextField(
                  controller: lastPaymentCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Дата последнего платежа',
                      border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                  controller: nextPaymentCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Дата следующего платежа',
                      border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                  controller: agreementCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'О чём договаривались',
                      border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                  controller: lastContactCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Последняя коммуникация',
                      border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                  controller: consequencesCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Последствия неуплаты',
                      border: OutlineInputBorder())),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                if (_step == 1) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _step = 0),
                      child: const Text('Назад'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14)),
                    onPressed: () async {
                      if (_step == 0) {
                        setState(() => _step = 1);
                      } else {
                        debugPrint('onSave вызывается');
                        debugPrint('existing: ${widget.existing}');
                        await widget.onSave(Debt(
                          id: widget.existing?.id,
                          creditor: creditorCtrl.text,
                          type: _type,
                          amount:
                              double.tryParse(amountCtrl.text) ?? 0,
                          rate: double.tryParse(rateCtrl.text) ?? 0,
                          lastPayment: lastPaymentCtrl.text,
                          nextPayment: nextPaymentCtrl.text,
                          agreement: agreementCtrl.text,
                          lastContact: lastContactCtrl.text,
                          consequences: consequencesCtrl.text,
                        ));
                        Navigator.pop(context);
                      }
                    },
                    child: Text(_step == 0 ? 'Далее' : 'Сохранить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepDot(int step) {
    return Container(
      width: step == _step ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: step == _step ? Colors.indigo : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}