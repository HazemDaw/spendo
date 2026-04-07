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
    final List<OrbitConnector> connectors = orbitNodes
        .where((node) => node.active)
        .map(
          (node) => OrbitConnector(
            iconCenter: node.position,
            color: node.color,
            active: true,
          ),
        )
        .toList();

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
                  Positioned(
                    left: _chartCenter.dx - (_donutOuterRadius * 1.15),
                    top: _chartCenter.dy - (_donutOuterRadius * 1.15),
                    child: SizedBox(
                      width: _donutOuterRadius * 2.3,
                      height: _donutOuterRadius * 2.3,
                      child: CustomPaint(
                        painter: ConnectorLinesPainter(
                          connectors: connectors,
                          center: const Offset(
                            _donutOuterRadius * 1.15,
                            _donutOuterRadius * 1.15,
                          ),
                          chartRadius: _donutOuterRadius,
                        ),
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
                'Monefy',
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
                    fontSize: 25,
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

    return <_OrbitNode>[
      _OrbitNode(
        position: const Offset(70, 324),
        icon: Icons.accessibility_new_outlined,
        color: MockData.categoryByKey('sport')!.color,
        categoryKey: 'sport',
        label: _percentLabel(totals, totalExpense, 'sport'),
      ),
      _OrbitNode(
        position: const Offset(250, 322),
        icon: Icons.restaurant_menu_outlined,
        color: MockData.categoryByKey('health')!.color,
        categoryKey: 'health',
        label: _percentLabel(totals, totalExpense, 'health'),
      ),
      _OrbitNode(
        position: const Offset(472, 322),
        icon: Icons.local_bar_outlined,
        color: MockData.categoryByKey('entertainment')!.color,
        categoryKey: 'entertainment',
        label: _percentLabel(totals, totalExpense, 'entertainment'),
      ),
      _OrbitNode(
        position: const Offset(650, 324),
        icon: Icons.card_giftcard_outlined,
        color: MockData.categoryByKey('gifts')!.color,
        categoryKey: 'gifts',
      ),
      _OrbitNode(
        position: const Offset(94, 520),
        icon: Icons.pets_outlined,
        color: MockData.categoryByKey('pets')!.color,
        categoryKey: 'pets',
      ),
      _OrbitNode(
        position: const Offset(640, 518),
        icon: Icons.checkroom_outlined,
        color: MockData.categoryByKey('clothing')!.color,
        categoryKey: 'clothing',
        label: _percentLabel(totals, totalExpense, 'clothing'),
      ),
      _OrbitNode(
        position: const Offset(72, 686),
        icon: Icons.shopping_basket_outlined,
        color: MockData.categoryByKey('food')!.color,
        categoryKey: 'food',
        label: _percentLabel(totals, totalExpense, 'food'),
      ),
      _OrbitNode(
        position: const Offset(652, 684),
        icon: Icons.phone_outlined,
        color: MockData.categoryByKey('communication')!.color,
        categoryKey: 'communication',
        label: _percentLabel(totals, totalExpense, 'communication'),
      ),
      const _OrbitNode(
        position: Offset(76, 902),
        icon: Icons.sports_tennis_outlined,
        color: Color(0xFFEA8D94),
      ),
      const _OrbitNode(
        position: Offset(614, 902),
        icon: Icons.work_outline_rounded,
        color: Color(0xFFDBAE4F),
      ),
      _OrbitNode(
        position: const Offset(76, 1080),
        icon: Icons.calendar_month_outlined,
        color: MockData.categoryByKey('transport')!.color,
        categoryKey: 'transport',
        label: _percentLabel(totals, totalExpense, 'transport'),
      ),
      const _OrbitNode(
        position: Offset(312, 1100),
        icon: Icons.directions_car_outlined,
        color: Color(0xFF9097A0),
      ),
      const _OrbitNode(
        position: Offset(476, 1090),
        icon: Icons.restaurant_outlined,
        color: Color(0xFF97A89A),
      ),
      _OrbitNode(
        position: const Offset(650, 1086),
        icon: Icons.home_outlined,
        color: MockData.categoryByKey('housing')!.color,
        categoryKey: 'housing',
        label: _percentLabel(totals, totalExpense, 'housing'),
      ),
    ].map((_OrbitNode node) {
      final bool active =
          node.categoryKey != null && (totals[node.categoryKey] ?? 0) > 0;
      return node.copyWith(active: active);
    }).toList();
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
