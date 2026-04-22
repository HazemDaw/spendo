import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/services/export_service.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_state.dart';

class ExportBottomSheet extends StatefulWidget {
  const ExportBottomSheet({super.key});

  @override
  State<ExportBottomSheet> createState() => _ExportBottomSheetState();
}

class _ExportBottomSheetState extends State<ExportBottomSheet> {
  final ExportService _exportService = ExportService();
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Экспорт данных',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Выберите формат',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: const Text('Экспорт в PDF'),
                  subtitle: const Text('Отчёт с группировкой по категориям'),
                  onTap: () => _export('pdf'),
                ),
                ListTile(
                  leading: const Icon(Icons.table_chart, color: Colors.green),
                  title: const Text('Экспорт в CSV'),
                  subtitle: const Text('Таблица для Excel / Google Sheets'),
                  onTap: () => _export('csv'),
                ),
              ],
            ),
          ),
          if (_isExporting)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withValues(alpha: 0.2),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _export(String format) async {
    if (_isExporting) {
      return;
    }

    final TransactionState state = context.read<TransactionBloc>().state;
    if (state is! TransactionLoaded) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Не удалось загрузить транзакции')),
        );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      late final File file;
      if (format == 'pdf') {
        file = await _exportService.exportPdf(
          state.transactions,
          state.totalIncome,
          state.totalExpense,
        );
      } else {
        file = await _exportService.exportCsv(state.transactions);
      }

      await Share.shareXFiles(<XFile>[XFile(file.path)]);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Ошибка экспорта: $error')),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }
}
