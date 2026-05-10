import 'package:flutter/material.dart';
import 'package:saca_app/l10n/app_localizations.dart';
import '../constants/app_colors.dart';

class SacaBottomNav extends StatelessWidget {
  final int currentIndex;
  final VoidCallback? onHomeTap;
  final ValueChanged<Locale>? onLocaleChange;
  final ValueChanged<String>? onLanguageChange;

  const SacaBottomNav({
    super.key,
    required this.currentIndex,
    this.onHomeTap,
    this.onLocaleChange,
    this.onLanguageChange,
  });

  void _showLanguagePopup(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.chooseLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.chat_bubble_outline_rounded),
                title: const Text('English'),
                onTap: () {
                  onLocaleChange?.call(const Locale('en'));
                  onLanguageChange?.call('english');
                  Navigator.pop(dialogContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.people_outline_rounded),
                title: const Text('Yolŋu'),
                onTap: () {
                  onLocaleChange?.call(const Locale('en', 'YN'));
                  onLanguageChange?.call('yolngu');
                  Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: kBrown,
      unselectedItemColor: kTextGrey,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_rounded),
          label: l10n.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.description_outlined),
          label: l10n.results,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined),
          label: l10n.settings,
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            onHomeTap?.call();
            break;
          case 1:
            break;
          case 2:
            _showLanguagePopup(context);
            break;
        }
      },
    );
  }
}
