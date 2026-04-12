import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:spendo/features/transactions/domain/entities/transaction.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
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
  static const double _orbitGridOffset = 114;
  static const double _iconTouchSize = 84;
  static const double _iconSize = 58;
  static const double _slotAxisRadius = _donutOuterRadius + _orbitGridOffset;
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
  static const List<_OrbitAssignment> _orbitAssignments =
      <_OrbitAssignment>[
        _OrbitAssignment(
          categoryKey: 'entertainment',
          slot: _OrbitSlot.topLeft,
        ),
        _OrbitAssignment(
          categoryKey: 'clothing',
          slot: _OrbitSlot.topCenter,
        ),
        _OrbitAssignment(
          categoryKey: 'communication',
          slot: _OrbitSlot.topRight,
        ),
        _OrbitAssignment(
          categoryKey: 'housing',
          slot: _OrbitSlot.right,
        ),
        _OrbitAssignment(
          categoryKey: 'transport',
          slot: _OrbitSlot.bottomRight,
        ),
        _OrbitAssignment(
          categoryKey: 'food',
          slot: _OrbitSlot.bottomCenter,
        ),
        _OrbitAssignment(
          categoryKey: 'sport',
          slot: _OrbitSlot.bottomLeft,
        ),
        _OrbitAssignment(
          categoryKey: 'health',
          slot: _OrbitSlot.left,
        ),
      ];

  TransactionPeriod _selectedPeriod = TransactionPeriod.month;

  @override
  Widget build(BuildContext context) {
    final String selectedPeriodLabel = _selectedPeriodLabel();
    final TransactionState transactionState = context.watch<TransactionBloc>().state;
    final double income = transactionState is TransactionLoaded
        ? transactionState.totalIncome
        : 0;
    final double expense = transactionState is TransactionLoaded
        ? transactionState.totalExpense
        : 0;
    final Map<String, double> expenseTotals = transactionState is TransactionLoaded
        ? transactionState.categoryTotals
        : const <String, double>{};
    final List<Transaction> allTransactions = transactionState is TransactionLoaded
        ? transactionState.transactions
        : MockData.sampleTransactions;
    final List<DonutCategorySlice> slices = _buildSlices(expenseTotals);
    final List<_OrbitNode> orbitNodes = _buildOrbitNodes(expenseTotals);
    final List<OrbitConnector> connectors = _buildConnectors(
      slices: slices,
      orbitNodes: orbitNodes,
    );
    final bool isLoading =
        transactionState is TransactionInitial ||
        transactionState is TransactionLoading;

    return BlocListener<TransactionBloc, TransactionState>(
      listener: (BuildContext context, TransactionState state) {
        if (state is TransactionError &&
            (ModalRoute.of(context)?.isCurrent ?? false)) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.message)),
            );
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
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
                        selectedPeriodLabel,
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
                          selectedPeriodLabel,
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
                      child: SizedBox.square(
                        dimension: _donutOuterRadius * 2,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            DonutChartWidget(
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
                            if (isLoading)
                              const SizedBox(
                                width: 36,
                                height: 36,
                                child: CircularProgressIndicator(strokeWidth: 2.5),
                              ),
                          ],
                        ),
                      ),
                    ),
                    for (final _OrbitNode node in orbitNodes) _buildOrbitNode(node),
                    Positioned(
                      left: 44,
                      right: 44,
                      top: 1248,
                      child: BalanceBar(
                        balanceText: _formatSignedHomeAmount(income - expense),
                        onTap: () => context.push(
                          '/all-transactions',
                          extra: allTransactions,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 70,
                      right: 70,
                      top: 1362,
                      child: HomeActionButtons(
                        expenseLabel: 'Expense',
                        incomeLabel: 'Income',
                        onExpensePressed: () async {
                          final Object? result = await context.pushNamed(
                            'addTransaction',
                            queryParameters: const <String, String>{
                              'type': 'expense',
                            },
                          );
                          if (!mounted) {
                            return;
                          }
                          _showAddResult(result);
                        },
                        onIncomePressed: () async {
                          final Object? result = await context.pushNamed(
                            'addTransaction',
                            queryParameters: const <String, String>{
                              'type': 'income',
                            },
                          );
                          if (!mounted) {
                            return;
                          }
                          _showAddResult(result);
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
      left: node.position.dx - (_iconTouchSize / 2),
      top: node.position.dy - (_iconTouchSize / 2),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          final Object? result = await context.pushNamed(
            'addTransaction',
            queryParameters: <String, String>{
              'type': 'expense',
              'categoryKey': node.categoryKey,
            },
          );
          if (!mounted) {
            return;
          }
          _showAddResult(result);
        },
        child: SizedBox(
          width: _iconTouchSize,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox.square(
                dimension: _iconTouchSize,
                child: Center(
                  child: Icon(
                    node.icon,
                    color: node.color.withValues(alpha: node.active ? 1 : 0.42),
                    size: _iconSize,
                  ),
                ),
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
    return _orbitAssignments.map((_OrbitAssignment assignment) {
      final category = MockData.categoryByKey(assignment.categoryKey)!;
      final bool active = (totals[assignment.categoryKey] ?? 0) > 0;
      return _OrbitNode(
        position: _slotPosition(assignment.slot),
        slot: assignment.slot,
        icon: category.icon,
        color: category.color,
        categoryKey: assignment.categoryKey,
        label: active
            ? _percentLabel(totals, totalExpense, assignment.categoryKey)
            : null,
        active: active,
      );
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
      for (final _OrbitNode node in orbitNodes) node.categoryKey: node,
    };
    final double total = slices.fold<double>(
      0,
      (double sum, DonutCategorySlice slice) => sum + slice.value,
    );
    double currentAngle = _donutStartAngle * (math.pi / 180);
    final List<OrbitConnector> connectors = <OrbitConnector>[];
    for (final DonutCategorySlice slice in slices) {
      final _OrbitNode? node = nodeByKey[slice.categoryKey];
      if (node == null) {
        currentAngle += (slice.value / total) * (math.pi * 2);
        continue;
      }
      final double sweep = (slice.value / total) * (math.pi * 2);
      final double midAngle = currentAngle + (sweep / 2);
      final Offset chartEdge = Offset(
        _chartCenter.dx + (math.cos(midAngle) * _donutOuterRadius),
        _chartCenter.dy + (math.sin(midAngle) * _donutOuterRadius),
      );
      connectors.add(
        OrbitConnector(
          start: chartEdge,
          end: node.position,
          color: node.color,
          chartCenter: _chartCenter,
          routeRadius: _routeRadiusFor(node.slot),
        ),
      );
      currentAngle += sweep;
    }
    return connectors;
  }

  Offset _slotPosition(_OrbitSlot slot) {
    return switch (slot) {
      _OrbitSlot.topLeft => Offset(
          _chartCenter.dx - _slotAxisRadius,
          _chartCenter.dy - _slotAxisRadius,
        ),
      _OrbitSlot.topCenter => Offset(
          _chartCenter.dx,
          _chartCenter.dy - _slotAxisRadius,
        ),
      _OrbitSlot.topRight => Offset(
          _chartCenter.dx + _slotAxisRadius,
          _chartCenter.dy - _slotAxisRadius,
        ),
      _OrbitSlot.right => Offset(
          _chartCenter.dx + _slotAxisRadius,
          _chartCenter.dy,
        ),
      _OrbitSlot.bottomRight => Offset(
          _chartCenter.dx + _slotAxisRadius,
          _chartCenter.dy + _slotAxisRadius,
        ),
      _OrbitSlot.bottomCenter => Offset(
          _chartCenter.dx,
          _chartCenter.dy + _slotAxisRadius,
        ),
      _OrbitSlot.bottomLeft => Offset(
          _chartCenter.dx - _slotAxisRadius,
          _chartCenter.dy + _slotAxisRadius,
        ),
      _OrbitSlot.left => Offset(
          _chartCenter.dx - _slotAxisRadius,
          _chartCenter.dy,
        ),
    };
  }

  double _routeRadiusFor(_OrbitSlot slot) {
    return switch (slot) {
      _OrbitSlot.topCenter || _OrbitSlot.bottomCenter => _donutOuterRadius + 56,
      _OrbitSlot.left || _OrbitSlot.right => _donutOuterRadius + 70,
      _OrbitSlot.topLeft ||
      _OrbitSlot.topRight ||
      _OrbitSlot.bottomRight ||
      _OrbitSlot.bottomLeft => _donutOuterRadius + 86,
    };
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

  String _selectedPeriodLabel() {
    final DateTime now = DateTime.now();
    return switch (_selectedPeriod) {
      TransactionPeriod.day =>
        DateFormat('d MMM yyyy', 'ru_RU').format(now),
      TransactionPeriod.week => _currentWeekLabel(now),
      TransactionPeriod.month =>
        DateFormat('MMM yyyy', 'ru_RU').format(now),
    };
  }

  String _currentWeekLabel(DateTime now) {
    final DateTime weekStart = AppDateUtils.getPeriodRange(
      TransactionPeriod.week,
      now: now,
    ).start;
    final DateFormat formatter = DateFormat('d MMM', 'ru_RU');
    return '${formatter.format(weekStart)} — ${formatter.format(now)}';
  }

  void _cyclePeriod() {
    setState(() {
      _selectedPeriod = switch (_selectedPeriod) {
        TransactionPeriod.day => TransactionPeriod.week,
        TransactionPeriod.week => TransactionPeriod.month,
        TransactionPeriod.month => TransactionPeriod.day,
      };
    });
    context.read<TransactionBloc>().add(LoadTransactionsEvent(_selectedPeriod));
  }

  void _showAddResult(Object? result) {
    final messenger = ScaffoldMessenger.of(context);
    if (result == 'added') {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.transactionAddedMessage),
          ),
        );
    } else if (result == 'updated') {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.transactionUpdatedMessage,
            ),
          ),
        );
    } else if (result == 'deleted') {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.transactionDeletedMessage,
            ),
          ),
        );
    }
  }
}

class _OrbitNode {
  const _OrbitNode({
    required this.position,
    required this.slot,
    required this.icon,
    required this.color,
    required this.categoryKey,
    required this.active,
    this.label,
  });

  final Offset position;
  final _OrbitSlot slot;
  final IconData icon;
  final Color color;
  final String categoryKey;
  final bool active;
  final String? label;
}

class _OrbitAssignment {
  const _OrbitAssignment({
    required this.categoryKey,
    required this.slot,
  });

  final String categoryKey;
  final _OrbitSlot slot;
}

enum _OrbitSlot {
  topLeft,
  topCenter,
  topRight,
  right,
  bottomRight,
  bottomCenter,
  bottomLeft,
  left,
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
