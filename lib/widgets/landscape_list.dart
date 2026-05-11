import 'package:flutter/material.dart';
import '../models/debt.dart';
import '../constants.dart';
import '../widgets/table_header.dart';

class LandscapeList extends StatelessWidget {
  final List<Debt> sorted;
  final double bottomPadding;
  final double topPadding;
  final Function(Debt) onTap;
  final Function(String) onDismissed;

  const LandscapeList({
    super.key,
    required this.sorted,
    required this.bottomPadding,
    required this.topPadding,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: TableHeaderDelegate(topPadding: topPadding),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding + 80),
          sliver: sorted.isEmpty
              ? const SliverFillRemaining(
                  child: Center(
                    child: Text('Долгов нет — добавь первый',
                        style: TextStyle(color: Colors.grey)),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final d = sorted[i];
                      return Dismissible(
                        key: ValueKey(d.id),
                        direction: DismissDirection.startToEnd,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(Icons.delete,
                              color: Colors.white),
                        ),
                        onDismissed: (_) => onDismissed(d.id),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => onTap(d),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  _creditorCell(d),
                                  _dataCell(d.lastPayment, colLastPay),
                                  _dataCell(d.nextPayment, colNextPay),
                                  _dataCell(d.agreement, colAgreement),
                                  _dataCell(d.lastContact, colContact),
                                  _dataCell(d.consequences, colConsequences),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: sorted.length,
                  ),
                ),
        ),
      ],
    );
  }

  // Ячейка с именем кредитора, суммой и типом
  Widget _creditorCell(Debt d) {
    return SizedBox(
      width: colCreditor,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    color: d.type.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(d.creditor,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '${d.amount.toStringAsFixed(0)} ₽  ${d.rate}%',
              style: TextStyle(fontSize: 11, color: Colors.indigo[700]),
            ),
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: d.type.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(d.type.label,
                  style: TextStyle(fontSize: 10, color: d.type.color)),
            ),
          ],
        ),
      ),
    );
  }

  // Ячейка с текстовыми данными фиксированной ширины
  Widget _dataCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Text(
          text.isEmpty ? '—' : text,
          style: TextStyle(
              fontSize: 12,
              color: text.isEmpty ? Colors.grey[400] : Colors.black87),
        ),
      ),
    );
  }
}