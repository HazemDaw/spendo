import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/currency/currency_cubit.dart';
import '../../../../core/mock/mock_data.dart';
import '../../../../core/services/receipt_scanner_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/category_localizer.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../categories/data/custom_category_access.dart';
import '../../../categories/data/custom_category_store.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/widgets/category_picker_sheet.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';

class ReceiptScanResultSheet extends StatefulWidget {
  const ReceiptScanResultSheet({
    super.key,
    required this.result,
  });

  final ReceiptScanResult result;

  @override
  State<ReceiptScanResultSheet> createState() => _ReceiptScanResultSheetState();
}

class _ReceiptScanResultSheetState extends State<ReceiptScanResultSheet> {
  final CustomCategoryStore? _categoryStore = maybeCustomCategoryStore();
  late final TextEditingController _amountController;
  late final List<TextEditingController> _itemNameControllers;
  late List<ReceiptItemDraft> _items;
  late List<bool> _selectedItems;
  late DateTime? _selectedDate;
  late String? _categoryKey;
  double? _amount;

  @override
  void initState() {
    super.initState();
    _categoryStore?.ensureLoaded();
    _selectedDate = widget.result.date;
    _categoryKey = widget.result.suggestedCategoryKey;
    _amount = widget.result.totalAmount;
    _items = List<ReceiptItemDraft>.of(widget.result.items);
    _selectedItems = List<bool>.filled(_items.length, true);
    _itemNameControllers = _items
        .map((ReceiptItemDraft item) => TextEditingController(text: item.name))
        .toList();
    _amountController = TextEditingController(
      text: _amount == null ? '' : _formatAmount(_amount!),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    for (final TextEditingController controller in _itemNameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.scanResultTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                if (widget.result.totalAmount != null || _items.isNotEmpty)
                  _buildReviewContent(context, l10n)
                else
                  _buildFailureContent(context, l10n),
                const SizedBox(height: 12),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(l10n.scanRawText),
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.result.rawText,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewContent(BuildContext context, AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Icon(Icons.check_circle, color: AppColors.income),
            const SizedBox(width: 10),
            Text(
              l10n.scanSuccess,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildAmountField(l10n),
                const SizedBox(height: 12),
                _buildDateTile(l10n),
                const SizedBox(height: 4),
                _buildCategoryTile(l10n),
              ],
            ),
          ),
        ),
        if (_items.isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          _buildItemsTile(l10n),
        ],
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: (_amount ?? 0) > 0 ? _openAddExpense : null,
          child: Text(l10n.scanAddSingleExpense),
        ),
        if (_items.isNotEmpty) ...<Widget>[
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed:
                _selectedItemCount > 0 ? () => _addSelectedItems(l10n) : null,
            child: Text(l10n.scanAddSelectedItems),
          ),
        ],
      ],
    );
  }

  Widget _buildFailureContent(BuildContext context, AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(
          Icons.receipt_long,
          color: AppColors.textSecondary,
          size: 48,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.scanFailure,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.scanFallbackHint,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: _openManualExpense,
          child: Text(l10n.addManually),
        ),
      ],
    );
  }

  Widget _buildAmountField(AppLocalizations l10n) {
    final String currencySymbol = context.watch<CurrencyCubit>().state;

    return TextField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: l10n.scanFinalTotalLabel,
        suffixText: currencySymbol,
      ),
      onChanged: (String value) {
        setState(() {
          _amount = double.tryParse(value.trim().replaceAll(',', '.'));
        });
      },
    );
  }

  Widget _buildDateTile(AppLocalizations l10n) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_today_outlined),
      title: Text(l10n.dateLabel),
      subtitle: Text(
        _selectedDate == null
            ? l10n.scanDateNotRecognized
            : DateFormat('dd.MM.yyyy').format(_selectedDate!),
      ),
      onTap: _pickDate,
    );
  }

  Widget _buildCategoryTile(AppLocalizations l10n) {
    final Category? category = _categoryForKey(_categoryKey);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        category?.icon ?? Icons.category_outlined,
        color: category?.color ?? AppColors.textSecondary,
      ),
      title: Text(l10n.exportCsvCategoryHeader),
      subtitle: Text(
        category == null
            ? l10n.scanUnknownCategory
            : CategoryLocalizer.label(l10n, category),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: _showCategoryPicker,
    );
  }

  Widget _buildItemsTile(AppLocalizations l10n) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(l10n.scanParsedItemsTitle),
        subtitle: Text(l10n.scanSelectedItemsCount(_selectedItemCount)),
        children: <Widget>[
          for (int index = 0; index < _items.length; index++)
            _buildItemRow(l10n, index),
        ],
      ),
    );
  }

  Widget _buildItemRow(AppLocalizations l10n, int index) {
    final ReceiptItemDraft item = _items[index];
    final Category? category = _categoryForKey(item.suggestedCategoryKey);
    final String currencySymbol = context.watch<CurrencyCubit>().state;

    return CheckboxListTile(
      value: _selectedItems[index],
      onChanged: (bool? selected) {
        setState(() {
          _selectedItems[index] = selected ?? false;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.only(left: 4, right: 4),
      title: TextField(
        controller: _itemNameControllers[index],
        minLines: 1,
        maxLines: 2,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        style: Theme.of(context).textTheme.bodyMedium,
        onChanged: (String value) {
          _items[index] = _items[index].copyWith(name: value.trim());
        },
      ),
      subtitle: Text(
        category == null
            ? l10n.scanUnknownCategory
            : CategoryLocalizer.label(l10n, category),
      ),
      secondary: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '${_formatAmount(item.amount)} $currencySymbol',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          IconButton(
            tooltip: l10n.deleteAction,
            onPressed: () {
              setState(() {
                _itemNameControllers.removeAt(index).dispose();
                _items.removeAt(index);
                _selectedItems.removeAt(index);
              });
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime initialDate = _selectedDate ?? DateTime.now();
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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
          selectedCategoryKey: _categoryKey,
          onCategorySelected: (String categoryKey) {
            if (!mounted) {
              return;
            }
            setState(() {
              _categoryKey = categoryKey;
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _openAddExpense() {
    final GoRouter router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.pushNamed(
      'addTransaction',
      queryParameters: <String, String>{
        'type': 'expense',
        if (_categoryKey != null) 'categoryKey': _categoryKey!,
        'amount': _formatAmount(_amount ?? 0),
        'date': _selectedDate?.toIso8601String() ?? '',
      },
    );
  }

  Future<void> _addSelectedItems(AppLocalizations l10n) async {
    final List<ReceiptItemDraft> selectedItems = _selectedReceiptItems;
    if (selectedItems.isEmpty) {
      _showSnackBar(l10n.scanNoItemsSelected);
      return;
    }

    final bool hasMissingCategory = selectedItems.any(
      (ReceiptItemDraft item) =>
          (item.suggestedCategoryKey ?? _categoryKey) == null,
    );
    if (hasMissingCategory) {
      _showSnackBar(l10n.invalidCategoryMessage);
      return;
    }

    final String total = _formatAmount(
      selectedItems.fold<double>(
        0,
        (double sum, ReceiptItemDraft item) => sum + item.amount,
      ),
    );
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.scanConfirmSelectedItemsTitle),
          content: Text(
            l10n.scanConfirmSelectedItemsMessage(
              selectedItems.length,
              total,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancelAction),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.saveAction),
            ),
          ],
        );
      },
    );
    if (!mounted || confirmed != true) {
      return;
    }

    final TransactionBloc bloc = context.read<TransactionBloc>();
    final DateTime date = _selectedDate ?? DateTime.now();
    final int idBase = DateTime.now().microsecondsSinceEpoch;
    for (int index = 0; index < selectedItems.length; index++) {
      final ReceiptItemDraft item = selectedItems[index];
      bloc.add(
        AddTransactionEvent(
          Transaction(
            id: '${idBase}_receipt_$index',
            amount: item.amount,
            categoryKey: item.suggestedCategoryKey ?? _categoryKey,
            type: TransactionType.expense,
            date: date,
            note: item.name,
          ),
        ),
      );
    }

    Navigator.of(context).pop();
  }

  void _openManualExpense() {
    final GoRouter router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.pushNamed(
      'addTransaction',
      queryParameters: const <String, String>{'type': 'expense'},
    );
  }

  Category? _categoryForKey(String? key) {
    return _categoryStore?.resolveCategory(key) ?? MockData.categoryByKey(key);
  }

  List<ReceiptItemDraft> get _selectedReceiptItems {
    final List<ReceiptItemDraft> selectedItems = <ReceiptItemDraft>[];
    for (int index = 0; index < _items.length; index++) {
      if (_selectedItems[index]) {
        selectedItems.add(_items[index]);
      }
    }
    return selectedItems;
  }

  int get _selectedItemCount =>
      _selectedItems.where((bool value) => value).length;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatAmount(double amount) {
    return amount % 1 == 0 ? amount.toInt().toString() : amount.toString();
  }
}
