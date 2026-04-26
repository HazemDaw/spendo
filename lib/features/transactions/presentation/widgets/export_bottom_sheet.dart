import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/services/export_service.dart';
import '../../../../l10n/app_localizations.dart';
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
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.exportTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.exportChooseFormat,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: Text(l10n.exportPdf),
                  subtitle: Text(l10n.exportPdfSubtitle),
                  onTap: () => _export('pdf'),
                ),
                ListTile(
                  leading: const Icon(Icons.table_chart, color: Colors.green),
                  title: Text(l10n.exportCsv),
                  subtitle: Text(l10n.exportCsvSubtitle),
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
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    if (state is! TransactionLoaded) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.exportLoadError)),
        );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      late final File file;
      final String locale = Localizations.localeOf(context).languageCode;
      if (format == 'pdf') {
        file = await _exportService.exportPdf(
          state.transactions,
          state.totalIncome,
          state.totalExpense,
          locale: locale,
        );
      } else {
        file = await _exportService.exportCsv(
          state.transactions,
          locale: locale,
        );
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
          SnackBar(content: Text(l10n.exportError(error.toString()))),
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
