import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:casa_app/l10n/app_localizations.dart';

import '../constants/app_colors.dart';
import '../painters/bg_decoration_painter.dart';
import '../widgets/bottom_nav.dart';

class BodyMapScreen extends StatefulWidget {
  final bool openKeyboard;
  final String language;

  const BodyMapScreen({
    super.key,
    this.openKeyboard = false,
    this.language = 'english',
  });

  @override
  State<BodyMapScreen> createState() => _BodyMapScreenState();
}

class _BodyMapScreenState extends State<BodyMapScreen> {
  final List<Map<String, dynamic>> _selectedSymptoms = [];

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
    if (widget.language != 'yolngu') return value;
    return _yolnguLabels[value] ?? value;
  }

  final TextEditingController _sheetSearchCtrl = TextEditingController();
  final FocusNode _sheetSearchFocus = FocusNode();

  Map<String, List<String>> _categories = {};
  Map<String, List<String>> _symptomTypes = {};

  bool _isLoadingSymptoms = true;
  bool _openedSheetOnce = false;

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
    _loadSymptomsData();
  }

  @override
  void dispose() {
    _sheetSearchCtrl.dispose();
    _sheetSearchFocus.dispose();
    super.dispose();
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

      if (widget.openKeyboard && !_openedSheetOnce && mounted) {
        _openedSheetOnce = true;

        Future.delayed(const Duration(milliseconds: 700), () {
          if (!mounted) return;
          _showSymptomFlowSheet();
        });
      }
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
      if (entry.value.contains(norm)) {
        _sheetSearchFocus.unfocus();

        _showSymptomFlowSheet(initialCategory: _categoryForBodyPart(entry.key));
        break;
      }
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
                            disabledBackgroundColor: kBrownLight.withOpacity(
                              0.5,
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
          inactiveColor: kBrownLight.withOpacity(0.35),
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
                            onPressed: _selectedSymptoms.isEmpty
                                ? null
                                : () {
                                    debugPrint(
                                      'FINAL DATA: $_selectedSymptoms',
                                    );

                                    Navigator.pop(sheetContext);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.symptomsConfirmed),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kBrown,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(l10n.confirmSelection),
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: GestureDetector(
                    onTap: _isLoadingSymptoms ? null : _showSymptomFlowSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: kTextGrey),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.exampleHeadache,
                              style: const TextStyle(
                                color: kTextGrey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  l10n.wherePain,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: kBrown,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  l10n.tapBodyArea,
                  style: const TextStyle(color: kTextDark, fontSize: 15),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      bottom: hasSymptoms ? 80 : 8,
                    ),
                    child: SingleChildScrollView(
                      child: SizedBox(
                        height: 680,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return GestureDetector(
                              onTapDown: (details) {
                                _onBodyTap(details, constraints);
                              },
                              child: Image.asset(
                                'assets/images/body.png',
                                fit: BoxFit.contain,
                                width: constraints.maxWidth,
                                height: constraints.maxHeight,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (hasSymptoms)
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
      bottomNavigationBar: const SacaBottomNav(currentIndex: 0),
    );
  }
}
