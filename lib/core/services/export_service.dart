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

class ExportService {
  // CSV Export
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

  // PDF Export
  Future<File> exportPdf(
    List<Transaction> transactions,
    double totalIncome,
    double totalExpense, {
    String locale = 'ru',
  }) async {
    final bool isRu = locale == 'ru';
    final String reportTitle = isRu
        ? 'Spendo — Отчет о расходах'
        : 'Spendo — Expense Report';
    final String generatedLbl = isRu ? 'Сформирован' : 'Generated';
    final String incomeLbl = isRu ? 'Доходы' : 'Income';
    final String expenseLbl = isRu ? 'Расходы' : 'Expenses';
    final String balanceLbl = isRu ? 'Баланс' : 'Balance';
    final String dateHeader = isRu ? 'Дата' : 'Date';
    final String amountHeader = isRu ? 'Сумма' : 'Amount';
    final String noteHeader = isRu ? 'Примечание' : 'Note';
    final String dateLocale = isRu ? 'ru_RU' : 'en_US';
    final pw.Document doc = pw.Document();

    final ByteData fontData =
        await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final pw.Font ttf = pw.Font.ttf(fontData);

    final Map<String, List<Transaction>> grouped = <String, List<Transaction>>{};
    for (final Transaction t in transactions) {
      final String key = t.categoryKey ?? 'income';
      grouped.putIfAbsent(key, () => <Transaction>[]).add(t);
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: ttf),
        build: (pw.Context context) => <pw.Widget>[
          pw.Header(
            level: 0,
            child: pw.Text(
              reportTitle,
              style: const pw.TextStyle(fontSize: 24),
            ),
          ),
          pw.Text(
            '$generatedLbl: ${DateFormat('dd MMMM yyyy', dateLocale).format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(border: pw.Border.all()),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: <pw.Widget>[
                pw.Text(
                  '$incomeLbl: ${totalIncome.toStringAsFixed(2)} ₽',
                  style: const pw.TextStyle(color: PdfColors.green),
                ),
                pw.Text(
                  '$expenseLbl: ${totalExpense.toStringAsFixed(2)} ₽',
                  style: const pw.TextStyle(color: PdfColors.red),
                ),
                pw.Text(
                  '$balanceLbl: ${(totalIncome - totalExpense).toStringAsFixed(2)} ₽',
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
          ...grouped.entries.map(
            (MapEntry<String, List<Transaction>> entry) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Text(
                  entry.key,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.TableHelper.fromTextArray(
                  headers: <String>[dateHeader, amountHeader, noteHeader],
                  data: entry.value
                      .map(
                        (Transaction t) => <String>[
                          DateFormat('dd.MM.yyyy', dateLocale).format(t.date),
                          '${t.amount.toStringAsFixed(2)} ₽',
                          t.note ?? '—',
                        ],
                      )
                      .toList(),
                ),
                pw.SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );

    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File('${dir.path}/spendo_export.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }
}
