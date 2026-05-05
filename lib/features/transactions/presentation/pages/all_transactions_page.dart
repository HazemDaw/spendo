import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/currency/currency_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/category_localizer.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../categories/data/custom_category_access.dart';
import '../../../categories/domain/entities/category.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_state.dart';
import '../widgets/transaction_delete_undo_snackbar.dart';
import '../widgets/transaction_list_item.dart';

class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({
    super.key,
    required this.initialTransactions,
  });

  final List<Transaction> initialTransactions;

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  static const String _incomeSectionKey = '__income__';
  static const Color _filterColor = Color(0xFF7C3AED);

  _TransactionTypeFilter _typeFilter = _TransactionTypeFilter.all;
  String? _selectedCategoryKey;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String currencySymbol = context.watch<CurrencyCubit>().state;

    return BlocListener<TransactionBloc, TransactionState>(
      listener: (BuildContext context, TransactionState state) {
        if (state is TransactionError &&
            (ModalRoute.of(context)?.isCurrent ?? false)) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(l10n.allTransactionsTitle),
          actions: <Widget>[
            IconButton(
              tooltip: l10n.searchTransactionsHint,
              icon: const Icon(Icons.search),
              onPressed: () {
                final TransactionState state =
                    context.read<TransactionBloc>().state;
                final List<Transaction> transactions =
                    state is TransactionLoaded
                        ? state.transactions
                        : widget.initialTransactions;

                showSearch<Transaction?>(
                  context: context,
                  delegate: _TransactionSearchDelegate(
                    l10n: l10n,
                    transactions: transactions,
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (BuildContext context, TransactionState state) {
            final List<Transaction> transactions = state is TransactionLoaded
                ? state.transactions
                : widget.initialTransactions;
            final List<Transaction> typeFilteredTransactions =
                _applyTypeFilter(transactions);
            final List<String> categoryKeys = _categoryKeys(
              l10n,
              typeFilteredTransactions,
            );
            final String? effectiveCategoryKey =
                categoryKeys.contains(_selectedCategoryKey)
                    ? _selectedCategoryKey
                    : null;
            final List<Transaction> filteredTransactions =
                _applyCategoryFilter(
              typeFilteredTransactions,
              effectiveCategoryKey,
            );
            final List<_CategorySection> sections = _buildSections(
              l10n,
              filteredTransactions,
            );

            return Column(
              children: <Widget>[
                _buildFilterRows(
                  l10n: l10n,
                  categoryKeys: categoryKeys,
                  selectedCategoryKey: effectiveCategoryKey,
                ),
                Expanded(
                  child: sections.isEmpty
                      ? _FilteredEmptyState(l10n: l10n)
                      : _CategorySectionList(
                          sections: sections,
                          currencySymbol: currencySymbol,
                          onTransactionTap: _openTransaction,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterRows({
    required AppLocalizations l10n,
    required List<String> categoryKeys,
    required String? selectedCategoryKey,
  }) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _TransactionTypeFilter.values
                  .map(
                    (_TransactionTypeFilter filter) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _FilterChip(
                        label: _typeFilterLabel(filter, l10n),
                        selected: _typeFilter == filter,
                        onSelected: () {
                          setState(() {
                            _typeFilter = filter;
                            _selectedCategoryKey = null;
                          });
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: l10n.allTransactionsAllCategoriesFilter,
                    selected: selectedCategoryKey == null,
                    onSelected: () {
                      setState(() {
                        _selectedCategoryKey = null;
                      });
                    },
                  ),
                ),
                ...categoryKeys.map(
                  (String categoryKey) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: _categoryLabel(categoryKey, l10n),
                      selected: selectedCategoryKey == categoryKey,
                      onSelected: () {
                        setState(() {
                          _selectedCategoryKey = categoryKey;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _typeFilterLabel(
    _TransactionTypeFilter filter,
    AppLocalizations l10n,
  ) {
    return switch (filter) {
      _TransactionTypeFilter.all => l10n.allTransactionsAllFilter,
      _TransactionTypeFilter.income => l10n.incomeLabel,
      _TransactionTypeFilter.expense => l10n.expenseLabel,
    };
  }

  List<Transaction> _applyTypeFilter(List<Transaction> transactions) {
    return switch (_typeFilter) {
      _TransactionTypeFilter.all => transactions,
      _TransactionTypeFilter.income => transactions
          .where(
            (Transaction transaction) =>
                transaction.type == TransactionType.income,
          )
          .toList(growable: false),
      _TransactionTypeFilter.expense => transactions
          .where(
            (Transaction transaction) =>
                transaction.type == TransactionType.expense,
          )
          .toList(growable: false),
    };
  }

  List<Transaction> _applyCategoryFilter(
    List<Transaction> transactions,
    String? categoryKey,
  ) {
    if (categoryKey == null) {
      return transactions;
    }

    return transactions
        .where(
          (Transaction transaction) => transaction.categoryKey == categoryKey,
        )
        .toList(growable: false);
  }

  List<String> _categoryKeys(
    AppLocalizations l10n,
    List<Transaction> transactions,
  ) {
    final Set<String> keys = <String>{};

    for (final Transaction transaction in transactions) {
      final String? categoryKey = transaction.categoryKey;
      if (categoryKey != null) {
        keys.add(categoryKey);
      }
    }

    return keys.toList()
      ..sort(
        (String a, String b) =>
            _categoryLabel(a, l10n).compareTo(_categoryLabel(b, l10n)),
      );
  }

  String _categoryLabel(String categoryKey, AppLocalizations l10n) {
    final Category? category =
        maybeCustomCategoryStore()?.resolveCategory(categoryKey);

    return category == null
        ? categoryKey
        : CategoryLocalizer.label(l10n, category);
  }

  List<_CategorySection> _buildSections(
    AppLocalizations l10n,
    List<Transaction> transactions,
  ) {
    final Map<String, List<Transaction>> transactionsBySection =
        <String, List<Transaction>>{};

    for (final Transaction transaction in transactions) {
      final String sectionKey = transaction.categoryKey ?? _incomeSectionKey;
      transactionsBySection.putIfAbsent(sectionKey, () => <Transaction>[]);
      transactionsBySection[sectionKey]!.add(transaction);
    }

    final List<_CategorySection> sections = transactionsBySection.entries.map(
      (MapEntry<String, List<Transaction>> entry) {
        final bool isIncome = entry.key == _incomeSectionKey;
        final List<Transaction> sectionTransactions = List<Transaction>.from(
          entry.value,
        )..sort(
            (Transaction a, Transaction b) => b.date.compareTo(a.date),
          );
        final double total = sectionTransactions.fold<double>(
          0,
          (double sum, Transaction transaction) => sum + transaction.amount,
        );

        if (isIncome) {
          return _CategorySection(
            title: l10n.incomeSectionTitle,
            icon: Icons.arrow_upward,
            iconColor: AppColors.income,
            isIncome: true,
            total: total,
            transactions: sectionTransactions,
          );
        }

        final Category? category =
            maybeCustomCategoryStore()?.resolveCategory(entry.key);

        return _CategorySection(
          title: category == null
              ? entry.key
              : CategoryLocalizer.label(l10n, category),
          icon: category?.icon ?? Icons.payments_outlined,
          iconColor: category?.color ?? AppColors.primary,
          isIncome: false,
          total: total,
          transactions: sectionTransactions,
        );
      },
    ).toList()
      ..sort(
        (_CategorySection a, _CategorySection b) =>
            b.total.abs().compareTo(a.total.abs()),
      );

    return sections;
  }

  Future<void> _openTransaction(Transaction transaction) async {
    final Object? result = await context.pushNamed(
      'editTransaction',
      pathParameters: <String, String>{
        'transactionId': transaction.id,
      },
    );
    if (!mounted) {
      return;
    }
    _showResult(result, transaction);
  }

  void _showResult(Object? result, Transaction fallbackTransaction) {
    final Transaction? deletedTransaction = switch (result) {
      TransactionDeleteResult(:final transaction) => transaction,
      'deleted' => fallbackTransaction,
      _ => null,
    };
    if (deletedTransaction != null) {
      showTransactionDeletedUndoSnackBar(context, deletedTransaction);
    }
  }
}

class _CategorySectionList extends StatelessWidget {
  const _CategorySectionList({
    required this.sections,
    required this.currencySymbol,
    required this.onTransactionTap,
  });

  final List<_CategorySection> sections;
  final String currencySymbol;
  final ValueChanged<Transaction> onTransactionTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: sections.length,
      separatorBuilder: (_, __) => const Divider(height: 32),
      itemBuilder: (BuildContext context, int index) {
        final _CategorySection section = sections[index];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Row(
                children: <Widget>[
                  Icon(section.icon, color: section.iconColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      section.title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    CurrencyFormatter.format(
                      section.total,
                      symbol: currencySymbol,
                    ),
                    style: TextStyle(
                      color: section.isIncome
                          ? AppColors.income
                          : AppColors.expense,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...section.transactions.map(
              (Transaction transaction) => TransactionListItem(
                transaction: transaction,
                onTap: () => onTransactionTap(transaction),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      showCheckmark: false,
      selected: selected,
      label: Text(label),
      labelStyle: TextStyle(
        color: selected ? Colors.white : _AllTransactionsPageState._filterColor,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      selectedColor: _AllTransactionsPageState._filterColor,
      backgroundColor: Colors.transparent,
      side: const BorderSide(color: _AllTransactionsPageState._filterColor),
      shape: const StadiumBorder(),
      onSelected: (_) => onSelected(),
    );
  }
}

class _FilteredEmptyState extends StatelessWidget {
  const _FilteredEmptyState({
    required this.l10n,
  });

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noTransactions,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.allTransactionsTryChangingFilters,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySection {
  const _CategorySection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.isIncome,
    required this.total,
    required this.transactions,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final bool isIncome;
  final double total;
  final List<Transaction> transactions;
}

enum _TransactionTypeFilter {
  all,
  income,
  expense,
}

class _TransactionSearchDelegate extends SearchDelegate<Transaction?> {
  _TransactionSearchDelegate({
    required this.l10n,
    required this.transactions,
  });

  final AppLocalizations l10n;
  final List<Transaction> transactions;

  @override
  String get searchFieldLabel => l10n.searchTransactionsHint;

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
    }).toList()
      ..sort((Transaction a, Transaction b) => b.date.compareTo(a.date));

    if (results.isEmpty) {
      return Center(child: Text(l10n.nothingFound));
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
