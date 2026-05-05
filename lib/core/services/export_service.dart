import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/transactions/domain/entities/transaction.dart';
import '../mock/mock_data.dart';
import '../utils/currency_formatter.dart';

class ExportService {
  static const PdfColor _violet = PdfColor.fromInt(0xFF7C3AED);
  static const PdfColor _green = PdfColor.fromInt(0xFF10B981);
  static const PdfColor _red = PdfColor.fromInt(0xFFEF4444);
  static const PdfColor _muted = PdfColor.fromInt(0xFF6B7280);
  static const PdfColor _line = PdfColor.fromInt(0xFFE5E7EB);

  Future<File> exportCsv(
    List<Transaction> transactions, {
    String locale = 'ru',
  }) async {
    final bool isRu = locale == 'ru';
    final String dateHeader = isRu ? 'Дата' : 'Date';
    final String typeHeader = isRu ? 'Тип' : 'Type';
    final String categoryHeader = isRu ? 'Категория' : 'Category';
    final String amountHeader = isRu ? 'Сумма' : 'Amount';
    final String noteHeader = isRu ? 'Примечание' : 'Note';
    final String expenseType = isRu ? 'Расход' : 'Expense';
    final String incomeType = isRu ? 'Доход' : 'Income';
    final String dateLocale = isRu ? 'ru_RU' : 'en_US';

    final List<List<String>> rows = <List<String>>[
      <String>[
        dateHeader,
        typeHeader,
        categoryHeader,
        amountHeader,
        noteHeader,
      ],
      ...transactions.map(
        (Transaction t) => <String>[
          DateFormat('dd.MM.yyyy', dateLocale).format(t.date),
          t.type == TransactionType.expense ? expenseType : incomeType,
          t.categoryKey ?? incomeType,
          t.amount.toStringAsFixed(2),
          t.note ?? '',
        ],
      ),
    ];

    final String actualCsv = const ListToCsvConverter().convert(rows);
    final String csvWithSep = 'sep=,\n$actualCsv';

    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File('${dir.path}/spendo_export.csv');
    final List<int> bytes = utf8.encode(csvWithSep);
    final List<int> bom = <int>[0xEF, 0xBB, 0xBF];

    await file.writeAsBytes(bom + bytes);
    return file;
  }

  Future<File> exportPdf(
    List<Transaction> transactions,
    double totalIncome,
    double totalExpense, {
    String locale = 'ru',
    String periodLabel = '',
    required String currencySymbol,
  }) async {
    final bool isRu = locale == 'ru';
    final String dateLocale = isRu ? 'ru_RU' : 'en_US';
    final String effectivePeriodLabel = periodLabel.isEmpty
        ? DateFormat('LLLL yyyy', dateLocale).format(DateTime.now())
        : periodLabel;
    final pw.Document doc = pw.Document();

    final ByteData fontData =
        await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final pw.Font ttf = pw.Font.ttf(fontData);
    final List<_CategoryExpenseSummary> categoryBreakdown =
        _buildCategoryBreakdown(transactions, totalExpense, locale);
    final List<_TransactionGroup> transactionGroups =
        _buildTransactionGroups(transactions, locale);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
        build: (pw.Context context) => <pw.Widget>[
          _buildHeader(effectivePeriodLabel),
          _divider(),
          _buildSummarySection(
            incomeLabel: isRu ? 'Доходы' : 'Total Income',
            expenseLabel: isRu ? 'Расходы' : 'Total Expenses',
            balanceLabel: isRu ? 'Баланс' : 'Balance',
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            currencySymbol: currencySymbol,
          ),
          _divider(),
          _buildCategoryBreakdownTable(
            title: isRu ? 'Расходы по категориям' : 'Category Breakdown',
            categoryHeader: isRu ? 'Категория' : 'Category name',
            amountHeader: isRu ? 'Сумма' : 'Amount',
            percentHeader: isRu ? '% от расходов' : '% of total expenses',
            rows: categoryBreakdown,
            currencySymbol: currencySymbol,
          ),
          _divider(),
          _buildTransactionList(
            title: isRu ? 'Список транзакций' : 'Transaction List',
            dateLocale: dateLocale,
            groups: transactionGroups,
            currencySymbol: currencySymbol,
          ),
        ],
      ),
    );

    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File('${dir.path}/spendo_export.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  pw.Widget _buildHeader(String periodLabel) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(
          'Spendo',
          style: pw.TextStyle(
            color: _violet,
            fontSize: 34,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          periodLabel,
          style: const pw.TextStyle(
            color: _muted,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSummarySection({
    required String incomeLabel,
    required String expenseLabel,
    required String balanceLabel,
    required double totalIncome,
    required double totalExpense,
    required String currencySymbol,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 14),
      child: pw.Row(
        children: <pw.Widget>[
          _summaryValue(
            label: incomeLabel,
            value: CurrencyFormatter.format(
              totalIncome,
              symbol: currencySymbol,
            ),
            color: _green,
          ),
          pw.SizedBox(width: 16),
          _summaryValue(
            label: expenseLabel,
            value: CurrencyFormatter.format(
              totalExpense,
              symbol: currencySymbol,
            ),
            color: _red,
          ),
          pw.SizedBox(width: 16),
          _summaryValue(
            label: balanceLabel,
            value: CurrencyFormatter.format(
              totalIncome - totalExpense,
              symbol: currencySymbol,
            ),
            color: _violet,
          ),
        ],
      ),
    );
  }

  pw.Widget _summaryValue({
    required String label,
    required String value,
    required PdfColor color,
  }) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Text(
            label,
            style: const pw.TextStyle(
              color: _muted,
              fontSize: 9,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            value,
            style: pw.TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCategoryBreakdownTable({
    required String title,
    required String categoryHeader,
    required String amountHeader,
    required String percentHeader,
    required List<_CategoryExpenseSummary> rows,
    required String currencySymbol,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        if (rows.isNotEmpty)
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: _line),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: const <int, pw.Alignment>{
              1: pw.Alignment.centerRight,
              2: pw.Alignment.centerRight,
            },
            headers: <String>[categoryHeader, amountHeader, percentHeader],
            data: rows
                .map(
                  (_CategoryExpenseSummary row) => <String>[
                    row.categoryName,
                    CurrencyFormatter.format(
                      row.amount,
                      symbol: currencySymbol,
                    ),
                    row.percentLabel,
                  ],
                )
                .toList(),
          ),
      ],
    );
  }

  pw.Widget _buildTransactionList({
    required String title,
    required String dateLocale,
    required List<_TransactionGroup> groups,
    required String currencySymbol,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        ...groups.map(
          (_TransactionGroup group) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text(
                group.categoryName,
                style: pw.TextStyle(
                  color: _violet,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Table(
                columnWidths: const <int, pw.TableColumnWidth>{
                  0: pw.FixedColumnWidth(88),
                  1: pw.FlexColumnWidth(),
                  2: pw.FixedColumnWidth(96),
                },
                children: group.transactions
                    .map(
                      (Transaction transaction) => pw.TableRow(
                        children: <pw.Widget>[
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 6),
                            child: pw.Text(
                              DateFormat.yMMMd(dateLocale)
                                  .format(transaction.date),
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 6),
                            child: pw.Text(
                              transaction.note?.trim().isNotEmpty == true
                                  ? transaction.note!.trim()
                                  : '—',
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(bottom: 6),
                            child: pw.Align(
                              alignment: pw.Alignment.centerRight,
                              child: pw.Text(
                                CurrencyFormatter.format(
                                  transaction.amount,
                                  symbol: currencySymbol,
                                ),
                                style: pw.TextStyle(
                                  color: transaction.type ==
                                          TransactionType.expense
                                      ? _red
                                      : _green,
                                  fontSize: 9,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
              pw.SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  List<_CategoryExpenseSummary> _buildCategoryBreakdown(
    List<Transaction> transactions,
    double totalExpense,
    String locale,
  ) {
    final Map<String, double> categoryTotals = <String, double>{};
    for (final Transaction t in transactions) {
      if (t.type != TransactionType.expense || t.categoryKey == null) {
        continue;
      }
      categoryTotals.update(
        t.categoryKey!,
        (double amount) => amount + t.amount,
        ifAbsent: () => t.amount,
      );
    }

    final NumberFormat percentFormatter = NumberFormat.decimalPattern(
      locale == 'ru' ? 'ru_RU' : 'en_US',
    );
    final List<_CategoryExpenseSummary> rows = categoryTotals.entries
        .map(
          (MapEntry<String, double> entry) {
            final double percent =
                totalExpense <= 0 ? 0 : (entry.value / totalExpense) * 100;
            return _CategoryExpenseSummary(
              categoryName: _categoryName(entry.key, locale),
              amount: entry.value,
              percentLabel: '${percentFormatter.format(percent)}%',
            );
          },
        )
        .toList();

    rows.sort(
      (_CategoryExpenseSummary a, _CategoryExpenseSummary b) =>
          b.amount.compareTo(a.amount),
    );
    return rows;
  }

  List<_TransactionGroup> _buildTransactionGroups(
    List<Transaction> transactions,
    String locale,
  ) {
    final Map<String, List<Transaction>> grouped = <String, List<Transaction>>{};
    for (final Transaction transaction in transactions) {
      final String key = transaction.type == TransactionType.income
          ? 'income'
          : (transaction.categoryKey ?? 'uncategorized');
      grouped.putIfAbsent(key, () => <Transaction>[]).add(transaction);
    }

    final List<_TransactionGroup> groups = grouped.entries
        .map(
          (MapEntry<String, List<Transaction>> entry) {
            final List<Transaction> groupTransactions =
                List<Transaction>.from(entry.value)
                  ..sort(
                    (Transaction a, Transaction b) => b.date.compareTo(a.date),
                  );
            return _TransactionGroup(
              categoryName: entry.key == 'income'
                  ? (locale == 'ru' ? 'Доходы' : 'Income')
                  : _categoryName(entry.key, locale),
              total: groupTransactions.fold<double>(
                0,
                (double sum, Transaction transaction) =>
                    sum + transaction.amount,
              ),
              transactions: groupTransactions,
            );
          },
        )
        .toList();

    groups.sort(
      (_TransactionGroup a, _TransactionGroup b) => b.total.compareTo(a.total),
    );
    return groups;
  }

  String _categoryName(String categoryKey, String locale) {
    final category = MockData.categoryByKey(categoryKey);
    if (category == null) {
      return categoryKey;
    }

    return switch (category.labelKey) {
      'categoryFood' => locale == 'ru' ? 'Еда и продукты' : 'Food & Groceries',
      'categoryTransport' => locale == 'ru' ? 'Транспорт' : 'Transport',
      'categoryHousing' => locale == 'ru' ? 'Жилье' : 'Housing',
      'categoryHealth' => locale == 'ru' ? 'Здоровье' : 'Health',
      'categoryClothing' => locale == 'ru' ? 'Одежда' : 'Clothing',
      'categoryEntertainment' => locale == 'ru'
          ? 'Развлечения'
          : 'Entertainment',
      'categoryCommunication' => locale == 'ru' ? 'Связь' : 'Communication',
      'categoryPets' => locale == 'ru' ? 'Питомцы' : 'Pets',
      'categoryGifts' => locale == 'ru' ? 'Подарки' : 'Gifts',
      'categorySport' => locale == 'ru' ? 'Спорт' : 'Sport',
      _ => category.labelKey,
    };
  }

  pw.Widget _divider() {
    return pw.Container(
      height: 1,
      margin: const pw.EdgeInsets.symmetric(vertical: 16),
      color: _line,
    );
  }
}

class _CategoryExpenseSummary {
  const _CategoryExpenseSummary({
    required this.categoryName,
    required this.amount,
    required this.percentLabel,
  });

  final String categoryName;
  final double amount;
  final String percentLabel;
}

class _TransactionGroup {
  const _TransactionGroup({
    required this.categoryName,
    required this.total,
    required this.transactions,
  });

  final String categoryName;
  final double total;
  final List<Transaction> transactions;
}
