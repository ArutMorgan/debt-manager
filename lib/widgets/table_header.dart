import 'package:flutter/material.dart';
import '../constants.dart';
class TableHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;
  TableHeaderDelegate({required this.topPadding});

  @override
  double get minExtent => topPadding + 54;
  @override
  double get maxExtent => topPadding + 54;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.indigo,
      padding: EdgeInsets.only(
          top: topPadding + 8, left: 16, right: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: colCreditor,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Мои',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                Text('долги',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          _hCell('Посл. платёж', colLastPay),
          _hCell('След. платёж', colNextPay),
          _hCell('Договорились', colAgreement),
          _hCell('Контакт', colContact),
          _hCell('Последствия', colConsequences),
        ],
      ),
    );
  }

  Widget _hCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  @override
  bool shouldRebuild(TableHeaderDelegate oldDelegate) => false;
}