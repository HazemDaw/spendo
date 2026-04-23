import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:spendo/features/transactions/domain/entities/transaction.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/app_left_drawer.dart';
import '../widgets/app_right_drawer.dart';
import '../widgets/connector_lines_painter.dart';
import '../widgets/donut_chart_widget.dart';
import '../widgets/home_action_buttons.dart';
import '../widgets/transaction_list_item.dart';

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
  DateTime _referenceDate = DateTime.now();
  double _slideDirection = 0;

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;
    const Color headerBg = Color(0xFF7C3AED);
    final Color canvasBg =
        isDark ? const Color(0xFF1E1B2E) : const Color(0xFFF5F3FF);
    const Color balanceBarBg = Color(0xFF7C3AED);
    final Color textOnCanvas =
        isDark ? Colors.white : const Color(0xFF1E1B4B);
    final Color textSecondary =
        isDark ? const Color(0xFFB0A8CC) : const Color(0xFF6B7280);
    // ignore: unused_local_variable
    const Color periodChipSelected = Color(0xFF7C3AED);
    // ignore: unused_local_variable
    final Color periodChipUnselected =
        isDark ? const Color(0xFF2D2640) : Colors.transparent;
    const Color periodChipLabelSelected = Colors.white;
    // ignore: unused_local_variable
    final Color periodChipLabelUnselected =
        isDark ? Colors.white70 : const Color(0xFF7C3AED);
    final TransactionState transactionState = context.watch<TransactionBloc>().state;
    final DateTime now = DateTime.now();
    final DateTime oldestTransactionDate = _oldestTransactionDate(
      transactionState,
      now,
    );
    final TransactionDateRange displayedRange = AppDateUtils.getPeriodRange(
      _selectedPeriod,
      referenceDate: _referenceDate,
    );
    final bool isAtOldestBoundary = _containsDate(
      displayedRange,
      oldestTransactionDate,
    );
    final bool isAtFutureBoundary = _containsDate(displayedRange, now);
    final String selectedPeriodLabel = _buildDateLabel(
      displayedRange: displayedRange,
      now: now,
    );
    final double income = transactionState is TransactionLoaded
        ? transactionState.totalIncome
        : 0;
    final double expense = transactionState is TransactionLoaded
        ? transactionState.totalExpense
        : 0;
    final Map<String, double> expenseTotals = transactionState is TransactionLoaded
        ? transactionState.categoryTotals
        : const <String, double>{};
    final double dynamicStartAngle = _computeStartAngle(expenseTotals);
    final List<Transaction> allTransactions = transactionState is TransactionLoaded
        ? transactionState.transactions
        : MockData.sampleTransactions;
    final List<DonutCategorySlice> slices = _buildSlices(expenseTotals);
    final List<_OrbitNode> orbitNodes = _buildOrbitNodes(expenseTotals);
    final List<OrbitConnector> connectors = _buildConnectors(
      orbitNodes: orbitNodes,
      startAngle: dynamicStartAngle,
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
          statusBarColor: Color(0xFF7C3AED),
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: canvasBg,
          drawer: AppLeftDrawer(
            selectedPeriod: _selectedPeriod,
            currentPeriodLabel: selectedPeriodLabel,
            onPeriodSelected: _selectPeriod,
          ),
          drawerEnableOpenDragGesture: false,
          endDrawer: const AppRightDrawer(),
          endDrawerEnableOpenDragGesture: false,
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
                      child: SizedBox.shrink(),
                    ),
                    Positioned.fill(
                      child: ColoredBox(color: canvasBg),
                    ),
                    const Positioned(
                      left: 0,
                      top: 0,
                      right: 0,
                      child: SizedBox(
                        height: 156,
                        child: ColoredBox(color: headerBg),
                      ),
                    ),
                    _buildHeader(
                      titleColor: periodChipLabelSelected,
                      subtitleColor: textSecondary,
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 128,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () => _navigatePeriod(-1, oldestTransactionDate),
                            child: Icon(
                              Icons.chevron_left,
                              color: isAtOldestBoundary
                                  ? Colors.transparent
                                  : (isDark ? Colors.white54 : headerBg),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _cyclePeriod,
                            child: Text(
                              selectedPeriodLabel,
                              style: GoogleFonts.inter(
                                color: textOnCanvas,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _navigatePeriod(1, oldestTransactionDate),
                            child: Icon(
                              Icons.chevron_right,
                              color: isAtFutureBoundary
                                  ? Colors.transparent
                                  : (isDark ? Colors.white54 : headerBg),
                              size: 28,
                            ),
                          ),
                        ],
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
                      child: GestureDetector(
                        onHorizontalDragEnd: (DragEndDetails details) {
                          if (details.primaryVelocity == null) {
                            return;
                          }
                          if (details.primaryVelocity! > 200) {
                            _navigatePeriod(-1, oldestTransactionDate);
                          }
                          if (details.primaryVelocity! < -200) {
                            _navigatePeriod(1, oldestTransactionDate);
                          }
                        },
                        child: SizedBox.square(
                          dimension: _donutOuterRadius * 2,
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (
                                  Widget child,
                                  Animation<double> animation,
                                ) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: Offset(_slideDirection, 0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  );
                                },
                                child: SizedBox.square(
                                  key: ValueKey<DateTime>(_referenceDate),
                                  dimension: _donutOuterRadius * 2,
                                  child: DonutChartWidget(
                                    slices: slices,
                                    incomeText: _homeAmountFormatter.format(income),
                                    expenseText: _homeAmountFormatter.format(
                                      expense,
                                    ),
                                    startAngleDegrees: dynamicStartAngle,
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
                    ),
                    for (final _OrbitNode node in orbitNodes) _buildOrbitNode(node),
                    Positioned(
                      left: 44,
                      right: 44,
                      top: 1248,
                      child: Builder(
                        builder: (BuildContext scaffoldContext) {
                          return _HomeBalanceBar(
                            balanceText: _formatSignedHomeAmount(
                              income - expense,
                            ),
                            backgroundColor: balanceBarBg,
                            onTap: () => context.push(
                              '/all-transactions',
                              extra: allTransactions,
                            ),
                            onMenuTap: () =>
                                Scaffold.of(scaffoldContext).openEndDrawer(),
                          );
                        },
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
                   
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required Color titleColor,
    required Color subtitleColor,
  }) {
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
                  color: titleColor,
                  fontSize: 52,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Transform.translate(
                offset: const Offset(4, -6),
                child: Text(
                  'All accounts',
                  style: GoogleFonts.inter(
                    color: subtitleColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: _TransactionSearchDelegate(
                  transactions:
                      (context.read<TransactionBloc>().state
                              is TransactionLoaded)
                          ? (context.read<TransactionBloc>().state
                                  as TransactionLoaded)
                              .transactions
                          : <Transaction>[],
                ),
              );
            },
            icon: const Icon(
              Icons.search_rounded,
              color: Colors.white,
              size: 38,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      
          const SizedBox(width: 6),
          Builder(
            builder: (BuildContext scaffoldContext) {
              return IconButton(
                onPressed: () => Scaffold.of(scaffoldContext).openEndDrawer(),
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white,
                  size: 38,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
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
    final Map<String, _OrbitSlot> slotAssignment = _assignSlots(totals);
    return _orbitAssignments.map((_OrbitAssignment assignment) {
      final category = MockData.categoryByKey(assignment.categoryKey)!;
      final _OrbitSlot slot =
          slotAssignment[assignment.categoryKey] ?? assignment.slot;
      final bool active = (totals[assignment.categoryKey] ?? 0) > 0;
      return _OrbitNode(
        position: _slotPosition(slot),
        slot: slot,
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

  Map<String, _OrbitSlot> _assignSlots(Map<String, double> totals) {
    final double total = _sliceOrder.fold<double>(
      0,
      (double sum, String key) => sum + (totals[key] ?? 0),
    );
    const Map<_OrbitSlot, double> slotAngles = <_OrbitSlot, double>{
      _OrbitSlot.topCenter: -math.pi / 2,
      _OrbitSlot.topRight: -math.pi / 4,
      _OrbitSlot.right: 0,
      _OrbitSlot.bottomRight: math.pi / 4,
      _OrbitSlot.bottomCenter: math.pi / 2,
      _OrbitSlot.bottomLeft: 3 * math.pi / 4,
      _OrbitSlot.left: math.pi,
      _OrbitSlot.topLeft: -3 * math.pi / 4,
    };

    if (total <= 0) {
      return <String, _OrbitSlot>{
        for (final _OrbitAssignment assignment in _orbitAssignments)
          assignment.categoryKey: assignment.slot,
      };
    }

    double currentAngle = _computeStartAngle(totals) * math.pi / 180;
    final Map<String, double> segmentMidAngles = <String, double>{};
    for (final String key in _sliceOrder) {
      final double amount = totals[key] ?? 0;
      if (amount <= 0) {
        continue;
      }
      final double sweep = (amount / total) * 2 * math.pi;
      segmentMidAngles[key] = currentAngle + (sweep / 2);
      currentAngle += sweep;
    }

    final Map<String, _OrbitSlot> assignment = <String, _OrbitSlot>{};
    final Set<_OrbitSlot> usedSlots = <_OrbitSlot>{};
    final List<MapEntry<String, double>> sortedCategories =
        segmentMidAngles.entries.toList()
          ..sort(
            (MapEntry<String, double> a, MapEntry<String, double> b) =>
                a.value.compareTo(b.value),
          );

    for (final MapEntry<String, double> entry in sortedCategories) {
      _OrbitSlot? bestSlot;
      double bestDiff = double.infinity;
      for (final MapEntry<_OrbitSlot, double> slot in slotAngles.entries) {
        if (usedSlots.contains(slot.key)) {
          continue;
        }
        double diff = (slot.value - entry.value).abs();
        if (diff > math.pi) {
          diff = (2 * math.pi) - diff;
        }
        if (diff < bestDiff) {
          bestDiff = diff;
          bestSlot = slot.key;
        }
      }
      if (bestSlot != null) {
        assignment[entry.key] = bestSlot;
        usedSlots.add(bestSlot);
      }
    }

    for (final _OrbitAssignment defaultAssignment in _orbitAssignments) {
      if (assignment.containsKey(defaultAssignment.categoryKey)) {
        continue;
      }
      for (final _OrbitSlot slot in slotAngles.keys) {
        if (usedSlots.contains(slot)) {
          continue;
        }
        assignment[defaultAssignment.categoryKey] = slot;
        usedSlots.add(slot);
        break;
      }
    }

    return assignment;
  }

  double _computeStartAngle(Map<String, double> totals) {
    final double total = _sliceOrder.fold<double>(
      0,
      (double sum, String key) => sum + (totals[key] ?? 0),
    );
    if (total <= 0) {
      return _donutStartAngle;
    }

    const double targetMidAngle = -90.0 * (math.pi / 180);
    final double sweep0 = ((totals[_sliceOrder[0]] ?? 0) / total) * 2 * math.pi;
    final double startAngleRadians = targetMidAngle - (sweep0 / 2);
    return startAngleRadians * (180 / math.pi);
  }

  List<OrbitConnector> _buildConnectors({
    required List<_OrbitNode> orbitNodes,
    required double startAngle,
  }) {
    final double currentAngle = startAngle * (math.pi / 180);
    assert(currentAngle.isFinite);
    final List<OrbitConnector> connectors = <OrbitConnector>[];
    for (final _OrbitNode node in orbitNodes) {
      if (!node.active) {
        continue;
      }

      final Offset direction = _chartCenter - node.position;
      final double distance = direction.distance;
      if (distance == 0) {
        continue;
      }
      final Offset normalized = direction / distance;
      final Offset lineStart = node.position + (normalized * 60);
      final Offset lineEnd = _chartCenter - (normalized * _donutOuterRadius);

      assert(_routeRadiusFor(node.slot) >= 0);

      connectors.add(
        OrbitConnector(
          start: lineStart,
          end: lineEnd,
          color: Colors.grey,
          chartCenter: _chartCenter,
          routeRadius: 0,
        ),
      );
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

  String _buildDateLabel({
    required TransactionDateRange displayedRange,
    required DateTime now,
  }) {
    final DateFormat dayFormatter = DateFormat('d MMM yyyy', 'ru_RU');
    final DateFormat monthFormatter = DateFormat('MMMM yyyy', 'ru_RU');

    return switch (_selectedPeriod) {
      TransactionPeriod.day => _isSameDay(_referenceDate, now)
          ? 'Сегодня'
          : dayFormatter.format(_referenceDate),
      TransactionPeriod.week => _containsDate(displayedRange, now)
          ? 'Эта неделя'
          : _currentWeekLabel(displayedRange.end),
      TransactionPeriod.month => _isSameMonth(_referenceDate, now)
          ? 'Этот месяц'
          : monthFormatter.format(_referenceDate),
    };
  }

  String _currentWeekLabel(DateTime now) {
    final DateTime weekStart = AppDateUtils.getPeriodRange(
      TransactionPeriod.week,
      referenceDate: now,
    ).start;
    final DateFormat formatter = DateFormat('d MMM', 'ru_RU');
    return '${formatter.format(weekStart)} — ${formatter.format(now)}';
  }

  DateTime _oldestTransactionDate(
    TransactionState transactionState,
    DateTime now,
  ) {
    if (transactionState is TransactionLoaded &&
        transactionState.oldestTransactionDate != null) {
      final DateTime oldest = transactionState.oldestTransactionDate!;
      return DateTime(oldest.year, oldest.month, oldest.day);
    }

    return DateTime(now.year, now.month - 12, now.day);
  }

  bool _containsDate(TransactionDateRange range, DateTime date) {
    return !date.isBefore(range.start) && !date.isAfter(range.end);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  void _navigatePeriod(int direction, DateTime oldestTransactionDate) {
    final DateTime now = DateTime.now();
    final TransactionDateRange currentRange = AppDateUtils.getPeriodRange(
      _selectedPeriod,
      referenceDate: _referenceDate,
    );
    if (direction > 0 && _containsDate(currentRange, now)) {
      return;
    }

    final DateTime candidate = switch (_selectedPeriod) {
      TransactionPeriod.day => _referenceDate.add(Duration(days: direction)),
      TransactionPeriod.week => _referenceDate.add(
          Duration(days: direction * 7),
        ),
      TransactionPeriod.month => DateTime(
          _referenceDate.year,
          _referenceDate.month + direction,
          1,
        ),
    };
    final TransactionDateRange candidateRange = AppDateUtils.getPeriodRange(
      _selectedPeriod,
      referenceDate: candidate,
    );
    if (candidateRange.end.isBefore(oldestTransactionDate)) {
      return;
    }

    DateTime nextReferenceDate = candidate;
    if (candidate.isAfter(now) || _containsDate(candidateRange, now)) {
      nextReferenceDate = now;
    }

    setState(() {
      _slideDirection = direction > 0 ? -1.0 : 1.0;
      _referenceDate = nextReferenceDate;
    });
    context.read<TransactionBloc>().add(
      LoadTransactionsEvent(
        _selectedPeriod,
        referenceDate: nextReferenceDate,
      ),
    );
  }

  void _cyclePeriod() {
    _selectPeriod(
      switch (_selectedPeriod) {
        TransactionPeriod.day => TransactionPeriod.week,
        TransactionPeriod.week => TransactionPeriod.month,
        TransactionPeriod.month => TransactionPeriod.day,
      },
    );
  }

  void _selectPeriod(TransactionPeriod period) {
    if (_selectedPeriod == period) {
      return;
    }
    setState(() {
      _selectedPeriod = period;
    });
    context.read<TransactionBloc>().add(
      LoadTransactionsEvent(
        period,
        referenceDate: _referenceDate,
      ),
    );
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

class _HomeBalanceBar extends StatelessWidget {
  const _HomeBalanceBar({
    required this.balanceText,
    required this.backgroundColor,
    this.onTap,
    this.onMenuTap,
  });

  final String balanceText;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _HomeBalanceHandle(color: backgroundColor),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 410,
            height: 76,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: const Color(0x88764340),
                width: 2,
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x332D2E2D),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'Balance  $balanceText',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        _HomeBalanceHandle(
          color: backgroundColor,
          onTap: onMenuTap,
        ),
      ],
    );
  }
}

class _HomeBalanceHandle extends StatelessWidget {
  const _HomeBalanceHandle({
    required this.color,
    this.onTap,
  });

  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          children: <Widget>[
            _HomeHandleLine(width: 74, color: color),
            const SizedBox(height: 8),
            _HomeHandleLine(width: 58, color: color),
            const SizedBox(height: 8),
            _HomeHandleLine(width: 74, color: color),
          ],
        ),
      ),
    );
  }
}

class _HomeHandleLine extends StatelessWidget {
  const _HomeHandleLine({
    required this.width,
    required this.color,
  });

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 3,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
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

class _TransactionSearchDelegate extends SearchDelegate<Transaction?> {
  _TransactionSearchDelegate({required this.transactions});

  final List<Transaction> transactions;

  @override
  String get searchFieldLabel => 'Поиск транзакций...';

  @override
  List<Widget> buildActions(BuildContext context) => <Widget>[
    IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () => query = '',
    ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final List<Transaction> results = transactions.where((Transaction t) {
      final String q = query.toLowerCase();
      return t.note?.toLowerCase().contains(q) == true ||
          (t.categoryKey?.toLowerCase().contains(q) == true) ||
          t.amount.toString().contains(q);
    }).toList()..sort((Transaction a, Transaction b) => b.date.compareTo(a.date));

    if (results.isEmpty) {
      return const Center(child: Text('Ничего не найдено'));
    }

    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        return TransactionListItem(
          transaction: results[index],
          onTap: () {
            close(context, results[index]);
            context.pushNamed(
              'editTransaction',
              pathParameters: <String, String>{
                'transactionId': results[index].id,
              },
            );
          },
        );
      },
    );
  }
}
