import 'package:flutter/material.dart';
import 'dart:async';
import '../models/debt.dart';
import '../widgets/add_debt_sheet.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';
import '../widgets/debt_card.dart';
import '../widgets/onboarding_dialog.dart';
import '../widgets/landscape_list.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Debt> _debts = [];
  bool _showOnboarding = true;
  final Set<String> _expandedIds = {};
  String? _deletedMessage;
  Timer? _deleteTimer;
  int _deleteCountdown = 5;
  VoidCallback? _undoCallback;
  bool _isAiSorting = false;
  @override
  void initState() {
    super.initState();
    _loadDebts();
  }

Future<void> _loadDebts() async {
  final debts = await StorageService.loadDebts();
  final seen = await StorageService.hasSeenOnboarding();
  setState(() {
    _debts.addAll(debts);
    _showOnboarding = !seen;
  });
}

Future<void> _saveDebts() async {
  await StorageService.saveDebts(_debts);
}

  double get _totalDebt => _debts.fold(0, (sum, d) => sum + d.amount);

  List<Debt> get _sortedDebts {
    final sorted = List<Debt>.from(_debts);
    sorted.sort((a, b) => a.type.priority.compareTo(b.type.priority));
    return sorted;
  }

  void _deleteDebtById(String id) {
    final idx = _debts.indexWhere((d) => d.id == id);
    if (idx == -1) return;
    final debt = _debts[idx];
    setState(() {
      _debts.removeAt(idx);
      _deletedMessage = 'Долг «${debt.creditor}» удалён';
      _deleteCountdown = 5;
    });
    _saveDebts();

    _deleteTimer?.cancel();
    _undoCallback = () {
      setState(() => _debts.insert(idx, debt));
      _saveDebts();
    };

    _deleteTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _deleteCountdown--);
      if (_deleteCountdown <= 0) {
        t.cancel();
        setState(() {
          _deletedMessage = null;
          _undoCallback = null;
        });
      }
    });
  }

void _showAddDebtSheet({Debt? existing}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => AddDebtSheet(
      existing: existing,
      onSave: (debt) async {
        if (existing != null) {
          final idx = _debts.indexWhere((d) => d.id == existing.id);
          if (idx != -1) {
            setState(() => _debts[idx] = debt);
          }
          _saveDebts();
        } else {
          setState(() {
            _debts.add(debt);
            _isAiSorting = true;
          });
          _saveDebts();
          await _aiSortDebtsOfType(debt.type);
          if (mounted) setState(() => _isAiSorting = false);
        }
      },
    ),
  );
}

Future<void> _aiSortDebtsOfType(DebtType type) async {
  final sameType = _debts.where((d) => d.type == type).toList();
  final sorted = await AiService.sortDebtsByRisk(sameType);
  
  setState(() {
    for (final d in sameType) {
      _debts.remove(d);
    }
    _debts.addAll(sorted);
  });
  _saveDebts();
}

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final sorted = _sortedDebts;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          isLandscape
              ? _buildLandscape(sorted, bottomPadding)
              : _buildPortrait(sorted, bottomPadding),
          if (_showOnboarding) _buildOnboarding(),
        ],
      ),
floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: FloatingActionButton(
          onPressed: () => _showAddDebtSheet(),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
  bottomSheet: _isAiSorting
      ? Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            margin: EdgeInsets.only(left: 16, bottom: bottomPadding + 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Text('Оцениваю риски...',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        )
      : _deletedMessage == null
          ? null
          : Container(
              color: Colors.grey[850],
              padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding + 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$_deletedMessage · $_deleteCountdown',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _deleteTimer?.cancel();
                      _undoCallback?.call();
                      setState(() {
                        _deletedMessage = null;
                        _undoCallback = null;
                      });
                    },
                    child: const Text('Отмена',
                        style: TextStyle(color: Colors.indigo)),
                  ),
                ],
              ),
            ),
    );
  }

Widget _buildLandscape(List<Debt> sorted, double bottomPadding) {
  final topPadding = MediaQuery.of(context).padding.top;
  return LandscapeList(
    sorted: sorted,
    bottomPadding: bottomPadding,
    topPadding: topPadding,
    onTap: (d) => _showAddDebtSheet(existing: d),
    onDismissed: (id) => _deleteDebtById(id),
  );
}

  Widget _buildPortrait(List<Debt> sorted, double bottomPadding) {
    return Column(
      children: [
        AppBar(
          title: const Text('Мои долги'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        _buildTotalCard(),
        Expanded(
          child: sorted.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                      16, 0, 16, bottomPadding + 80),
                  itemCount: sorted.length,
                  itemBuilder: (ctx, i) {
                    return _buildPortraitItem(sorted[i], i);
                  },
                ),
        ),
      ],
    );
  }
Widget _buildPortraitItem(Debt d, int i) {
  return DebtCard(
    debt: d,
    isExpanded: _expandedIds.contains(d.id),
    onTap: () => _showAddDebtSheet(existing: d),
    onToggleExpand: () {
      setState(() {
        if (_expandedIds.contains(d.id)) {
          _expandedIds.remove(d.id);
        } else {
          _expandedIds.add(d.id);
        }
      });
    },
    onDismissed: () => _deleteDebtById(d.id),
  );
}

// Экран когда список долгов пуст
Widget _buildEmptyState() {
  return const Center(
    child: Text(
      'Долгов нет — добавь первый',
      style: TextStyle(color: Colors.grey),
    ),
  );
}

Widget _buildTotalCard() {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.indigo,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Общий долг',
            style: TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          '${_totalDebt.toStringAsFixed(0)} ₽',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold),
        ),
        Text('${_debts.length} долгов',
            style: const TextStyle(color: Colors.white70)),
      ],
    ),
  );
}
// Красный фон который появляется при свайпе для удаления


  // Экран приветствия при первом запуске
Widget _buildOnboarding() {
  return OnboardingDialog(
    onDismiss: () => setState(() => _showOnboarding = false),
    onAddDebt: () {
      setState(() => _showOnboarding = false);
      _showAddDebtSheet();
    },
  );
}
}