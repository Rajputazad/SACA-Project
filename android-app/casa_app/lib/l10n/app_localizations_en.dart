// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcome => 'Welcome';

  @override
  String get getStarted => 'Get Started';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get continueText => 'Continue';

  @override
  String get howFeeling => 'How are you feeling today?';

  @override
  String get tapToSpeak => 'Tap to speak your symptoms';

  @override
  String get type => 'Type';

  @override
  String get select => 'Select';

  @override
  String get wherePain => 'Where do you feel pain?';

  @override
  String get confirmSelection => 'Confirm selection';

  @override
  String get connectingCommunity => 'Connecting community and health together.';

  @override
  String get agreeHealthInfo => 'I agree to share my health information';
}

/// The translations for English (`en_YN`).
class AppLocalizationsEnYn extends AppLocalizationsEn {
  AppLocalizationsEnYn() : super('en_YN');

  @override
  String get welcome => 'Marŋgi nhäma';

  @override
  String get getStarted => 'Djäma nhirrpan';

  @override
  String get chooseLanguage => 'Dhäruk nhirrpan';

  @override
  String get continueText => 'Dhärran';

  @override
  String get howFeeling => 'Nhä nhe walŋa nhakun dhiyaŋu?';

  @override
  String get tapToSpeak => 'Gatjuy dhäruk märram walŋa dhäwu';

  @override
  String get type => 'Dhäruk ŋurrkan';

  @override
  String get select => 'Nhäma nhirrpan';

  @override
  String get wherePain => 'Nhä wäŋa nhe marŋgithirri?';

  @override
  String get confirmSelection => 'Yakaŋu nhirrpan';

  @override
  String get connectingCommunity => 'Märram yolŋu wäŋa ga walŋa nhakun.';

  @override
  String get agreeHealthInfo => 'Ŋarra yakaŋu walŋa dhäwu nhäma.';
}
