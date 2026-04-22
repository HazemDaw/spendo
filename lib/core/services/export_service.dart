import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle; // مهم من أجل تحميل الخط

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/transactions/domain/entities/transaction.dart';

class ExportService {
  // CSV Export
  Future<File> exportCsv(List<Transaction> transactions) async {
    final List<List<String>> rows = <List<String>>[
      // Header row
      <String>['Дата', 'Тип', 'Категория', 'Сумма', 'Примечание'],
      // Data rows
      ...transactions.map(
        (Transaction t) => <String>[
          DateFormat('dd.MM.yyyy', 'ru_RU').format(t.date),
          t.type == TransactionType.expense ? 'Расход' : 'Доход',
          t.categoryKey ?? 'Доход',
          t.amount.toStringAsFixed(2),
          t.note ?? '',
        ],
      ),
    ];

    final String actualCsv = const ListToCsvConverter().convert(rows);
    
    // إضافة سطر الفاصلة ليقرأه الإكسل بشكل صحيح في روسيا وأوروبا
    final String csvWithSep = "sep=,\n$actualCsv"; 
    
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File('${dir.path}/spendo_export.csv');
    
    // تحويل النص إلى بايتات مع إضافة الـ BOM لدعم اللغة الروسية والعربية
    final List<int> bytes = utf8.encode(csvWithSep);
    final List<int> bom = <int>[0xEF, 0xBB, 0xBF];
    
    await file.writeAsBytes(bom + bytes);
    return file;
  }

  // PDF Export
  Future<File> exportPdf(
    List<Transaction> transactions,
    double totalIncome,
    double totalExpense,
  ) async {
    final pw.Document doc = pw.Document();

    // تحميل الخط الذي يدعم اللغة الروسية
    final ByteData fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final pw.Font ttf = pw.Font.ttf(fontData);

    // Group transactions by category
    final Map<String, List<Transaction>> grouped = <String, List<Transaction>>{};
    for (final Transaction t in transactions) {
      final String key = t.categoryKey ?? 'income';
      grouped.putIfAbsent(key, () => <Transaction>[]).add(t);
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        // تطبيق الخط على كامل الصفحة
        theme: pw.ThemeData.withFont(base: ttf),
        build: (pw.Context context) => <pw.Widget>[
          // Header
          pw.Header(
            level: 0,
            child: pw.Text(
              'Spendo — Отчёт о расходах',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(
            'Сформирован: ${DateFormat('dd MMMM yyyy', 'ru_RU').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 16),

          // Summary box
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(border: pw.Border.all()),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: <pw.Widget>[
                pw.Text(
                  'Доходы: ${totalIncome.toStringAsFixed(2)} ₽',
                  style: const pw.TextStyle(color: PdfColors.green),
                ),
                pw.Text(
                  'Расходы: ${totalExpense.toStringAsFixed(2)} ₽',
                  style: const pw.TextStyle(color: PdfColors.red),
                ),
                pw.Text(
                  'Баланс: ${(totalIncome - totalExpense).toStringAsFixed(2)} ₽',
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Transactions table grouped by category
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
                  headers: <String>['Дата', 'Сумма', 'Примечание'],
                  data: entry.value
                      .map(
                        (Transaction t) => <String>[
                          DateFormat('dd.MM.yyyy', 'ru_RU').format(t.date),
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