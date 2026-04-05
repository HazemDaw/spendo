import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class TransactionListPage extends StatelessWidget {
  const TransactionListPage({
    super.key,
    required this.categoryKey,
  });

  final String categoryKey;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.transactionListPlaceholder,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
