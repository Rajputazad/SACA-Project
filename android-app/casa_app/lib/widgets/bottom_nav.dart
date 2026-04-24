import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SacaBottomNav extends StatelessWidget {
  final int currentIndex;

  const SacaBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: kBrown,
      unselectedItemColor: kTextGrey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description_outlined),
          label: 'Results',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Settings',
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