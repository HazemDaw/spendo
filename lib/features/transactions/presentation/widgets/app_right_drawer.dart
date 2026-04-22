import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'export_bottom_sheet.dart';

class AppRightDrawer extends StatefulWidget {
  const AppRightDrawer({super.key});

  @override
  State<AppRightDrawer> createState() => _AppRightDrawerState();
}

class _AppRightDrawerState extends State<AppRightDrawer> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              margin: EdgeInsets.zero,
              decoration: const BoxDecoration(color: AppColors.primaryDark),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  l10n.drawerSettingsTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.label, color: AppColors.primary),
              title: Text(l10n.drawerCategories),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showPlaceholderDialog(
                context,
                message: l10n.featureComingSoonMessage,
                okLabel: l10n.commonOk,
              ),
            ),
            const Divider(height: 1),
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (BuildContext context, ThemeMode themeMode) {
                return SwitchListTile(
                  secondary: const Icon(
                    Icons.dark_mode,
                    color: AppColors.primary,
                  ),
                  title: Text(l10n.drawerDarkTheme),
                  value: themeMode == ThemeMode.dark,
                  onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
                  activeThumbColor: AppColors.primary,
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.upload_file,
                color: AppColors.primary,
              ),
              title: Text(l10n.drawerExportData),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet<void>(
                  context: context,
                  builder: (_) => const ExportBottomSheet(),
                );
              },
            ),
            const Divider(height: 1),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (BuildContext context, AuthState state) {
                if (state is AuthAuthenticated) {
                  return ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: AppColors.expense,
                    ),
                    title: Text(l10n.authSignOutAction),
                    subtitle: Text(state.email),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.read<AuthBloc>().add(const SignOutEvent());
                    },
                  );
                }

                return ListTile(
                  leading: const Icon(Icons.login, color: AppColors.primary),
                  title: Text(l10n.authLoginOrRegisterAction),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.push('/login');
                  },
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(
                Icons.info_outline,
                color: AppColors.textSecondary,
              ),
              title: Text(l10n.drawerAbout),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'Spendo',
                applicationVersion: '1.0.0',
                children: <Widget>[
                  Text(l10n.drawerAboutDescription),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPlaceholderDialog(
    BuildContext context, {
    required String message,
    required String okLabel,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(okLabel),
            ),
          ],
        );
      },
    );
  }
}
