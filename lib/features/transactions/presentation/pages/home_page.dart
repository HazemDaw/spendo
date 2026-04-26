import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:spendo/features/transactions/domain/entities/transaction.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/utils/category_localizer.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../injection_container.dart';
import '../../../categories/data/datasources/custom_category_local_datasource.dart';
import '../../../categories/data/datasources/orbit_slot_datasource.dart';
import '../../../categories/data/models/custom_category_model.dart';
import '../../../categories/data/models/orbit_slot_model.dart';
import '../../../budget/domain/entities/budget.dart';
import '../../../budget/presentation/bloc/budget_bloc.dart';
import '../../../budget/presentation/bloc/budget_state.dart';
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
  static const List<_OrbitAssignment> _defaultOrbitAssignments =
      <_OrbitAssignment>[
        _OrbitAssignment(
          slotIndex: 0,
          categoryKey: 'entertainment',
          slot: _OrbitSlot.topLeft,
          isCustom: false,
        ),
        _OrbitAssignment(
          slotIndex: 1,
          categoryKey: 'clothing',
          slot: _OrbitSlot.topCenter,
          isCustom: false,
        ),
        _OrbitAssignment(
          slotIndex: 2,
          categoryKey: 'communication',
          slot: _OrbitSlot.topRight,
          isCustom: false,
        ),
        _OrbitAssignment(
          slotIndex: 3,
          categoryKey: 'housing',
          slot: _OrbitSlot.right,
          isCustom: false,
        ),
        _OrbitAssignment(
          slotIndex: 4,
          categoryKey: 'transport',
          slot: _OrbitSlot.bottomRight,
          isCustom: false,
        ),
        _OrbitAssignment(
          slotIndex: 5,
          categoryKey: 'food',
          slot: _OrbitSlot.bottomCenter,
          isCustom: false,
        ),
        _OrbitAssignment(
          slotIndex: 6,
          categoryKey: 'sport',
          slot: _OrbitSlot.bottomLeft,
          isCustom: false,
        ),
        _OrbitAssignment(
          slotIndex: 7,
          categoryKey: 'health',
          slot: _OrbitSlot.left,
          isCustom: false,
        ),
      ];

  TransactionPeriod _selectedPeriod = TransactionPeriod.month;
  DateTime _referenceDate = DateTime.now();
  DateTime? _intervalStart;
  DateTime? _intervalEnd;
  double _slideDirection = 0;
  List<_OrbitAssignment> _orbitAssignments =
      List<_OrbitAssignment>.from(_defaultOrbitAssignments);
  Map<String, CustomCategoryModel> _customOrbitCategories =
      <String, CustomCategoryModel>{};

  List<String> get _sliceOrder => _orbitAssignments
      .map(( _OrbitAssignment assignment) => assignment.categoryKey)
      .toList();

  @override
  void initState() {
    super.initState();
    _loadOrbitSlots();
  }

  Future<void> _loadOrbitSlots() async {
    final List<OrbitSlotModel> slots = await sl<OrbitSlotDatasource>().getSlots();
    final CustomCategoryLocalDatasource customCategoryDatasource =
        sl<CustomCategoryLocalDatasource>();
    final List<_OrbitAssignment> mappedAssignments = <_OrbitAssignment>[];
    final Map<String, CustomCategoryModel> customCategories =
        <String, CustomCategoryModel>{};

    for (final OrbitSlotModel slot in slots) {
      final _OrbitAssignment defaultAssignment =
          _defaultOrbitAssignments[slot.slotIndex];
      if (slot.isCustom) {
        final CustomCategoryModel? customCategory =
            await customCategoryDatasource.getById(slot.categoryKey);
        if (customCategory == null) {
          await sl<OrbitSlotDatasource>().resetSlot(slot.slotIndex);
          mappedAssignments.add(defaultAssignment);
          continue;
        }

        customCategories[customCategory.id] = customCategory;
        mappedAssignments.add(
          _OrbitAssignment(
            slotIndex: slot.slotIndex,
            categoryKey: customCategory.id,
            slot: defaultAssignment.slot,
            isCustom: true,
          ),
        );
        continue;
      }

      mappedAssignments.add(
        _OrbitAssignment(
          slotIndex: slot.slotIndex,
          categoryKey: slot.categoryKey,
          slot: defaultAssignment.slot,
          isCustom: false,
        ),
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _orbitAssignments = mappedAssignments;
      _customOrbitCategories = customCategories;
    });
  }

  Future<void> _openCategoriesPage() async {
    final Object? result = await context.push('/categories');
    if (!mounted || result != 'updated') {
      return;
    }

    await _loadOrbitSlots();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;
    const Color headerBg = Color(0xFF7C3AED);
    final Color canvasBg =
        isDark ? const Color(0xFF1E1B2E) : const Color(0xFFF5F3FF);
    const Color balanceBarBg = Color(0xFF7C3AED);
    // ignore: unused_local_variable
    final Color textOnCanvas =
        isDark ? Colors.white : const Color(0xFF1E1B4B);
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
      slices: slices,
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
          endDrawer: AppRightDrawer(onCategoriesTap: _openCategoriesPage),
          endDrawerEnableOpenDragGesture: false,
          body: Align(
            alignment: Alignment.topCenter,
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
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                            child: child,
                          );
                        },
                        child: SizedBox(
                          key: ValueKey<String>(
                            '${_selectedPeriod}_${_referenceDate.millisecondsSinceEpoch}',
                          ),
                          width: _referenceSize.width,
                          height: _referenceSize.height,
                          child: Stack(
                            children: <Widget>[
                              Positioned(
                                left: 0,
                                right: 0,
                                top: 170,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: GestureDetector(
                                        onTap: () => _navigatePeriod(
                                          -1,
                                          oldestTransactionDate,
                                        ),
                                        child: Text(
                                          isAtOldestBoundary
                                              ? ''
                                              : _buildAdjacentLabel(-1),
                                          style: GoogleFonts.inter(
                                            color: isDark
                                                ? Colors.white38
                                                : const Color(
                                                    0xFF7C3AED,
                                                  ).withValues(alpha: 0.4),
                                            fontSize: 20,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () => _navigatePeriod(
                                            -1,
                                            oldestTransactionDate,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Icon(
                                              Icons.chevron_left_rounded,
                                              color: isAtOldestBoundary
                                                  ? Colors.transparent
                                                  : isDark
                                                  ? Colors.white54
                                                  : const Color(0xFF7C3AED),
                                              size: 36,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: _cyclePeriod,
                                          child: Text(
                                            selectedPeriodLabel,
                                            style: GoogleFonts.inter(
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFF1E1B4B),
                                              fontSize: 28,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => _navigatePeriod(
                                            1,
                                            oldestTransactionDate,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Icon(
                                              Icons.chevron_right_rounded,
                                              color: isAtFutureBoundary
                                                  ? Colors.transparent
                                                  : isDark
                                                  ? Colors.white54
                                                  : const Color(0xFF7C3AED),
                                              size: 36,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: GestureDetector(
                                        onTap: () => _navigatePeriod(
                                          1,
                                          oldestTransactionDate,
                                        ),
                                        child: Text(
                                          isAtFutureBoundary
                                              ? ''
                                              : _buildAdjacentLabel(1),
                                          style: GoogleFonts.inter(
                                            color: isDark
                                                ? Colors.white38
                                                : const Color(
                                                    0xFF7C3AED,
                                                  ).withValues(alpha: 0.4),
                                            fontSize: 20,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                left: 32,
                                right: 32,
                                top: 220,
                                child: _buildBudgetWarningBanner(
                                  expenseTotals: expenseTotals,
                                  totalSpent: expense,
                                ),
                              ),
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: CustomPaint(
                                    painter: ConnectorLinesPainter(
                                      connectors: connectors,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: _chartCenter.dx - _donutOuterRadius,
                                top: _chartCenter.dy - _donutOuterRadius,
                                child: GestureDetector(
                                  child: SizedBox.square(
                                    dimension: _donutOuterRadius * 2,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        SizedBox.square(
                                          dimension: _donutOuterRadius * 2,
                                          child: DonutChartWidget(
                                            slices: slices,
                                            incomeText: _homeAmountFormatter
                                                .format(income),
                                            expenseText: _homeAmountFormatter
                                                .format(expense),
                                            startAngleDegrees:
                                                dynamicStartAngle,
                                            outerRadius: _donutOuterRadius,
                                            innerRadius: _donutInnerRadius,
                                            onSliceTap: (String categoryKey) {
                                              context.pushNamed(
                                                'transactionList',
                                                pathParameters:
                                                    <String, String>{
                                                  'categoryKey': categoryKey,
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                        if (isLoading)
                                          const SizedBox(
                                            width: 36,
                                            height: 36,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              for (final _OrbitNode node in orbitNodes)
                                _buildOrbitNode(node),
                            ],
                          ),
                        ),
                      ),
                      _buildHeader(
                        titleColor: periodChipLabelSelected,
                      ),
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
      ),
    );
  }

  Widget _buildHeader({
    required Color titleColor,
  }) {
    return Positioned(
      left: 20,
      right: 10,
      top: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Builder(
            builder: (BuildContext scaffoldContext) {
              return IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
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
            mainAxisAlignment: MainAxisAlignment.center,
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
    final List<DonutCategorySlice> slices = _sliceOrder
        .where((String key) => (totals[key] ?? 0) > 0)
        .map(
          (String key) => DonutCategorySlice(
            categoryKey: key,
            value: totals[key]!,
            color: _colorForOrbitCategory(key),
          ),
        )
        .toList();

    slices.sort(
      (DonutCategorySlice a, DonutCategorySlice b) =>
          b.value.compareTo(a.value),
    );
    return slices;
  }

  List<_OrbitNode> _buildOrbitNodes(Map<String, double> totals) {
    final double totalExpense = totals.values.fold<double>(
      0,
      (double sum, double value) => sum + value,
    );
    final Map<String, _OrbitSlot> slotAssignment = _assignSlots(totals);
    return _orbitAssignments.map(
      (_OrbitAssignment assignment) => _buildNodeForSlot(
        assignment,
        slotAssignment,
        totals,
        totalExpense,
      ),
    ).toList();
  }

  _OrbitNode _buildNodeForSlot(
    _OrbitAssignment assignment,
    Map<String, _OrbitSlot> slotAssignment,
    Map<String, double> totals,
    double totalExpense,
  ) {
    final _OrbitSlot slot =
        slotAssignment[assignment.categoryKey] ?? assignment.slot;

    if (!assignment.isCustom) {
      final category = MockData.categoryByKey(assignment.categoryKey)!;
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
    }

    final CustomCategoryModel? customCategory =
        _customOrbitCategories[assignment.categoryKey];
    if (customCategory == null) {
      final _OrbitAssignment fallbackAssignment =
          _defaultOrbitAssignments[assignment.slotIndex];
      return _buildNodeForSlot(
        fallbackAssignment,
        slotAssignment,
        totals,
        totalExpense,
      );
    }

    final bool active = (totals[customCategory.id] ?? 0) > 0;
    return _OrbitNode(
      position: _slotPosition(slot),
      slot: slot,
      icon: IconData(
        customCategory.iconCodePoint,
        fontFamily: customCategory.fontFamily,
      ),
      color: Color(customCategory.colorValue),
      categoryKey: customCategory.id,
      label: active ? _percentLabel(totals, totalExpense, customCategory.id) : null,
      active: active,
    );
  }

  Color _colorForOrbitCategory(String categoryKey) {
    final category = MockData.categoryByKey(categoryKey);
    if (category != null) {
      return category.color;
    }

    final CustomCategoryModel? customCategory = _customOrbitCategories[categoryKey];
    if (customCategory != null) {
      return Color(customCategory.colorValue);
    }

    return AppColors.primary;
  }

  Map<String, _OrbitSlot> _assignSlots(Map<String, double> totals) {
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
    final double total = _sliceOrder.fold<double>(
      0,
      (double sum, String key) => sum + (totals[key] ?? 0),
    );

    if (total <= 0) {
      return <String, _OrbitSlot>{
        for (final _OrbitAssignment assignment in _orbitAssignments)
          assignment.categoryKey: assignment.slot,
      };
    }

    final List<String> sortedKeys = _sliceOrder
        .where((String key) => (totals[key] ?? 0) > 0)
        .toList()
      ..sort(
          (String a, String b) =>
              (totals[b] ?? 0).compareTo(totals[a] ?? 0),
        );

    double currentAngle = _computeStartAngle(totals) * math.pi / 180;
    final Map<String, double> segmentMidAngles = <String, double>{};
    for (final String key in sortedKeys) {
      final double sweep = ((totals[key] ?? 0) / total) * 2 * math.pi;
      double midpointAngle = currentAngle + (sweep / 2);
      while (midpointAngle > math.pi) {
        midpointAngle -= 2 * math.pi;
      }
      while (midpointAngle < -math.pi) {
        midpointAngle += 2 * math.pi;
      }
      segmentMidAngles[key] = midpointAngle;
      currentAngle += sweep;
    }

    final Map<String, _OrbitSlot> assignment = <String, _OrbitSlot>{};
    final Set<_OrbitSlot> usedSlots = <_OrbitSlot>{};

    for (final String key in sortedKeys) {
      final double segmentAngle = segmentMidAngles[key]!;
      _OrbitSlot? bestSlot;
      double bestDiff = double.infinity;
      for (final MapEntry<_OrbitSlot, double> slot in slotAngles.entries) {
        if (usedSlots.contains(slot.key)) {
          continue;
        }
        double diff = (slot.value - segmentAngle).abs();
        if (diff > math.pi) {
          diff = (2 * math.pi) - diff;
        }
        if (diff < bestDiff) {
          bestDiff = diff;
          bestSlot = slot.key;
        }
      }
      if (bestSlot != null) {
        assignment[key] = bestSlot;
        usedSlots.add(bestSlot);
      }
    }

    final List<_OrbitSlot> remainingSlots = slotAngles.keys
        .where(( _OrbitSlot slot) => !usedSlots.contains(slot))
        .toList();
    int slotIndex = 0;
    for (final _OrbitAssignment assignmentEntry in _orbitAssignments) {
      if (assignment.containsKey(assignmentEntry.categoryKey)) {
        continue;
      }
      if (slotIndex < remainingSlots.length) {
        assignment[assignmentEntry.categoryKey] = remainingSlots[slotIndex++];
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

    String? largestKey;
    double largestValue = 0;
    for (final String key in _sliceOrder) {
      final double value = totals[key] ?? 0;
      if (value > largestValue) {
        largestValue = value;
        largestKey = key;
      }
    }
    if (largestKey == null) {
      return _donutStartAngle;
    }

    const double targetMidAngle = -math.pi / 2;
    final double sweep0 = (largestValue / total) * 2 * math.pi;
    final double startAngleRadians = targetMidAngle - (sweep0 / 2);
    return startAngleRadians * (180 / math.pi);
  }

  List<OrbitConnector> _buildConnectors({
    required List<DonutCategorySlice> slices,
    required List<_OrbitNode> orbitNodes,
    required double startAngle,
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

    double currentAngle = startAngle * (math.pi / 180);
    final List<OrbitConnector> connectors = <OrbitConnector>[];
    for (final DonutCategorySlice slice in slices) {
      final _OrbitNode? node = nodeByKey[slice.categoryKey];
      if (node == null || !node.active) {
        currentAngle += (slice.value / total) * 2 * math.pi;
        continue;
      }

      final double sweep = (slice.value / total) * 2 * math.pi;
      final double midAngle = currentAngle + sweep / 2;
      final Offset segmentEdge = Offset(
        _chartCenter.dx + math.cos(midAngle) * _donutOuterRadius,
        _chartCenter.dy + math.sin(midAngle) * _donutOuterRadius,
      );

      final Offset direction = segmentEdge - node.position;
      final double distance = direction.distance;
      if (distance == 0) {
        currentAngle += sweep;
        continue;
      }
      final Offset normalized = direction / distance;
      final Offset lineStart = node.position + (normalized * 55);

      assert(_routeRadiusFor(node.slot) >= 0);

        connectors.add(
          OrbitConnector(
            start: lineStart,
            end: segmentEdge,
            color: node.color,
            chartCenter: _chartCenter,
            routeRadius: 0,
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

  Widget _buildBudgetWarningBanner({
    required Map<String, double> expenseTotals,
    required double totalSpent,
  }) {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (BuildContext context, BudgetState state) {
        if (state is! BudgetLoaded) {
          return const SizedBox.shrink();
        }

        final List<String> exceededLabels = <String>[];
        final List<String> warningLabels = <String>[];
        for (final Budget budget in state.budgets) {
          if (budget.limitAmount <= 0) {
            continue;
          }

          final double spent = budget.isTotalBudget
              ? totalSpent
              : (expenseTotals[budget.categoryKey] ?? 0);
          if (spent >= budget.limitAmount) {
            exceededLabels.add(_budgetWarningLabel(context, budget.categoryKey));
          } else if (spent >= budget.limitAmount * 0.8) {
            warningLabels.add(_budgetWarningLabel(context, budget.categoryKey));
          }
        }

        if (exceededLabels.isEmpty && warningLabels.isEmpty) {
          return const SizedBox.shrink();
        }

        final bool isExceeded = exceededLabels.isNotEmpty;
        final String warningMessage = isExceeded
            ? 'Превышен бюджет: ${exceededLabels.join(', ')}'
            : 'Близко к лимиту: ${warningLabels.join(', ')}';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isExceeded
                ? AppColors.expenseLight
                : const Color(0xFFFFF3CD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isExceeded ? AppColors.expense : Colors.orange,
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                isExceeded ? Icons.warning : Icons.info_outline,
                color: isExceeded ? AppColors.expense : Colors.orange,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  warningMessage,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/budget'),
                child: const Text(
                  'Подробнее',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _budgetWarningLabel(BuildContext context, String? categoryKey) {
    if (categoryKey == null) {
      return 'общий';
    }

    final category = MockData.categoryByKey(categoryKey);
    if (category == null) {
      return categoryKey;
    }

    return CategoryLocalizer.label(AppLocalizations.of(context)!, category);
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
    final DateFormat dayFmt = DateFormat('d MMMM yyyy', 'ru_RU');
    final DateFormat weekFmt = DateFormat('d MMM', 'ru_RU');
    final DateFormat monthFmt = DateFormat('MMMM yyyy', 'ru_RU');
    final DateFormat yearFmt = DateFormat('yyyy', 'ru_RU');

    return switch (_selectedPeriod) {
      TransactionPeriod.day => dayFmt.format(_referenceDate),
      TransactionPeriod.week =>
        '${weekFmt.format(displayedRange.start)} — '
            '${weekFmt.format(displayedRange.end)}',
      TransactionPeriod.month => monthFmt.format(_referenceDate),
      TransactionPeriod.year => yearFmt.format(_referenceDate),
      TransactionPeriod.all => 'Все время',
      TransactionPeriod.interval =>
        '${weekFmt.format(_intervalStart ?? _referenceDate)} — '
            '${weekFmt.format(_intervalEnd ?? now)}',
    };
  }

  String _buildAdjacentLabel(int direction) {
    final DateFormat monthFmt = DateFormat('MMM yyyy', 'ru_RU');
    final DateFormat dayFmt = DateFormat('d MMM', 'ru_RU');
    final DateFormat yearFmt = DateFormat('yyyy');

    final DateTime adjacent = switch (_selectedPeriod) {
      TransactionPeriod.day => _referenceDate.add(Duration(days: direction)),
      TransactionPeriod.week => _referenceDate.add(
          Duration(days: direction * 7),
        ),
      TransactionPeriod.month => DateTime(
          _referenceDate.year,
          _referenceDate.month + direction,
          1,
        ),
      TransactionPeriod.year => DateTime(
          _referenceDate.year + direction,
          1,
          1,
        ),
      TransactionPeriod.all || TransactionPeriod.interval => _referenceDate,
    };

    return switch (_selectedPeriod) {
      TransactionPeriod.day => dayFmt.format(adjacent),
      TransactionPeriod.week => dayFmt.format(adjacent),
      TransactionPeriod.month => monthFmt.format(adjacent),
      TransactionPeriod.year => yearFmt.format(adjacent),
      TransactionPeriod.all || TransactionPeriod.interval => '',
    };
  }

  Future<void> _showIntervalPicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _intervalStart != null && _intervalEnd != null
          ? DateTimeRange(start: _intervalStart!, end: _intervalEnd!)
          : null,
      builder: (BuildContext context, Widget? child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (!mounted) {
      return;
    }
    if (picked != null) {
      setState(() {
        _intervalStart = picked.start;
        _intervalEnd = picked.end;
        _selectedPeriod = TransactionPeriod.interval;
      });
      context.read<TransactionBloc>().add(
        LoadTransactionsEvent(
          TransactionPeriod.interval,
          intervalStart: picked.start,
          intervalEnd: picked.end,
        ),
      );
    }
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

  void _navigatePeriod(int direction, DateTime oldestTransactionDate) {
    if (_selectedPeriod == TransactionPeriod.all ||
        _selectedPeriod == TransactionPeriod.interval) {
      return;
    }
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
      TransactionPeriod.year => DateTime(
          _referenceDate.year + direction,
          1,
          1,
        ),
      TransactionPeriod.all || TransactionPeriod.interval => _referenceDate,
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
    switch (_selectedPeriod) {
      case TransactionPeriod.day:
        _selectPeriod(TransactionPeriod.week);
      case TransactionPeriod.week:
        _selectPeriod(TransactionPeriod.month);
      case TransactionPeriod.month:
        _selectPeriod(TransactionPeriod.year);
      case TransactionPeriod.year:
        _selectPeriod(TransactionPeriod.all);
      case TransactionPeriod.all:
        _showIntervalPicker();
      case TransactionPeriod.interval:
        _selectPeriod(TransactionPeriod.day);
    }
  }

  void _selectPeriod(TransactionPeriod period) {
    if (period == TransactionPeriod.interval) {
      _showIntervalPicker();
      return;
    }
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
    required this.slotIndex,
    required this.categoryKey,
    required this.slot,
    required this.isCustom,
  });

  final int slotIndex;
  final String categoryKey;
  final _OrbitSlot slot;
  final bool isCustom;
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
