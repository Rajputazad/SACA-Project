import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:saca_app/l10n/app_localizations.dart';

import '../constants/app_colors.dart';
import '../painters/bg_decoration_painter.dart';
import '../services/nlp_api_service.dart';
import '../widgets/bottom_nav.dart';
import 'results_screen.dart';

class BodyMapScreen extends StatefulWidget {
  final String language;
  final ValueChanged<Locale>? onLocaleChange;

  const BodyMapScreen({
    super.key,
    this.language = 'english',
    this.onLocaleChange,
  });

  @override
  State<BodyMapScreen> createState() => _BodyMapScreenState();
}

class _BodyMapScreenState extends State<BodyMapScreen> {
  final List<Map<String, dynamic>> _selectedSymptoms = [];
  final FlutterTts _tts = FlutterTts();
  late String _language;
  bool _showBodyMap = false;
  bool _isSending = false;
  Map<String, String>? _pendingLocationSymptom;
  String? _selectedMapArea;
  String _readText = 'Select your symptom. Tap an image to start.';

  static const List<Map<String, String>> _symptomChoices = [
    {
      'name': 'Anxiety',
      'image': 'assets/images/symptoms/anxiety.png',
      'category': 'General Symptoms',
    },
    {
      'name': 'Back pain',
      'image': 'assets/images/symptoms/back_pain.png',
      'category': 'Back',
    },
    {
      'name': 'Body pain',
      'image': 'assets/images/symptoms/joint_pain.png',
      'category': 'General Symptoms',
    },
    {
      'name': 'Body bleeding',
      'image': 'assets/images/symptoms/cut.png',
      'category': 'Skin Symptoms',
    },
    {
      'name': 'Burning skin',
      'image': 'assets/images/symptoms/burn.png',
      'category': 'Skin Symptoms',
    },
    {
      'name': 'Chest pain',
      'image': 'assets/images/symptoms/chest_pain.png',
      'category': 'Chest',
    },
    {
      'name': 'Cough',
      'image': 'assets/images/symptoms/cough.png',
      'category': 'Chest',
    },
    {
      'name': 'Wound',
      'image': 'assets/images/symptoms/cut.png',
      'category': 'Skin Symptoms',
    },
    {
      'name': 'Depression',
      'image': 'assets/images/symptoms/depression.png',
      'category': 'General Symptoms',
    },
    {
      'name': 'Diarrhea',
      'image': 'assets/images/symptoms/diarrhoea.png',
      'category': 'Abdomen',
    },
    {
      'name': 'Ear pain',
      'image': 'assets/images/symptoms/ear_pain.png',
      'category': 'Head',
    },
    {
      'name': 'Fainting',
      'image': 'assets/images/symptoms/faint.png',
      'category': 'General Symptoms',
    },
    {
      'name': 'Fatigue',
      'image': 'assets/images/symptoms/fatigue.png',
      'category': 'General Symptoms',
    },
    {
      'name': 'Dizziness',
      'image': 'assets/images/symptoms/dizziness.png',
      'category': 'Head',
    },
    {
      'name': 'Fever',
      'image': 'assets/images/symptoms/fever.png',
      'category': 'General Symptoms',
    },
    {
      'name': 'Headache',
      'image': 'assets/images/symptoms/headache.png',
      'category': 'Head',
    },
    {
      'name': 'Eye pain',
      'image': 'assets/images/symptoms/eye_irritation.png',
      'category': 'Head',
    },
    {
      'name': 'Joint pain',
      'image': 'assets/images/symptoms/joint_pain.png',
      'category': 'Legs',
    },
    {
      'name': 'Nausea',
      'image': 'assets/images/symptoms/nausea.png',
      'category': 'Abdomen',
    },
    {
      'name': 'Rash',
      'image': 'assets/images/symptoms/rash.png',
      'category': 'Skin Symptoms',
    },
    {
      'name': 'Runny nose',
      'image': 'assets/images/symptoms/running_nose.png',
      'category': 'Head',
    },
    {
      'name': 'Shortness of breath',
      'image': 'assets/images/symptoms/shortness_of_breath.png',
      'category': 'Chest',
    },
    {
      'name': 'Sore throat',
      'image': 'assets/images/symptoms/sore_throat.png',
      'category': 'Neck',
    },
    {
      'name': 'Stomach pain',
      'image': 'assets/images/symptoms/stomach_pain.png',
      'category': 'Abdomen',
    },
    {
      'name': 'Swelling',
      'image': 'assets/images/symptoms/swelling.png',
      'category': 'Skin Symptoms',
    },
  ];

  static const Map<String, String> _yolnguLabels = {
    'General Symptoms': 'General batjpatj dhäwu',
    'Skin Symptoms': 'Skin batjpatj dhäwu',
    'Head': 'Head',
    'Neck': 'Neck',
    'Chest': 'Chest',
    'Abdomen': 'Stomach wäŋa',
    'Arms': 'Baṉdja',
    'Legs': 'Bäka',
    'Back': 'Back',
    'Lower Back': 'Lower back',
    'Left Arm': 'Left baṉdja',
    'Right Arm': 'Right baṉdja',
    'Left Leg': 'Left bäka',
    'Right Leg': 'Right bäka',
    'Fever': 'Gorrmur',
    'Headache': 'Head batjpatj',
    'Cough': 'Cough',
    'Sore throat': 'Sore throat',
    'Vomiting': 'Vomiting',
    'Dizziness': 'Bukumuk',
    'Fatigue': 'Djawaryun',
    'Body pain': 'Body batjpatj',
    'Nausea': 'Nausea',
    'Weakness': 'Dhoṯ',
    'Rash': 'Burru\'purru',
    'Itching': 'Ḏatji',
    'Swelling': 'Swelling',
    'Burning skin': 'Skin gorrmur',
    'Skin redness': 'Skin red',
    'Wound': 'Wound',
    'Skin infection': 'Skin disease',
    'Migraine': 'Migraine',
    'Blurred vision': 'Blurred vision',
    'Eye pain': 'Eye batjpatj',
    'Confusion': 'Confusion',
    'Neck pain': 'Neck batjpatj',
    'Stiff neck': 'Stiff neck',
    'Chest pain': 'Chest batjpatj',
    'Shortness of breath': 'Breath dhärran',
    'Heartburn': 'Heartburn',
    'Wheezing': 'Wheezing',
    'Stomach pain': 'Stomach batjpatj',
    'Diarrhea': 'Diarrhea',
    'Bloating': 'Bloating',
    'Constipation': 'Constipation',
    'Arm pain': 'Baṉdja batjpatj',
    'Numbness': 'Numbness',
    'Shoulder pain': 'Shoulder batjpatj',
    'Leg pain': 'Bäka batjpatj',
    'Knee pain': 'Knee batjpatj',
    'Foot pain': 'Foot batjpatj',
    'Back pain': 'Back batjpatj',
    'Stiffness': 'Stiffness',
    'Pain while moving': 'Batjpatj movingŋur',
    'Migraine headache': 'Migraine head batjpatj',
    'Tension headache': 'Tension head batjpatj',
    'Sinus headache': 'Sinus head batjpatj',
    'Cluster headache': 'Cluster head batjpatj',
    'Headache with eye pain': 'Head batjpatj ga eye batjpatj',
    'Migraine with nausea': 'Migraine ga nausea',
    'Migraine with light sensitivity': 'Migraine ga light sensitivity',
    'Migraine with vision changes': 'Migraine ga vision changes',
    'Low fever': 'Small gorrmur',
    'High fever': 'Big gorrmur',
    'Fever with chills': 'Gorrmur ga chills',
    'Fever with sweating': 'Gorrmur ga sweating',
    'Dry cough': 'Dry cough',
    'Wet cough': 'Wet cough',
    'Cough with fever': 'Cough ga gorrmur',
    'Cough with chest pain': 'Cough ga chest batjpatj',
    'Sharp chest pain': 'Sharp chest batjpatj',
    'Pressure / tightness': 'Pressure / tightness',
    'Burning chest pain': 'Burning chest batjpatj',
    'Pain with breathing': 'Batjpatj breathingŋur',
    'Cramping pain': 'Cramping batjpatj',
    'Sharp stomach pain': 'Sharp stomach batjpatj',
    'Burning pain': 'Burning batjpatj',
    'Pain after eating': 'Batjpatj ŋatha after',
    'Mild sore throat': 'Mild sore throat',
    'Pain when swallowing': 'Batjpatj swallowingŋur',
    'Sore throat with fever': 'Sore throat ga gorrmur',
    'Vomiting once': 'Vomiting once',
    'Repeated vomiting': 'Repeated vomiting',
    'Vomiting with stomach pain': 'Vomiting ga stomach batjpatj',
    'Light dizziness': 'Small bukumuk',
    'Dizziness when standing': 'Bukumuk standingŋur',
    'Dizziness with blurred vision': 'Bukumuk ga blurred vision',
    'Upper back pain': 'Upper back batjpatj',
    'Lower back pain': 'Lower back batjpatj',
    'Back stiffness': 'Back stiffness',
  };

  String _label(String value) {
    if (_language != 'yolngu') return value;
    return _yolnguLabels[value] ?? value;
  }

  final TextEditingController _sheetSearchCtrl = TextEditingController();
  final FocusNode _sheetSearchFocus = FocusNode();

  Map<String, List<String>> _categories = {};
  Map<String, List<String>> _symptomTypes = {};

  bool _isLoadingSymptoms = true;

  static const Map<String, Rect> _bodyParts = {
    'Head': Rect.fromLTWH(0.38, 0.02, 0.24, 0.12),
    'Neck': Rect.fromLTWH(0.42, 0.14, 0.16, 0.06),
    'Chest': Rect.fromLTWH(0.30, 0.20, 0.40, 0.15),
    'Abdomen': Rect.fromLTWH(0.32, 0.35, 0.36, 0.14),
    'Left Arm': Rect.fromLTWH(0.10, 0.20, 0.20, 0.32),
    'Right Arm': Rect.fromLTWH(0.70, 0.20, 0.20, 0.32),
    'Left Leg': Rect.fromLTWH(0.28, 0.55, 0.20, 0.42),
    'Right Leg': Rect.fromLTWH(0.52, 0.55, 0.20, 0.42),
    'Lower Back': Rect.fromLTWH(0.32, 0.48, 0.36, 0.08),
  };

  @override
  void initState() {
    super.initState();
    _language = widget.language;
    _loadSymptomsData();
  }

  @override
  void dispose() {
    _tts.stop();
    _sheetSearchCtrl.dispose();
    _sheetSearchFocus.dispose();
    super.dispose();
  }

  Future<void> _readCurrentText([String? text]) async {
    final words = (text ?? _readText).trim();
    if (words.isEmpty) return;

    await _tts.stop();
    await _tts.setLanguage('en-AU');
    await _tts.setSpeechRate(0.58);
    await _tts.setPitch(1.0);
    await _tts.speak(words);
  }

  Future<void> _loadSymptomsData() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/symptoms.json',
      );

      final data = json.decode(jsonString) as Map<String, dynamic>;

      final categoriesJson = data['categories'] as Map<String, dynamic>;
      final typesJson = data['types'] as Map<String, dynamic>;

      setState(() {
        _categories = categoriesJson.map(
          (key, value) => MapEntry(key, List<String>.from(value as List)),
        );

        _symptomTypes = typesJson.map(
          (key, value) => MapEntry(key, List<String>.from(value as List)),
        );

        _isLoadingSymptoms = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSymptoms = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load symptoms.json: $e')),
      );
    }
  }

  String _categoryForBodyPart(String bodyPart) {
    switch (bodyPart) {
      case 'Left Arm':
      case 'Right Arm':
        return 'Arms';
      case 'Left Leg':
      case 'Right Leg':
        return 'Legs';
      case 'Lower Back':
        return 'Back';
      default:
        return bodyPart;
    }
  }

  List<String> _allSymptoms() {
    return _categories.values.expand((items) => items).toSet().toList()..sort();
  }

  void _onBodyTap(TapDownDetails details, BoxConstraints constraints) {
    if (_isLoadingSymptoms) return;

    final size = Size(constraints.maxWidth, constraints.maxHeight);
    final norm = Offset(
      details.localPosition.dx / size.width,
      details.localPosition.dy / size.height,
    );

    for (final entry in _bodyParts.entries) {
      if (!entry.value.contains(norm)) continue;

      _sheetSearchFocus.unfocus();
      final exactBodyPart = entry.key;
      final categoryBodyPart = _categoryForBodyPart(entry.key);
      final pending = _pendingLocationSymptom;

      if (pending != null) {
        setState(() {
          _selectedMapArea = exactBodyPart;
          _readText =
              'Selected ${_label(exactBodyPart)}. Now answer the questions.';
        });
        Future.delayed(const Duration(milliseconds: 550), () {
          if (!mounted || _pendingLocationSymptom != pending) return;
          setState(() {
            _showBodyMap = false;
            _pendingLocationSymptom = null;
            _selectedMapArea = null;
          });
          _openSymptomQuestionSheet(pending, exactBodyPart);
        });
      } else {
        setState(() {
          _selectedMapArea = exactBodyPart;
        });
        _showSymptomFlowSheet(initialCategory: categoryBodyPart);
      }
      break;
    }
  }

  void _showSymptomFlowSheet({String? initialCategory}) {
    final l10n = AppLocalizations.of(context)!;

    _sheetSearchCtrl.clear();

    String screen = initialCategory == null ? 'categories' : 'symptoms';
    String? selectedCategory = initialCategory;
    String? selectedSymptom;
    String? selectedType;
    double selectedLevel = 1;

    List<String> visibleSymptoms = initialCategory == null
        ? []
        : (_categories[initialCategory] ?? []);

    String levelText() {
      if (selectedLevel == 1) return l10n.mild;
      if (selectedLevel == 2) return l10n.moderate;
      return l10n.severe;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final title = screen == 'categories'
                ? l10n.searchSymptoms
                : screen == 'symptoms'
                ? selectedCategory ?? l10n.selectSymptom
                : l10n.symptomDetails;

            return SizedBox(
              height: MediaQuery.of(sheetContext).size.height * 0.88,
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  Container(
                    width: 55,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new),
                          onPressed: () {
                            _sheetSearchFocus.unfocus();

                            if (screen == 'details') {
                              setSheetState(() {
                                screen = 'symptoms';
                                selectedSymptom = null;
                                selectedType = null;
                                selectedLevel = 1;
                              });
                            } else if (screen == 'symptoms' &&
                                initialCategory == null) {
                              setSheetState(() {
                                screen = 'categories';
                                selectedCategory = null;
                                visibleSymptoms = [];
                                _sheetSearchCtrl.clear();
                              });
                            } else {
                              Navigator.pop(sheetContext);
                            }
                          },
                        ),

                        Expanded(
                          child: Text(
                            _label(title),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: kTextDark,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                            _sheetSearchFocus.unfocus();
                            Navigator.pop(sheetContext);
                          },
                          child: Text(l10n.cancel),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  if (screen != 'details')
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: TextField(
                        controller: _sheetSearchCtrl,
                        focusNode: _sheetSearchFocus,
                        autofocus: initialCategory == null,
                        decoration: InputDecoration(
                          hintText: l10n.addAnotherSymptom,
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          if (!mounted) return;

                          final query = value.trim().toLowerCase();

                          setSheetState(() {
                            selectedCategory = null;

                            if (query.isEmpty) {
                              screen = 'categories';
                              visibleSymptoms = [];
                            } else {
                              screen = 'symptoms';
                              visibleSymptoms = _allSymptoms()
                                  .where(
                                    (symptom) =>
                                        symptom.toLowerCase().contains(query),
                                  )
                                  .toList();
                            }
                          });
                        },
                      ),
                    ),

                  if (screen != 'details')
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      color: const Color(0xFFF2F2F2),
                      child: Text(
                        screen == 'categories'
                            ? l10n.searchOrBrowse
                            : l10n.selectSymptom,
                        style: const TextStyle(
                          color: kTextGrey,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                  Expanded(
                    child: screen == 'categories'
                        ? ListView(
                            children: _categories.keys.map((category) {
                              return ListTile(
                                title: Text(
                                  _label(category),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  _sheetSearchFocus.unfocus();

                                  setSheetState(() {
                                    selectedCategory = category;
                                    visibleSymptoms =
                                        _categories[category] ?? [];
                                    screen = 'symptoms';
                                  });
                                },
                              );
                            }).toList(),
                          )
                        : screen == 'symptoms'
                        ? visibleSymptoms.isEmpty
                              ? Center(
                                  child: Text(
                                    l10n.noSymptomsFound,
                                    style: const TextStyle(
                                      color: kTextGrey,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: visibleSymptoms.length,
                                  itemBuilder: (context, index) {
                                    final symptom = visibleSymptoms[index];

                                    return ListTile(
                                      title: Text(
                                        _label(symptom),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      trailing: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      onTap: () {
                                        _sheetSearchFocus.unfocus();

                                        setSheetState(() {
                                          selectedSymptom = symptom;
                                          selectedType = null;
                                          selectedLevel = 1;
                                          screen = 'details';
                                        });
                                      },
                                    );
                                  },
                                )
                        : _detailsView(
                            symptom: selectedSymptom ?? '',
                            selectedType: selectedType,
                            selectedLevel: selectedLevel,
                            levelText: levelText(),
                            l10n: l10n,
                            onTypeTap: (type) {
                              _sheetSearchFocus.unfocus();

                              setSheetState(() {
                                selectedType = type;
                              });
                            },
                            onLevelChanged: (value) {
                              setSheetState(() {
                                selectedLevel = value;
                              });
                            },
                          ),
                  ),

                  if (screen == 'details')
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: selectedType == null
                              ? null
                              : () {
                                  _sheetSearchFocus.unfocus();

                                  setState(() {
                                    _selectedSymptoms.add({
                                      'symptom': selectedSymptom,
                                      'type': selectedType,
                                      'level': levelText(),
                                    });
                                  });

                                  Navigator.pop(sheetContext);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kBrown,
                            disabledBackgroundColor: kBrownLight.withValues(
                              alpha: 0.5,
                            ),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            l10n.confirmSelection,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      _sheetSearchFocus.unfocus();
      _sheetSearchCtrl.clear();
    });
  }

  Widget _detailsView({
    required String symptom,
    required String? selectedType,
    required double selectedLevel,
    required String levelText,
    required AppLocalizations l10n,
    required Function(String) onTypeTap,
    required Function(double) onLevelChanged,
  }) {
    final options = _symptomTypes[symptom] ?? [symptom];

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      children: [
        Text(
          '${l10n.whatTypeOf} ${_label(symptom)}?',
          style: const TextStyle(
            color: kTextDark,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 18),

        ...options.map((type) {
          final selected = selectedType == type;

          return GestureDetector(
            onTap: () => onTypeTap(type),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? kBrown : Colors.black12,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _label(type),
                      style: const TextStyle(
                        color: kTextDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(
                    selected ? Icons.check_circle : Icons.circle_outlined,
                    color: selected ? kBrown : kTextGrey,
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 18),

        Text(
          l10n.intensityLevel,
          style: const TextStyle(
            color: kTextDark,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 12),

        Center(
          child: Text(
            levelText,
            style: const TextStyle(
              color: kBrown,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),

        Slider(
          value: selectedLevel,
          min: 1,
          max: 3,
          divisions: 2,
          label: levelText,
          activeColor: kBrown,
          inactiveColor: kBrownLight.withValues(alpha: 0.35),
          onChanged: onLevelChanged,
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(l10n.mild), Text(l10n.moderate), Text(l10n.severe)],
        ),
      ],
    );
  }

  void _showMySymptomsDrawer() {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                height: MediaQuery.of(sheetContext).size.height * 0.50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.mySymptoms,
                      style: const TextStyle(
                        color: kTextDark,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Expanded(
                      child: _selectedSymptoms.isEmpty
                          ? Center(child: Text(l10n.noSymptomsSelected))
                          : ListView.builder(
                              itemCount: _selectedSymptoms.length,
                              itemBuilder: (context, index) {
                                final item = _selectedSymptoms[index];

                                return ListTile(
                                  title: Text(_label(item['type'].toString())),
                                  subtitle: Text(
                                    '${l10n.intensity}: ${item['level']}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        _selectedSymptoms.removeAt(index);
                                      });

                                      setSheetState(() {});
                                    },
                                  ),
                                );
                              },
                            ),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            child: Text(l10n.cancel),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: _selectedSymptoms.isEmpty || _isSending
                                ? null
                                : () async {
                                    debugPrint(
                                      'FINAL DATA: $_selectedSymptoms',
                                    );

                                    Navigator.pop(sheetContext);

                                    await _submitSelectedSymptoms();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kBrown,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              _isSending
                                  ? 'Checking...'
                                  : l10n.confirmSelection,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _needsBodyMap(String symptom) {
    final value = symptom.toLowerCase();
    return value == 'body pain' ||
        value == 'body bleeding' ||
        value == 'swelling';
  }

  List<String> _locationOptions(String symptom) {
    final value = symptom.toLowerCase();
    if (value.contains('back pain') ||
        value.contains('chest pain') ||
        value.contains('ear pain') ||
        value.contains('joint pain') ||
        value.contains('eye pain')) {
      return const ['Left side', 'Right side', 'Both sides'];
    }
    if (value.contains('stomach pain')) {
      return const ['Upper stomach', 'Lower stomach', 'Whole stomach'];
    }
    return const [];
  }

  List<String> _questionOptions(String symptom) {
    final options = _symptomTypes[symptom];
    if (options != null && options.isNotEmpty) return options;

    final lower = symptom.toLowerCase();
    if (lower.contains('anxiety')) {
      return ['Worried or nervous', 'Panic feeling', 'Trouble sleeping'];
    }
    if (lower.contains('depression')) {
      return ['Feeling sad', 'No interest', 'Low energy'];
    }
    if (lower.contains('rash')) {
      return ['Itchy rash', 'Red rash', 'Painful rash'];
    }
    if (lower.contains('body bleeding')) {
      return ['Small bleeding', 'Heavy bleeding', 'Bleeding with pain'];
    }
    if (lower.contains('wound')) {
      return ['Small cut', 'Deep cut', 'Bleeding wound'];
    }
    if (lower.contains('burn')) {
      return ['Small burn', 'Hot red burn', 'Blister burn'];
    }
    if (lower.contains('swelling')) {
      return ['Mild swelling', 'Hot swelling', 'Painful swelling'];
    }
    if (lower.contains('shortness')) {
      return ['After walking', 'While resting', 'With chest pain'];
    }
    if (lower.contains('faint')) {
      return ['Felt like fainting', 'Fainted once', 'Fainted more than once'];
    }
    return ['Mild', 'Moderate', 'Severe'];
  }

  List<Map<String, dynamic>> _questionsForSymptom(
    String symptom,
    String? bodyLocation,
    AppLocalizations l10n,
  ) {
    final questions = <Map<String, dynamic>>[
      {
        'key': 'type',
        'title': '${l10n.whatTypeOf} ${_label(symptom).toLowerCase()}?',
        'options': _questionOptions(symptom),
      },
    ];

    // if (bodyLocation != null) {
    //   questions.add({
    //     'key': 'location',
    //     'title': 'Confirm the body area',
    //     'options': [bodyLocation],
    //   });
    // } else if (locationOptions.isNotEmpty) {
    //   questions.add({
    //     'key': 'location',
    //     'title': 'Which side is the problem on?',
    //     'options': locationOptions,
    //   });
    // }

    questions.addAll([
      {
        'key': 'duration',
        'title': l10n.howLongHappening,
        'options': ['Today', '1-2 days', '3+ days', '1 week+'],
      },
      {
        'key': 'trigger',
        'title': l10n.whenFeelMost,
        'options': _triggerOptions(symptom),
      },
      {'key': 'intensity', 'title': l10n.howStrongIsIt, 'type': 'scale'},
      {
        'key': 'medicine',
        'title': l10n.medicineQuestion,
        'options': ['No', 'Yes'],
      },
      {'key': 'notes', 'title': l10n.anythingElseAdd, 'type': 'text'},
      {
        'key': 'addMore',
        'title': l10n.addMoreSymptomsQuestion,
        'options': ['Yes', 'No'],
      },
    ]);

    return questions;
  }

  String _selectedSymptomsInputText() {
    return _selectedSymptoms
        .map((item) {
          final symptom = item['symptom']?.toString() ?? '';
          final type = item['type']?.toString() ?? '';
          final location = item['location']?.toString() ?? '';
          final duration = item['duration']?.toString() ?? '';
          final trigger = item['trigger']?.toString() ?? '';
          final level = item['level']?.toString() ?? '';
          final medicine = item['medicine']?.toString() ?? '';
          final notes = item['notes']?.toString() ?? '';

          return [
            'I have $symptom',
            if (type.isNotEmpty) type,
            if (location.isNotEmpty && location != 'Not selected')
              'Location: $location',
            if (duration.isNotEmpty) 'Duration: $duration',
            if (trigger.isNotEmpty) 'Trigger: $trigger',
            if (level.isNotEmpty) 'Intensity: $level',
            if (medicine.isNotEmpty) 'Medicine: $medicine',
            if (notes.isNotEmpty) notes,
          ].join('. ');
        })
        .join('\n');
  }

  Future<void> _submitSelectedSymptoms() async {
    final inputText = _selectedSymptomsInputText().trim();
    if (inputText.isEmpty || _isSending) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSending = true);
    try {
      final response = await NlpApiService.triage(
        text: inputText,
        language: 'auto',
      );
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            language: _language,
            onLocaleChange: widget.onLocaleChange,
            result: TriageResultData.fromApi(response),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      print('${l10n.apiError}: $error');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.apiError}: $error')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  List<String> _triggerOptions(String symptom) {
    final value = symptom.toLowerCase();
    if (value.contains('cough') || value.contains('shortness')) {
      return const [
        'While resting',
        'After walking',
        'At night',
        'All the time',
      ];
    }
    if (value.contains('stomach') ||
        value.contains('nausea') ||
        value.contains('diarrhea')) {
      return const [
        'After eating',
        'Before eating',
        'At night',
        'All the time',
      ];
    }
    if (value.contains('pain')) {
      return const [
        'When moving',
        'When resting',
        'When touched',
        'All the time',
      ];
    }
    if (value.contains('anxiety') || value.contains('depression')) {
      return const ['Morning', 'Night', 'Around people', 'Most of the day'];
    }
    return const ['Always there', 'Comes and goes', 'At night', 'Not sure'];
  }

  void _handleSymptomChoice(Map<String, String> symptom) {
    if (_needsBodyMap(symptom['name'] ?? '')) {
      setState(() {
        _pendingLocationSymptom = symptom;
        _showBodyMap = true;
      });
      return;
    }

    _openSymptomQuestionSheet(symptom, null);
  }

  void _openSymptomQuestionSheet(
    Map<String, String> symptom,
    String? bodyLocation,
  ) {
    final name = symptom['name'] ?? '';
    final image = symptom['image'] ?? '';
    final l10n = AppLocalizations.of(context)!;
    final questions = _questionsForSymptom(name, bodyLocation, l10n);
    final answers = <String, dynamic>{'symptom': name, 'level': 5};
    final notesController = TextEditingController();
    var step = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final question = questions[step];
            final key = question['key'].toString();
            final isLast = step == questions.length - 1;

            String questionReadText() {
              final title = question['title'].toString();
              final type = question['type']?.toString();
              if (type == 'scale') {
                return '$title ${l10n.chooseNumberFromOneToTen}';
              }
              if (type == 'text') {
                return '$title ${l10n.optionalQuestion}';
              }
              final options = question['options'];
              if (options is List && options.isNotEmpty) {
                return '$title ${l10n.optionsAre} ${options.join(', ')}.';
              }
              return title;
            }

            void finish({required bool addMore}) {
              answers['notes'] = notesController.text.trim();
              setState(() {
                _selectedSymptoms.add({
                  'symptom': name,
                  'type': answers['type'] ?? '',
                  'location': answers['location'] ?? 'Not selected',
                  'duration': answers['duration'] ?? '',
                  'trigger': answers['trigger'] ?? '',
                  'level': '${answers['level'] ?? 5}/10',
                  'medicine': answers['medicine'] ?? 'No',
                  'notes': answers['notes'] ?? '',
                });
                _readText = addMore
                    ? l10n.selectAnotherSymptom
                    : l10n.symptomsSubmitted;
              });
              Navigator.pop(sheetContext);

              if (!addMore) {
                _submitSelectedSymptoms();
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: SizedBox(
                height: MediaQuery.of(sheetContext).size.height * 0.86,
                child: Column(
                  children: [
                    Container(
                      width: 55,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Hero(
                          tag: image,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset(
                              image,
                              width: 76,
                              height: 76,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _label(name),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: kTextDark,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  IconButton.filledTonal(
                                    tooltip: 'Read aloud',
                                    onPressed: () =>
                                        _readCurrentText(questionReadText()),
                                    icon: const Icon(
                                      Icons.record_voice_over_rounded,
                                    ),
                                    color: kBrown,
                                  ),
                                ],
                              ),
                              if (bodyLocation != null) ...[
                                const SizedBox(height: 6),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 240),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kCardSelected,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: kBrown),
                                  ),
                                  child: Text(
                                    '${l10n.selectedArea}: ${_label(bodyLocation)}',
                                    style: const TextStyle(
                                      color: kBrown,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: (step + 1) / questions.length,
                                minHeight: 7,
                                color: kBrown,
                                backgroundColor: kBrownLight.withValues(
                                  alpha: 0.25,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.08, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: _singleQuestionPage(
                          key: ValueKey('$name-$step'),
                          question: question,
                          answer: answers[key],
                          notesController: notesController,
                          onAnswer: (value) {
                            setSheetState(() {
                              answers[key] = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: step == 0
                                ? () => Navigator.pop(sheetContext)
                                : () => setSheetState(() => step--),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(step == 0 ? l10n.cancel : l10n.back),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final options = question['options'];
                              if (options is List &&
                                  options.isNotEmpty &&
                                  answers[key] == null) {
                                answers[key] = options.first;
                              }
                              if (isLast) {
                                finish(addMore: answers['addMore'] == 'Yes');
                                return;
                              }
                              setSheetState(() => step++);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kBrown,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              isLast ? l10n.done : l10n.next,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(notesController.dispose);
  }

  Widget _singleQuestionPage({
    required Key key,
    required Map<String, dynamic> question,
    required dynamic answer,
    required TextEditingController notesController,
    required ValueChanged<dynamic> onAnswer,
  }) {
    final type = question['type']?.toString();
    final title = question['title'].toString();

    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: kTextDark,
              fontSize: 25,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: type == 'scale'
                ? _scaleQuestion(answer: answer, onAnswer: onAnswer)
                : type == 'text'
                ? _textQuestion(notesController)
                : _optionQuestion(
                    options: List<String>.from(question['options'] as List),
                    answer: answer?.toString(),
                    onAnswer: onAnswer,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _optionQuestion({
    required List<String> options,
    required String? answer,
    required ValueChanged<String> onAnswer,
  }) {
    return ListView.separated(
      itemCount: options.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final option = options[index];
        final selected = answer == option || (answer == null && index == 0);
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 180 + index * 45),
          tween: Tween(begin: 0, end: 1),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(18 * (1 - value), 0),
                child: child,
              ),
            );
          },
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => onAnswer(option),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: selected ? kCardSelected : const Color(0xFFF8F5F0),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? kBrown : Colors.black12,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _label(option),
                      style: TextStyle(
                        color: selected ? kBrown : kTextDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Icon(
                    selected ? Icons.check_circle : Icons.circle_outlined,
                    color: selected ? kBrown : kTextGrey,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _scaleQuestion({
    required dynamic answer,
    required ValueChanged<int> onAnswer,
  }) {
    final value = answer is int ? answer : 5;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedScale(
          scale: 1 + (value / 70),
          duration: const Duration(milliseconds: 180),
          child: Text(
            '$value/10',
            style: const TextStyle(
              color: kBrown,
              fontSize: 54,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 22),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: '$value/10',
          activeColor: kBrown,
          inactiveColor: kBrownLight.withValues(alpha: 0.35),
          onChanged: (newValue) => onAnswer(newValue.round()),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context)!.oneMild),
            const Text('5'),
            const Text('10 strong'),
          ],
        ),
      ],
    );
  }

  Widget _textQuestion(TextEditingController controller) {
    return Column(
      children: [
        TextField(
          controller: controller,
          minLines: 6,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.optionalNote,
            filled: true,
            fillColor: const Color(0xFFF8F5F0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _topNavBar({
    required String title,
    required String readText,
    VoidCallback? onBack,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack ?? () => Navigator.pop(context),
              icon: Icon(
                onBack == null ? Icons.home_rounded : Icons.arrow_back_ios_new,
                color: kBrown,
              ),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: kTextDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            IconButton.filledTonal(
              tooltip: 'Read text',
              onPressed: () => _readCurrentText(readText),
              icon: const Icon(Icons.record_voice_over_rounded),
              color: kBrown,
            ),
          ],
        ),
      ),
    );
  }

  Widget _symptomGridView(AppLocalizations l10n, bool hasSymptoms) {
    final screenText =
        '${l10n.selectYourSymptom}. ${l10n.tapImageAnswerOneAtATime}';
    _readText = screenText;

    return Column(
      children: [
        _topNavBar(title: l10n.selectSymptoms, readText: screenText),
        const SizedBox(height: 8),
        Text(
          l10n.selectYourSymptom,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: kBrown,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            l10n.tapImageAnswerOneAtATime,
            textAlign: TextAlign.center,
            style: const TextStyle(color: kTextDark, fontSize: 15),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.fromLTRB(16, 0, 16, hasSymptoms ? 86 : 18),
            itemCount: _symptomChoices.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.82,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemBuilder: (context, index) {
              final item = _symptomChoices[index];
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 260 + (index % 8) * 45),
                tween: Tween(begin: 0, end: 1),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value.clamp(0, 1),
                    child: Transform.translate(
                      offset: Offset(0, 18 * (1 - value)),
                      child: Transform.scale(
                        scale: 0.94 + (value * 0.06),
                        child: child,
                      ),
                    ),
                  );
                },
                child: _symptomCard(item, l10n),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _symptomCard(Map<String, String> item, AppLocalizations l10n) {
    final name = item['name'] ?? '';
    final image = item['image'] ?? '';
    final needsLocation =
        _needsBodyMap(name) || _locationOptions(name).isNotEmpty;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _handleSymptomChoice(item),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Hero(
                  tag: image,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(image, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _label(name),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: kTextDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              if (needsLocation)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _needsBodyMap(name) ? l10n.chooseOnMap : l10n.chooseSide,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: kBrown,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bodyLocationView(AppLocalizations l10n, bool hasSymptoms) {
    final title =
        'Where is the ${_label(_pendingLocationSymptom?['name'] ?? 'problem')}?';
    final readText = _selectedMapArea == null
        ? '$title Tap the body area so we know the location.'
        : 'Selected ${_label(_selectedMapArea!)}.';
    _readText = readText;

    return Column(
      children: [
        _topNavBar(
          title: 'Body Map',
          readText: readText,
          onBack: () {
            setState(() {
              _showBodyMap = false;
              _pendingLocationSymptom = null;
              _selectedMapArea = null;
            });
          },
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: kBrown,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Tap the body area so we know the location',
          style: TextStyle(color: kTextDark, fontSize: 15),
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: _selectedMapArea == null
              ? const SizedBox(height: 38)
              : Container(
                  key: ValueKey(_selectedMapArea),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: kCardSelected,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: kBrown),
                  ),
                  child: Text(
                    'Selected: ${_label(_selectedMapArea!)}',
                    style: const TextStyle(
                      color: kBrown,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapDown: (details) => _onBodyTap(details, constraints),
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 320),
                    tween: Tween(begin: 0.96, end: 1),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/body_map.png',
                        fit: BoxFit.contain,
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSymptoms = _selectedSymptoms.isNotEmpty;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: BgDecorationPainter(),
          ),
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _showBodyMap
                  ? _bodyLocationView(l10n, hasSymptoms)
                  : _symptomGridView(l10n, hasSymptoms),
            ),
          ),
          if (hasSymptoms && !_showBodyMap)
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: ElevatedButton(
                onPressed: _showMySymptomsDrawer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  '${l10n.mySymptoms} (${_selectedSymptoms.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _showBodyMap
          ? null
          : SacaBottomNav(
              currentIndex: 0,
              onHomeTap: () => Navigator.pop(context),
              onLocaleChange: widget.onLocaleChange,
              onLanguageChange: (language) {
                setState(() {
                  _language = language;
                });
              },
            ),
    );
  }
}
