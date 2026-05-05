import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/currency/currency_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/utils/category_localizer.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../categories/data/custom_category_access.dart';
import '../../../categories/data/custom_category_store.dart';
import '../../../categories/domain/entities/category.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/keypad_cubit.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/calculator_keypad.dart';
import '../../../categories/presentation/widgets/category_picker_sheet.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({
    super.key,
    required this.type,
    this.initialCategoryKey,
    this.transactionId,
  });

  final String type;
  final String? initialCategoryKey;
  final String? transactionId;

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final TextEditingController _noteController = TextEditingController();
  late final KeypadCubit _keypadCubit = KeypadCubit();
  final CustomCategoryStore? _categoryStore = maybeCustomCategoryStore();

  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryKey;
  Transaction? _editingTransaction;
  _PendingAction? _pendingAction;
  bool _didInitialize = false;

  bool get _isEditMode => widget.transactionId != null;

  TransactionType get _transactionType {
    if (_editingTransaction != null) {
      return _editingTransaction!.type;
    }

    return widget.type == 'income'
        ? TransactionType.income
        : TransactionType.expense;
  }

  bool get _requiresCategory => _transactionType == TransactionType.expense;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitialize) {
      return;
    }

    _categoryStore?.ensureLoaded();
    _selectedCategoryKey = widget.initialCategoryKey;
    if (_isEditMode) {
      final TransactionState state = context.read<TransactionBloc>().state;
      if (state is TransactionLoaded) {
        _initializeEditingTransaction(state.transactions);
      }
    }

    _didInitialize = true;
  }

  @override
  void dispose() {
    _noteController.dispose();
    _keypadCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final TransactionState transactionState = context.watch<TransactionBloc>().state;
    final bool isDark = context.watch<ThemeCubit>().state == ThemeMode.dark;
    final String currencySymbol = context.watch<CurrencyCubit>().state;
    final Category? category =
        _categoryStore?.resolveCategory(_selectedCategoryKey);
    final bool isResolvingEditTransaction =
        _isEditMode &&
        _editingTransaction == null &&
        (transactionState is TransactionInitial ||
            transactionState is TransactionLoading);
    final bool isMissingEditTransaction =
        _isEditMode &&
        _editingTransaction == null &&
        transactionState is TransactionLoaded;
    final bool canSubmit =
        _pendingAction == null && (!_isEditMode || _editingTransaction != null);

    return BlocListener<TransactionBloc, TransactionState>(
        listener: (BuildContext context, TransactionState state) {
          if (_isEditMode && state is TransactionLoaded) {
            _hydrateEditingTransaction(state.transactions);
          }

          if (_pendingAction == null) {
            return;
          }

          if (state is TransactionError &&
              (ModalRoute.of(context)?.isCurrent ?? false)) {
            setState(() {
              _pendingAction = null;
            });
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message)));
            return;
          }

          if (state is TransactionLoaded) {
            final _PendingAction action = _pendingAction!;
            final String result = switch (action) {
              _PendingAction.add => 'added',
              _PendingAction.update => 'updated',
              _PendingAction.delete => 'deleted',
            };
            if (action == _PendingAction.delete) {
              _pendingAction = null;
              context.pop(result);
              return;
            }

            _pendingAction = null;
            _showSuccessAndPop(result);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(_title(l10n)),
            actions: <Widget>[
              if (_isEditMode)
                IconButton(
                  onPressed:
                      _pendingAction == null && _editingTransaction != null
                      ? _confirmDelete
                      : null,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              TextButton(
                onPressed: canSubmit ? _save : null,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  l10n.saveAction,
                  style: const TextStyle(
                    inherit: true,
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: isResolvingEditTransaction
                ? const Center(child: CircularProgressIndicator())
                : isMissingEditTransaction
                ? _buildMissingTransactionState(l10n)
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: <Widget>[
                      _buildDateCard(context, l10n),
                      const SizedBox(height: 16),
                      _buildAmountCard(currencySymbol),
                      const SizedBox(height: 16),
                      _buildNoteField(l10n, isDark),
                      const SizedBox(height: 16),
                      CalculatorKeypad(onKeyTap: _keypadCubit.appendChar),
                      if (_requiresCategory) ...<Widget>[
                        const SizedBox(height: 24),
                        OutlinedButton(
                          onPressed: _showCategoryPicker,
                          child: Text(l10n.pickCategoryAction),
                        ),
                        if (category != null) ...<Widget>[
                          const SizedBox(height: 12),
                          Row(
                            children: <Widget>[
                              Icon(category.icon, color: category.color),
                              const SizedBox(width: 12),
                              Text(
                                CategoryLocalizer.label(l10n, category),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ],
                      ],
                      if (_pendingAction != null) ...<Widget>[
                        const SizedBox(height: 24),
                        const LinearProgressIndicator(),
                      ],
                    ],
                  ),
          ),
        ),
      );
  }

  Future<void> _showSuccessAndPop(String result) async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7C3AED),
          behavior: SnackBarBehavior.fixed,
          duration: const Duration(milliseconds: 1500),
          content: Row(
            children: <Widget>[
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.transactionSavedSuccessMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) {
      return;
    }

    context.pop(result);
  }

  Widget _buildMissingTransactionState(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Transaction unavailable',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.pop(),
              child: Text(l10n.cancelAction),
            ),
          ],
        ),
      ),
    );
  }

  void _initializeEditingTransaction(List<Transaction> transactions) {
    final Transaction? transaction = _findEditingTransaction(transactions);
    if (transaction == null) {
      return;
    }

    _editingTransaction = transaction;
    _selectedDate = transaction.date;
    _selectedCategoryKey = transaction.categoryKey;
    _noteController.text = transaction.note ?? '';
    _keypadCubit.setExpression(_formatInitialAmount(transaction.amount));
  }

  void _hydrateEditingTransaction(List<Transaction> transactions) {
    if (_editingTransaction != null) {
      return;
    }

    final Transaction? transaction = _findEditingTransaction(transactions);
    if (transaction == null || !mounted) {
      return;
    }

    setState(() {
      _initializeEditingTransaction(transactions);
    });
  }

  Transaction? _findEditingTransaction(List<Transaction> transactions) {
    for (final Transaction transaction in transactions) {
      if (transaction.id == widget.transactionId) {
        return transaction;
      }
    }

    return null;
  }

  Widget _buildDateCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: ListTile(
        onTap: _pickDate,
        leading: const Icon(Icons.calendar_today_outlined),
        title: Text(l10n.dateLabel),
        trailing: Text(
          DateFormat('d MMM yyyy', 'ru_RU').format(_selectedDate),
        ),
      ),
    );
  }

  Widget _buildAmountCard(String currencySymbol) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: BlocBuilder<KeypadCubit, String>(
          bloc: _keypadCubit,
          builder: (BuildContext context, String expression) {
            return Row(
              children: <Widget>[
                Text(
                  currencySymbol,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    expression.isEmpty ? '0' : expression,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _keypadCubit.backspace,
                  icon: const Icon(Icons.backspace_outlined),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoteField(AppLocalizations l10n, bool isDark) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: _noteController,
      keyboardType: TextInputType.text,
      keyboardAppearance: isDark ? Brightness.dark : Brightness.light,
      textInputAction: TextInputAction.done,
      enableSuggestions: true,
      autocorrect: false,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: l10n.noteLabel,
        prefixIcon: const Icon(Icons.edit_note_outlined),
        filled: true,
        fillColor: colorScheme.surface,
        labelStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('ru'),
    );
    if (!mounted || selected == null) {
      return;
    }

    setState(() {
      _selectedDate = selected;
    });
  }

  Future<void> _showCategoryPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return CategoryPickerSheet(
          selectedCategoryKey: _selectedCategoryKey,
          onCategorySelected: (String categoryKey) {
            setState(() {
              _selectedCategoryKey = categoryKey;
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<void> _confirmDelete() async {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.deleteTransactionTitle),
          content: Text(l10n.deleteTransactionMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancelAction),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.deleteAction),
            ),
          ],
        );
      },
    );

    if (confirmed != true || _editingTransaction == null || !mounted) {
      return;
    }

    setState(() {
      _pendingAction = _PendingAction.delete;
    });
    context
        .read<TransactionBloc>()
        .add(DeleteTransactionEvent(_editingTransaction!.id));
  }

  void _save() {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final double? amount = _keypadCubit.parseValue();
    if (amount == null || amount <= 0) {
      _showSnackBar(l10n.invalidAmountMessage);
      return;
    }

    if (_requiresCategory && _selectedCategoryKey == null) {
      _showSnackBar(l10n.invalidCategoryMessage);
      return;
    }

    final String note = _noteController.text.trim();
    final Transaction transaction = Transaction(
      id: _editingTransaction?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      amount: amount,
      categoryKey: _requiresCategory ? _selectedCategoryKey : null,
      type: _transactionType,
      date: _selectedDate,
      note: note.isEmpty ? null : note,
    );

    setState(() {
      _pendingAction =
          _isEditMode ? _PendingAction.update : _PendingAction.add;
    });

    context.read<TransactionBloc>().add(
          _isEditMode
              ? UpdateTransactionEvent(transaction)
              : AddTransactionEvent(transaction),
        );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _title(AppLocalizations l10n) {
    if (_isEditMode) {
      return l10n.editTransactionTitle;
    }

    return _transactionType == TransactionType.income
        ? l10n.addIncomeTitle
        : l10n.addExpenseTitle;
  }

  String _formatInitialAmount(double amount) {
    return amount % 1 == 0 ? amount.toInt().toString() : amount.toString();
  }
}

enum _PendingAction {
  add,
  update,
  delete,
}
