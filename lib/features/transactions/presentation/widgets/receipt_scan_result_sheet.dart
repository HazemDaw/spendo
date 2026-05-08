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
  late final List<TextEditingController> _itemAmountControllers;
  late List<ReceiptItemDraft> _items;
  late List<bool> _validItemAmounts;
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
    _items = List<ReceiptItemDraft>.of(widget.result.items, growable: true);
    _selectedItems = List<bool>.filled(
      _items.length,
      true,
      growable: true,
    );
    _itemNameControllers = _items
        .map((ReceiptItemDraft item) => TextEditingController(text: item.name))
        .toList();
    _itemAmountControllers = _items
        .map(
          (ReceiptItemDraft item) => TextEditingController(
            text: _formatAmount(item.amount),
          ),
        )
        .toList();
    _validItemAmounts = List<bool>.filled(
      _items.length,
      true,
      growable: true,
    );
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
    for (final TextEditingController controller in _itemAmountControllers) {
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
                _canAddSelectedItems ? () => _addSelectedItems(l10n) : null,
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
          for (int index = 0; index < _itemRowCount; index++)
            KeyedSubtree(
              key: ObjectKey(_itemNameControllers[index]),
              child: _buildItemRow(l10n, index),
            ),
        ],
      ),
    );
  }

  Widget _buildItemRow(AppLocalizations l10n, int index) {
    if (!_isValidItemIndex(index)) {
      return const SizedBox.shrink();
    }

    final ReceiptItemDraft item = _items[index];
    final Category? category = _categoryForKey(item.suggestedCategoryKey);
    final String currencySymbol = context.watch<CurrencyCubit>().state;
    final String categoryLabel = category == null
        ? l10n.scanUnknownCategory
        : CategoryLocalizer.label(l10n, category);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Checkbox(
            value: _selectedItems[index],
            onChanged: (bool? selected) {
              _updateItemSelection(index, selected ?? false);
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextField(
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
                    _updateItemName(index, value.trim());
                  },
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: InputChip(
                    avatar: Icon(
                      category?.icon ?? Icons.category_outlined,
                      size: 16,
                      color: category?.color ?? AppColors.textSecondary,
                    ),
                    label: Text(
                      categoryLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: () => _showItemCategoryPicker(index),
                    onDeleted: item.suggestedCategoryKey == null
                        ? null
                        : () => _clearItemCategory(index),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    deleteButtonTooltipMessage: l10n.deleteAction,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _showItemCategoryPicker(index),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: Text(l10n.pickCategoryAction),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              SizedBox(
                width: 116,
                child: TextField(
                  controller: _itemAmountControllers[index],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.end,
                  decoration: InputDecoration(
                    isDense: true,
                    suffixText: currencySymbol,
                    errorText: _validItemAmounts[index] ? null : '',
                    errorStyle: const TextStyle(fontSize: 0, height: 0),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  onChanged: (String value) {
                    _updateItemAmount(index, value);
                  },
                ),
              ),
              IconButton(
                tooltip: l10n.deleteAction,
                onPressed: () => _removeItem(index),
                icon: const Icon(Icons.close),
              ),
            ],
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

  Future<void> _showItemCategoryPicker(int itemIndex) async {
    if (!_isValidItemIndex(itemIndex)) {
      return;
    }

    final String? selectedCategoryKey = _items[itemIndex].suggestedCategoryKey;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return CategoryPickerSheet(
          selectedCategoryKey: selectedCategoryKey,
          onCategorySelected: (String categoryKey) {
            if (!mounted) {
              return;
            }
            _updateItemCategory(itemIndex, categoryKey);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _updateItemCategory(int itemIndex, String? categoryKey) {
    if (!_isValidItemIndex(itemIndex)) {
      return;
    }

    setState(() {
      if (!_isValidItemIndex(itemIndex)) {
        return;
      }

      final ReceiptItemDraft item = _items[itemIndex];
      _items[itemIndex] = ReceiptItemDraft(
        name: item.name,
        amount: item.amount,
        suggestedCategoryKey: categoryKey,
        confidence: item.confidence,
        sourceLine: item.sourceLine,
      );
    });
  }

  void _clearItemCategory(int itemIndex) {
    _updateItemCategory(itemIndex, null);
  }

  void _updateItemName(int itemIndex, String name) {
    if (!_isValidItemIndex(itemIndex)) {
      return;
    }

    setState(() {
      if (!_isValidItemIndex(itemIndex)) {
        return;
      }

      _items[itemIndex] = _items[itemIndex].copyWith(name: name);
    });
  }

  void _updateItemAmount(int itemIndex, String rawAmount) {
    if (!_isValidItemIndex(itemIndex)) {
      return;
    }

    final double? amount = double.tryParse(
      rawAmount.trim().replaceAll(',', '.'),
    );
    final bool isValid = amount != null && amount > 0;

    setState(() {
      if (!_isValidItemIndex(itemIndex)) {
        return;
      }

      _validItemAmounts[itemIndex] = isValid;
      if (isValid) {
        _items[itemIndex] = _items[itemIndex].copyWith(amount: amount);
      }
    });
  }

  void _updateItemSelection(int itemIndex, bool selected) {
    if (!_isValidItemIndex(itemIndex)) {
      return;
    }

    setState(() {
      if (!_isValidItemIndex(itemIndex)) {
        return;
      }

      _selectedItems[itemIndex] = selected;
    });
  }

  void _removeItem(int itemIndex) {
    if (!_isValidItemIndex(itemIndex)) {
      return;
    }

    setState(() {
      if (!_isValidItemIndex(itemIndex)) {
        return;
      }

      final TextEditingController controller =
          _itemNameControllers.removeAt(itemIndex);
      final TextEditingController amountController =
          _itemAmountControllers.removeAt(itemIndex);
      _items.removeAt(itemIndex);
      _selectedItems.removeAt(itemIndex);
      _validItemAmounts.removeAt(itemIndex);
      controller.dispose();
      amountController.dispose();
    });
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

    if (_hasInvalidSelectedItemAmount) {
      _showSnackBar(l10n.invalidAmountMessage);
      return;
    }

    final bool hasMissingCategory = selectedItems.any(
      (ReceiptItemDraft item) => item.suggestedCategoryKey == null,
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
            categoryKey: item.suggestedCategoryKey,
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

  bool _isValidItemIndex(int index) {
    return index >= 0 &&
        index < _items.length &&
        index < _selectedItems.length &&
        index < _itemNameControllers.length &&
        index < _itemAmountControllers.length &&
        index < _validItemAmounts.length;
  }

  int get _itemRowCount => <int>[
        _items.length,
        _selectedItems.length,
        _itemNameControllers.length,
        _itemAmountControllers.length,
        _validItemAmounts.length,
      ].reduce((int value, int element) => value < element ? value : element);

  List<ReceiptItemDraft> get _selectedReceiptItems {
    final List<ReceiptItemDraft> selectedItems = <ReceiptItemDraft>[];
    for (int index = 0; index < _itemRowCount; index++) {
      if (_selectedItems[index]) {
        selectedItems.add(_items[index]);
      }
    }
    return selectedItems;
  }

  int get _selectedItemCount {
    return _selectedItems
        .take(_itemRowCount)
        .where((bool value) => value)
        .length;
  }

  bool get _hasInvalidSelectedItemAmount {
    for (int index = 0; index < _itemRowCount; index++) {
      if (_selectedItems[index] && !_validItemAmounts[index]) {
        return true;
      }
    }
    return false;
  }

  bool get _canAddSelectedItems {
    return _selectedItemCount > 0 && !_hasInvalidSelectedItemAmount;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatAmount(double amount) {
    return amount % 1 == 0 ? amount.toInt().toString() : amount.toString();
  }
}
