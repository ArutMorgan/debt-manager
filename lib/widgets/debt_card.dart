import 'package:flutter/material.dart';
import '../models/debt.dart';

class DebtCard extends StatelessWidget {
  final Debt debt;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onToggleExpand;
  final VoidCallback onDismissed;

  const DebtCard({
    super.key,
    required this.debt,
    required this.isExpanded,
    required this.onTap,
    required this.onToggleExpand,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(debt.id),
      direction: DismissDirection.startToEnd,
      background: _buildDismissBackground(),
      onDismissed: (_) => onDismissed(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                if (isExpanded) ...[
                  const Divider(height: 20),
                  _infoRow('Последний платёж', debt.lastPayment),
                  _infoRow('Следующий платёж', debt.nextPayment),
                  _infoRow('Договорились', debt.agreement),
                  _infoRow('Последний контакт', debt.lastContact),
                  _infoRow('Последствия неуплаты', debt.consequences),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Красный фон при свайпе
  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  // Заголовок карточки — имя, тип, сумма, шеврон
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: debt.type.color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(debt.creditor,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: debt.type.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(debt.type.label,
                        style: TextStyle(
                            fontSize: 11, color: debt.type.color)),
                  ),
                ],
              ),
              Text(
                '${debt.amount.toStringAsFixed(0)} ₽  ·  ${debt.rate}%',
                style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onToggleExpand,
          child: SizedBox(
            width: 60,
            height: 44,
            child: Center(
              child: Text(
                isExpanded ? '⌃' : '⌄',
                style: const TextStyle(
                    fontSize: 26, color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Строка с информацией о долге
  Widget _infoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}