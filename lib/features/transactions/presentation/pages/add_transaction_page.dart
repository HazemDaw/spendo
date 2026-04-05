import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class AddTransactionPage extends StatelessWidget {
  const AddTransactionPage({
    super.key,
    required this.type,
    this.initialCategoryKey,
  });

  final String type;
  final String? initialCategoryKey;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.addTransactionPlaceholder,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
