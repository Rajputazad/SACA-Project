import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('en', 'YN'),
  ];

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @howFeeling.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today?'**
  String get howFeeling;

  /// No description provided for @symptomDetailsQuestion.
  ///
  /// In en, this message translates to:
  /// **'Can you describe it more?'**
  String get symptomDetailsQuestion;

  /// No description provided for @medicineQuestion.
  ///
  /// In en, this message translates to:
  /// **'Have you taken any medicine?'**
  String get medicineQuestion;

  /// No description provided for @addMoreSymptomsQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to add more symptoms?'**
  String get addMoreSymptomsQuestion;

  /// No description provided for @additionalSymptomQuestion.
  ///
  /// In en, this message translates to:
  /// **'What other symptom do you have?'**
  String get additionalSymptomQuestion;

  /// No description provided for @tapToSpeak.
  ///
  /// In en, this message translates to:
  /// **'Tap to speak your symptoms'**
  String get tapToSpeak;

  /// No description provided for @tellUsHowFeel.
  ///
  /// In en, this message translates to:
  /// **'Tell us how you feel'**
  String get tellUsHowFeel;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// No description provided for @typeSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Type your symptoms'**
  String get typeSymptoms;

  /// No description provided for @chooseFromBodyMap.
  ///
  /// In en, this message translates to:
  /// **'Choose from body map'**
  String get chooseFromBodyMap;

  /// No description provided for @tapMicStart.
  ///
  /// In en, this message translates to:
  /// **'Tap the microphone to start'**
  String get tapMicStart;

  /// No description provided for @preparingMic.
  ///
  /// In en, this message translates to:
  /// **'Preparing microphone...'**
  String get preparingMic;

  /// No description provided for @tapMicTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Tap microphone to try again'**
  String get tapMicTryAgain;

  /// No description provided for @tapMicSpeakAgain.
  ///
  /// In en, this message translates to:
  /// **'Tap microphone to speak again'**
  String get tapMicSpeakAgain;

  /// No description provided for @speechUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech is not available'**
  String get speechUnavailable;

  /// No description provided for @exampleStartedMorning.
  ///
  /// In en, this message translates to:
  /// **'Example: It started this morning'**
  String get exampleStartedMorning;

  /// No description provided for @exampleMedicine.
  ///
  /// In en, this message translates to:
  /// **'Example: Yes, I took paracetamol'**
  String get exampleMedicine;

  /// No description provided for @examplePainFever.
  ///
  /// In en, this message translates to:
  /// **'Example: I have pain and fever'**
  String get examplePainFever;

  /// No description provided for @triageResult.
  ///
  /// In en, this message translates to:
  /// **'Triage Result'**
  String get triageResult;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @symptomsLabel.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptomsLabel;

  /// No description provided for @severityLabel.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severityLabel;

  /// No description provided for @apiError.
  ///
  /// In en, this message translates to:
  /// **'API Error'**
  String get apiError;

  /// No description provided for @micError.
  ///
  /// In en, this message translates to:
  /// **'Mic error'**
  String get micError;

  /// No description provided for @noSpeechMatch.
  ///
  /// In en, this message translates to:
  /// **'I didn\'t catch that. Tap the microphone and try again.'**
  String get noSpeechMatch;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get checking;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @wherePain.
  ///
  /// In en, this message translates to:
  /// **'Where do you feel pain?'**
  String get wherePain;

  /// No description provided for @easyToRead.
  ///
  /// In en, this message translates to:
  /// **'Easy to read'**
  String get easyToRead;

  /// No description provided for @localLanguage.
  ///
  /// In en, this message translates to:
  /// **'Local language'**
  String get localLanguage;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @searchSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Search Symptoms'**
  String get searchSymptoms;

  /// No description provided for @selectSymptom.
  ///
  /// In en, this message translates to:
  /// **'Select Symptom'**
  String get selectSymptom;

  /// No description provided for @symptomDetails.
  ///
  /// In en, this message translates to:
  /// **'Symptom Details'**
  String get symptomDetails;

  /// No description provided for @addAnotherSymptom.
  ///
  /// In en, this message translates to:
  /// **'Add another symptom'**
  String get addAnotherSymptom;

  /// No description provided for @searchOrBrowse.
  ///
  /// In en, this message translates to:
  /// **'Search above or browse by body part'**
  String get searchOrBrowse;

  /// No description provided for @noSymptomsFound.
  ///
  /// In en, this message translates to:
  /// **'No symptoms found'**
  String get noSymptomsFound;

  /// No description provided for @whatTypeOf.
  ///
  /// In en, this message translates to:
  /// **'What type of'**
  String get whatTypeOf;

  /// No description provided for @intensityLevel.
  ///
  /// In en, this message translates to:
  /// **'Intensity level'**
  String get intensityLevel;

  /// No description provided for @mild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get mild;

  /// No description provided for @moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// No description provided for @severe.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get severe;

  /// No description provided for @mySymptoms.
  ///
  /// In en, this message translates to:
  /// **'My Symptoms'**
  String get mySymptoms;

  /// No description provided for @noSymptomsSelected.
  ///
  /// In en, this message translates to:
  /// **'No symptoms selected'**
  String get noSymptomsSelected;

  /// No description provided for @intensity.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get intensity;

  /// No description provided for @symptomsConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Symptoms confirmed'**
  String get symptomsConfirmed;

  /// No description provided for @exampleHeadache.
  ///
  /// In en, this message translates to:
  /// **'e.g., Headache'**
  String get exampleHeadache;

  /// No description provided for @tapBodyArea.
  ///
  /// In en, this message translates to:
  /// **'Tap a body area to select symptoms'**
  String get tapBodyArea;

  /// No description provided for @confirmSelection.
  ///
  /// In en, this message translates to:
  /// **'Confirm selection'**
  String get confirmSelection;

  /// No description provided for @connectingCommunity.
  ///
  /// In en, this message translates to:
  /// **'Connecting community and health together.'**
  String get connectingCommunity;

  /// No description provided for @agreeHealthInfo.
  ///
  /// In en, this message translates to:
  /// **'I agree to share my health information'**
  String get agreeHealthInfo;

  /// No description provided for @whatAreYouFeeling.
  ///
  /// In en, this message translates to:
  /// **'What are you feeling?'**
  String get whatAreYouFeeling;

  /// No description provided for @typeNaturallyExample.
  ///
  /// In en, this message translates to:
  /// **'Type naturally, for example: I am having fever'**
  String get typeNaturallyExample;

  /// No description provided for @typeYourSymptomsHere.
  ///
  /// In en, this message translates to:
  /// **'Type your symptoms here...'**
  String get typeYourSymptomsHere;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// No description provided for @typedSymptomsSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Typed symptoms submitted'**
  String get typedSymptomsSubmitted;

  /// No description provided for @typedSymptomsSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Typed Symptoms'**
  String get typedSymptomsSheetTitle;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @describeSymptomDetail.
  ///
  /// In en, this message translates to:
  /// **'Describe your symptom in more detail'**
  String get describeSymptomDetail;

  /// No description provided for @howLongHappening.
  ///
  /// In en, this message translates to:
  /// **'How long has this been happening?'**
  String get howLongHappening;

  /// No description provided for @howStrongIsIt.
  ///
  /// In en, this message translates to:
  /// **'How strong is it?'**
  String get howStrongIsIt;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Example: I feel hot and tired...'**
  String get descriptionHint;

  /// No description provided for @durationHint.
  ///
  /// In en, this message translates to:
  /// **'Or type: since morning, two days, one week...'**
  String get durationHint;

  /// No description provided for @intensityHint.
  ///
  /// In en, this message translates to:
  /// **'Type anything about the pain level...'**
  String get intensityHint;

  /// No description provided for @medicineHint.
  ///
  /// In en, this message translates to:
  /// **'Type medicine name or extra detail...'**
  String get medicineHint;

  /// No description provided for @finalNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Type any final note before submit...'**
  String get finalNoteHint;

  /// No description provided for @oneMild.
  ///
  /// In en, this message translates to:
  /// **'1 mild'**
  String get oneMild;

  /// No description provided for @medicineLabel.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get medicineLabel;

  /// No description provided for @selectSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Select symptoms'**
  String get selectSymptoms;

  /// No description provided for @selectYourSymptom.
  ///
  /// In en, this message translates to:
  /// **'Select your symptom'**
  String get selectYourSymptom;

  /// No description provided for @tapImageAnswerOneAtATime.
  ///
  /// In en, this message translates to:
  /// **'Tap an image, then answer one question at a time'**
  String get tapImageAnswerOneAtATime;

  /// No description provided for @chooseOnMap.
  ///
  /// In en, this message translates to:
  /// **'Choose on map'**
  String get chooseOnMap;

  /// No description provided for @chooseSide.
  ///
  /// In en, this message translates to:
  /// **'Choose side'**
  String get chooseSide;

  /// No description provided for @whenFeelMost.
  ///
  /// In en, this message translates to:
  /// **'When do you feel it most?'**
  String get whenFeelMost;

  /// No description provided for @anythingElseAdd.
  ///
  /// In en, this message translates to:
  /// **'Anything else you want to add?'**
  String get anythingElseAdd;

  /// No description provided for @chooseNumberFromOneToTen.
  ///
  /// In en, this message translates to:
  /// **'Choose a number from 1 to 10.'**
  String get chooseNumberFromOneToTen;

  /// No description provided for @optionalQuestion.
  ///
  /// In en, this message translates to:
  /// **'This is optional.'**
  String get optionalQuestion;

  /// No description provided for @optionsAre.
  ///
  /// In en, this message translates to:
  /// **'Options are'**
  String get optionsAre;

  /// No description provided for @selectAnotherSymptom.
  ///
  /// In en, this message translates to:
  /// **'Select another symptom.'**
  String get selectAnotherSymptom;

  /// No description provided for @selectedArea.
  ///
  /// In en, this message translates to:
  /// **'Selected area'**
  String get selectedArea;

  /// No description provided for @optionalNote.
  ///
  /// In en, this message translates to:
  /// **'Optional note'**
  String get optionalNote;

  /// No description provided for @symptomsSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Symptoms submitted'**
  String get symptomsSubmitted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'YN':
            return AppLocalizationsEnYn();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
