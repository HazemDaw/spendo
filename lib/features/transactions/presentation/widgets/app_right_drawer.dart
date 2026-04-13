import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

class AppRightDrawer extends StatefulWidget {
  const AppRightDrawer({super.key});

  @override
  State<AppRightDrawer> createState() => _AppRightDrawerState();
}

class _AppRightDrawerState extends State<AppRightDrawer> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(color: AppColors.primaryDark),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Настройки',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.label, color: AppColors.primary),
              title: const Text('Категории'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showPlaceholderDialog(
                context,
                'Управление категориями будет доступно позже',
              ),
            ),
            const Divider(height: 1),
            SwitchListTile(
              secondary: const Icon(
                Icons.dark_mode,
                color: AppColors.primary,
              ),
              title: const Text('Тёмная тема'),
              value: _darkMode,
              onChanged: (bool value) {
                setState(() => _darkMode = value);
              },
              activeThumbColor: AppColors.primary,
            ),
            ListTile(
              leading: const Icon(
                Icons.upload_file,
                color: AppColors.primary,
              ),
              title: const Text('Экспорт данных'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showPlaceholderDialog(
                context,
                'Экспорт будет доступен позже',
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.login, color: AppColors.primary),
              title: const Text('Войти / Зарегистрироваться'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/login');
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(
                Icons.info_outline,
                color: AppColors.textSecondary,
              ),
              title: const Text('О приложении'),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'Spendo',
                applicationVersion: '1.0.0',
                children: const <Widget>[
                  Text('Приложение для отслеживания личных расходов.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPlaceholderDialog(BuildContext context, String message) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
