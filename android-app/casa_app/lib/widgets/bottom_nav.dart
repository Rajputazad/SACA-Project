import 'package:flutter/material.dart';
import 'package:casa_app/l10n/app_localizations.dart';
import '../constants/app_colors.dart';

class SacaBottomNav extends StatelessWidget {
  final int currentIndex;

  const SacaBottomNav({super.key, required this.currentIndex});

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
        // Optional navigation logic
        if (index == currentIndex) return;

        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/home');
            break;
          case 1:
            // Navigator.pushNamed(context, '/results');
            break;
          case 2:
            // Navigator.pushNamed(context, '/settings');
            break;
        }
      },
    );
  }
}
