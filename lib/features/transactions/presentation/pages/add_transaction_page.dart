import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/mock/mock_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/category_localizer.dart';
import '../../../../l10n/app_localizations.dart';
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

    _selectedCategoryKey = widget.initialCategoryKey;
    if (_isEditMode) {
      final TransactionState state = context.read<TransactionBloc>().state;
      if (state is TransactionLoaded) {
        for (final Transaction transaction in state.transactions) {
          if (transaction.id == widget.transactionId) {
            _editingTransaction = transaction;
            break;
          }
        }
      }

      if (_editingTransaction != null) {
        _selectedDate = _editingTransaction!.date;
        _selectedCategoryKey = _editingTransaction!.categoryKey;
        _noteController.text = _editingTransaction!.note ?? '';
        _keypadCubit.setExpression(_formatInitialAmount(_editingTransaction!.amount));
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
    final category = MockData.categoryByKey(_selectedCategoryKey);

    return BlocProvider<KeypadCubit>.value(
      value: _keypadCubit,
      child: BlocListener<TransactionBloc, TransactionState>(
        listener: (BuildContext context, TransactionState state) {
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
            final String result = switch (_pendingAction!) {
              _PendingAction.add => 'added',
              _PendingAction.update => 'updated',
              _PendingAction.delete => 'deleted',
            };
            _pendingAction = null;
            context.pop(result);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(_title(l10n)),
            actions: <Widget>[
              if (_isEditMode)
                IconButton(
                  onPressed: _pendingAction == null ? _confirmDelete : null,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              TextButton(
                onPressed: _pendingAction == null ? _save : null,
                child: Text(l10n.saveAction),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: <Widget>[
                _buildDateCard(context, l10n),
                const SizedBox(height: 16),
                _buildAmountCard(),
                const SizedBox(height: 16),
                _buildNoteField(l10n),
                const SizedBox(height: 16),
                CalculatorKeypad(
                  onKeyTap: (String value) {
                    context.read<KeypadCubit>().appendChar(value);
                  },
                ),
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
      ),
    );
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

  Widget _buildAmountCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: BlocBuilder<KeypadCubit, String>(
          builder: (BuildContext context, String expression) {
            return Row(
              children: <Widget>[
                const Text(
                  '₽',
                  style: TextStyle(
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
                  onPressed: () => context.read<KeypadCubit>().backspace(),
                  icon: const Icon(Icons.backspace_outlined),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoteField(AppLocalizations l10n) {
    return TextField(
      controller: _noteController,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: l10n.noteLabel,
        prefixIcon: const Icon(Icons.edit_note_outlined),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
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
