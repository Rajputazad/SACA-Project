import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:casa_app/l10n/app_localizations.dart';

import 'screens/welcome_screen.dart';

void main() {
  runApp(const SacaApp());
}

class SacaApp extends StatefulWidget {
  const SacaApp({super.key});

  @override
  State<SacaApp> createState() => _SacaAppState();
}

class _SacaAppState extends State<SacaApp> {
  Locale _locale = const Locale('en');

  // Change language function
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SACA',
      debugShowCheckedModeBanner: false,

      // 🌍 Language control
      locale: _locale,

      supportedLocales: const [
        Locale('en'),
        Locale('en', 'YN'), 
      ],

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Georgia',
      ),

      // 👉 Pass language function to first screen
      home: WelcomeScreen(
        onLocaleChange: setLocale,
      ),
    );
  }
}