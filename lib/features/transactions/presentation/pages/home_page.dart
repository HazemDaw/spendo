import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/transaction.dart';
import '../widgets/balance_bar.dart';
import '../widgets/connector_lines_painter.dart';
import '../widgets/donut_chart_widget.dart';
import '../widgets/home_action_buttons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Size _referenceSize = Size(738, 1600);
  static const Offset _chartCenter = Offset(369, 686);
  static const double _donutOuterRadius = 205;
  static const double _donutInnerRadius = 120;
  static const double _donutStartAngle = 320;
  static const double _orbitRadius = 294;
  static const double _iconHitRadius = 34;
  static final NumberFormat _homeAmountFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: 'RUB',
    decimalDigits: 2,
  );
  static const List<String> _sliceOrder = <String>[
    'clothing',
    'communication',
    'housing',
    'transport',
    'food',
    'sport',
    'health',
    'entertainment',
  ];

  TransactionPeriod _selectedPeriod = TransactionPeriod.month;

  @override
  Widget build(BuildContext context) {
    final List<Transaction> filteredTransactions = MockData.sampleTransactions
        .where(
          (Transaction transaction) =>
              AppDateUtils.matchesPeriod(transaction.date, _selectedPeriod),
        )
        .toList();
    final double income = filteredTransactions
        .where((Transaction transaction) =>
            transaction.type == TransactionType.income)
        .fold<double>(
          0,
          (double sum, Transaction transaction) => sum + transaction.amount,
        );
    final double expense = filteredTransactions
        .where((Transaction transaction) =>
            transaction.type == TransactionType.expense)
        .fold<double>(
          0,
          (double sum, Transaction transaction) => sum + transaction.amount,
        );
    final Map<String, double> expenseTotals = _buildExpenseTotals(
      filteredTransactions,
    );
    final List<DonutCategorySlice> slices = _buildSlices(expenseTotals);
    final List<_OrbitNode> orbitNodes = _buildOrbitNodes(expenseTotals);
    final List<OrbitConnector> connectors = _buildConnectors(
      slices: slices,
      orbitNodes: orbitNodes,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF7AC793),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2FFF6),
        drawer: const _PhaseDrawer(icon: Icons.menu_rounded),
        endDrawer: const _PhaseDrawer(icon: Icons.more_vert_rounded),
        body: Align(
          alignment: Alignment.topCenter,
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: _referenceSize.width,
              height: _referenceSize.height,
              child: Stack(
                children: <Widget>[
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0xFFF2FFF6),
                    ),
                  ),
                  const Positioned(
                    left: 0,
                    top: 0,
                    right: 0,
                    child: SizedBox(
                      height: 156,
                      child: ColoredBox(color: Color(0xFF7AC793)),
                    ),
                  ),
                  _buildHeader(),
                  Positioned(
                    left: 6,
                    top: 190,
                    child: Text(
                      '10 Mar',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFBAC9C1),
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 288,
                    top: 190,
                    child: GestureDetector(
                      onTap: _cyclePeriod,
                      child: Text(
                        '11 Mar - 25 Mar',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF96A69C),
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: ConnectorLinesPainter(connectors: connectors),
                      ),
                    ),
                  ),
                  Positioned(
                    left: _chartCenter.dx - _donutOuterRadius,
                    top: _chartCenter.dy - _donutOuterRadius,
                    child: DonutChartWidget(
                      slices: slices,
                      incomeText: _homeAmountFormatter.format(income),
                      expenseText: _homeAmountFormatter.format(expense),
                      startAngleDegrees: _donutStartAngle,
                      outerRadius: _donutOuterRadius,
                      innerRadius: _donutInnerRadius,
                      onSliceTap: (String categoryKey) {
                        context.pushNamed(
                          'transactionList',
                          pathParameters: <String, String>{
                            'categoryKey': categoryKey,
                          },
                        );
                      },
                    ),
                  ),
                  for (final _OrbitNode node in orbitNodes) _buildOrbitNode(node),
                  Positioned(
                    left: 44,
                    right: 44,
                    top: 1248,
                    child: BalanceBar(
                      balanceText: _formatSignedHomeAmount(income - expense),
                    ),
                  ),
                  Positioned(
                    left: 70,
                    right: 70,
                    top: 1362,
                    child: HomeActionButtons(
                      expenseLabel: 'Expense',
                      incomeLabel: 'Income',
                      onExpensePressed: () {
                        context.pushNamed(
                          'addTransaction',
                          queryParameters: const <String, String>{
                            'type': 'expense',
                          },
                        );
                      },
                      onIncomePressed: () {
                        context.pushNamed(
                          'addTransaction',
                          queryParameters: const <String, String>{
                            'type': 'income',
                          },
                        );
                      },
                    ),
                  ),
                  const Positioned(
                    left: 175,
                    right: 175,
                    bottom: 18,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFF808582),
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                      child: SizedBox(height: 8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      left: 20,
      right: 10,
      top: 54,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Builder(
            builder: (BuildContext scaffoldContext) {
              return IconButton(
                onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
                icon: const Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              );
            },
          ),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Spendo',
                style: GoogleFonts.parisienne(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Transform.translate(
                offset: const Offset(4, -6),
                child: Text(
                  'All accounts',
                  style: GoogleFonts.inter(
                    color: const Color(0xE6FFFFFF),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(
            Icons.search_rounded,
            color: Colors.white,
            size: 38,
          ),
          const SizedBox(width: 34),
          const Icon(
            Icons.swap_horiz_rounded,
            color: Colors.white,
            size: 38,
          ),
          const SizedBox(width: 22),
          Builder(
            builder: (BuildContext scaffoldContext) {
              return IconButton(
                onPressed: () => Scaffold.of(scaffoldContext).openEndDrawer(),
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Positioned _buildOrbitNode(_OrbitNode node) {
    return Positioned(
      left: node.position.dx - 42,
      top: node.position.dy - 42,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: node.categoryKey == null
            ? null
            : () {
                context.pushNamed(
                  'addTransaction',
                  queryParameters: <String, String>{
                    'type': 'expense',
                    'categoryKey': node.categoryKey!,
                  },
                );
              },
        child: SizedBox(
          width: 84,
          child: Column(
            children: <Widget>[
              Icon(
                node.icon,
                color: node.color.withValues(alpha: node.active ? 1 : 0.78),
                size: 58,
              ),
              if (node.label != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  node.label!,
                  style: GoogleFonts.inter(
                    color: node.color,
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Map<String, double> _buildExpenseTotals(List<Transaction> filteredTransactions) {
    final Map<String, double> totals = <String, double>{};

    for (final Transaction transaction in filteredTransactions) {
      if (transaction.type != TransactionType.expense ||
          transaction.categoryKey == null) {
        continue;
      }

      totals.update(
        transaction.categoryKey!,
        (double value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    return totals;
  }

  List<DonutCategorySlice> _buildSlices(Map<String, double> totals) {
    return _sliceOrder
        .where((String key) => (totals[key] ?? 0) > 0)
        .map(
          (String key) => DonutCategorySlice(
            categoryKey: key,
            value: totals[key]!,
            color: MockData.categoryByKey(key)!.color,
          ),
        )
        .toList();
  }

  List<_OrbitNode> _buildOrbitNodes(Map<String, double> totals) {
    final double totalExpense = totals.values.fold<double>(
      0,
      (double sum, double value) => sum + value,
    );

    final List<_OrbitNode> nodes = <_OrbitNode>[];
    const double startAngleDegrees = -90;
    const double stepAngleDegrees = 360 / 8;
    for (int i = 0; i < _sliceOrder.length; i++) {
      final String key = _sliceOrder[i];
      final category = MockData.categoryByKey(key)!;
      final double angle = (startAngleDegrees + (stepAngleDegrees * i)) *
          (math.pi / 180);
      final Offset position = Offset(
        _chartCenter.dx + (math.cos(angle) * _orbitRadius),
        _chartCenter.dy + (math.sin(angle) * _orbitRadius),
      );
      nodes.add(
        _OrbitNode(
          position: position,
          icon: category.icon,
          color: category.color,
          categoryKey: key,
          label: _percentLabel(totals, totalExpense, key),
        ),
      );
    }

    return nodes.map((_OrbitNode node) {
      final bool active =
          node.categoryKey != null && (totals[node.categoryKey] ?? 0) > 0;
      return node.copyWith(active: active);
    }).toList();
  }

  List<OrbitConnector> _buildConnectors({
    required List<DonutCategorySlice> slices,
    required List<_OrbitNode> orbitNodes,
  }) {
    if (slices.isEmpty) {
      return const <OrbitConnector>[];
    }

    final Map<String, _OrbitNode> nodeByKey = <String, _OrbitNode>{
      for (final _OrbitNode node in orbitNodes)
        if (node.categoryKey != null) node.categoryKey!: node,
    };
    final double total = slices.fold<double>(
      0,
      (double sum, DonutCategorySlice slice) => sum + slice.value,
    );
    double currentAngle = _donutStartAngle * (math.pi / 180);
    final List<OrbitConnector> connectors = <OrbitConnector>[];
    for (final DonutCategorySlice slice in slices) {
      final _OrbitNode? node = nodeByKey[slice.categoryKey];
      if (node == null || !node.active) {
        currentAngle += (slice.value / total) * (math.pi * 2);
        continue;
      }
      final double sweep = (slice.value / total) * (math.pi * 2);
      final double midAngle = currentAngle + (sweep / 2);
      final Offset chartEdge = Offset(
        _chartCenter.dx + (math.cos(midAngle) * _donutOuterRadius),
        _chartCenter.dy + (math.sin(midAngle) * _donutOuterRadius),
      );
      final Offset toIcon = node.position - chartEdge;
      final double distance = toIcon.distance;
      if (distance == 0) {
        currentAngle += sweep;
        continue;
      }
      final Offset unit = toIcon / distance;
      final Offset iconEdge = node.position - (unit * _iconHitRadius);
      connectors.add(
        OrbitConnector(
          start: chartEdge,
          end: iconEdge,
          color: node.color,
        ),
      );
      currentAngle += sweep;
    }
    return connectors;
  }

  String? _percentLabel(
    Map<String, double> totals,
    double totalExpense,
    String key,
  ) {
    final double amount = totals[key] ?? 0;
    if (amount <= 0 || totalExpense <= 0) {
      return null;
    }

    return '${((amount / totalExpense) * 100).round()}%';
  }

  String _formatSignedHomeAmount(double amount) {
    final String formatted = _homeAmountFormatter.format(amount.abs());
    return amount.isNegative ? '-$formatted' : formatted;
  }

  void _cyclePeriod() {
    setState(() {
      _selectedPeriod = switch (_selectedPeriod) {
        TransactionPeriod.day => TransactionPeriod.week,
        TransactionPeriod.week => TransactionPeriod.month,
        TransactionPeriod.month => TransactionPeriod.day,
      };
    });
  }
}

class _OrbitNode {
  const _OrbitNode({
    required this.position,
    required this.icon,
    required this.color,
    this.categoryKey,
    this.label,
    this.active = false,
  });

  final Offset position;
  final IconData icon;
  final Color color;
  final String? categoryKey;
  final String? label;
  final bool active;

  _OrbitNode copyWith({
    String? label,
    bool? active,
  }) {
    return _OrbitNode(
      position: position,
      icon: icon,
      color: color,
      categoryKey: categoryKey,
      label: label ?? this.label,
      active: active ?? this.active,
    );
  }
}

class _PhaseDrawer extends StatelessWidget {
  const _PhaseDrawer({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, color: const Color(0xFF7AC793), size: 32),
              const SizedBox(height: 16),
              Text(
                'Phase 1 drawer stub',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
