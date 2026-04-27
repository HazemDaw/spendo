import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/locale/locale_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'export_bottom_sheet.dart';

class AppRightDrawer extends StatefulWidget {
  const AppRightDrawer({
    super.key,
    this.onCategoriesTap,
  });

  final Future<void> Function()? onCategoriesTap;

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
            Container(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFF7C3AED), Color(0xFF5B21B6)],
                ),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.drawerSettingsTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          inherit: true,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Spendo',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          inherit: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.label, color: AppColors.primary),
              title: Text(l10n.drawerCategories),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                Navigator.pop(context);
                if (widget.onCategoriesTap != null) {
                  await widget.onCategoriesTap!();
                  return;
                }
                if (!context.mounted) {
                  return;
                }
                context.push('/categories');
              },
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
            BlocBuilder<LocaleCubit, Locale>(
              builder: (BuildContext context, Locale locale) {
                final bool isRussian = locale.languageCode == 'ru';
                return ListTile(
                  leading: const Icon(Icons.language, color: AppColors.primary),
                  title: Text(
                    isRussian
                        ? l10n.languageTitleRussian
                        : l10n.languageTitleEnglish,
                  ),
                  trailing: Switch(
                    value: !isRussian,
                    onChanged: (_) =>
                        context.read<LocaleCubit>().toggleLocale(),
                    activeThumbColor: AppColors.primary,
                  ),
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
}
