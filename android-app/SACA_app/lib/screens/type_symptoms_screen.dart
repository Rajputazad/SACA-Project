import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../painters/bg_decoration_painter.dart';
import '../l10n/app_localizations.dart';
import '../services/nlp_api_service.dart';
import 'results_screen.dart';

class TypeSymptomsScreen extends StatefulWidget {
  final String language;
  final ValueChanged<Locale>? onLocaleChange;

  const TypeSymptomsScreen({
    super.key,
    required this.language,
    this.onLocaleChange,
  });

  @override
  State<TypeSymptomsScreen> createState() => _TypeSymptomsScreenState();
}

class _TypeSymptomsScreenState extends State<TypeSymptomsScreen> {
  final TextEditingController _symptomController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _durationAnswerController =
      TextEditingController();
  final TextEditingController _intensityAnswerController =
      TextEditingController();
  final TextEditingController _medicineAnswerController =
      TextEditingController();
  final TextEditingController _addMoreAnswerController =
      TextEditingController();
  final List<Map<String, dynamic>> _typedSymptoms = [];

  List<String> _allSymptoms = [];
  String _selectedSymptom = '';
  String _selectedDuration = 'Today';
  String _selectedMedicine = 'No';
  String _addMoreChoice = 'Submit';
  double _intensity = 5;
  int _step = 0;
  bool _isQuestionFlow = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadSymptoms();
  }

  @override
  void dispose() {
    _symptomController.dispose();
    _answerController.dispose();
    _durationAnswerController.dispose();
    _intensityAnswerController.dispose();
    _medicineAnswerController.dispose();
    _addMoreAnswerController.dispose();
    super.dispose();
  }

  Future<void> _loadSymptoms() async {
    final jsonString = await rootBundle.loadString('assets/data/symptoms.json');
    final data = json.decode(jsonString) as Map<String, dynamic>;
    final categories = data['categories'] as Map<String, dynamic>;
    final symptoms =
        categories.values
            .expand((items) => List<String>.from(items as List))
            .toSet()
            .toList()
          ..sort();

    if (!mounted) return;
    setState(() => _allSymptoms = symptoms);
  }

  List<String> _suggestions() {
    final text = _symptomController.text.trim().toLowerCase();
    if (text.isEmpty) return _allSymptoms.take(8).toList();

    final words = text
        .split(RegExp(r'[^a-zA-Z]+'))
        .where((word) => word.length > 2)
        .toList();

    return _allSymptoms
        .where((symptom) {
          final lower = symptom.toLowerCase();
          return lower.contains(text) ||
              text.contains(lower) ||
              words.any((word) => lower.contains(word));
        })
        .take(8)
        .toList();
  }

  String _detectSymptom() {
    final text = _symptomController.text.trim();
    final lower = text.toLowerCase();
    for (final symptom in _allSymptoms) {
      if (lower.contains(symptom.toLowerCase())) return symptom;
    }
    final suggestions = _suggestions();
    if (suggestions.isNotEmpty) return suggestions.first;
    return text.isEmpty ? 'Symptom' : text;
  }

  void _startQuestions([String? symptom]) {
    final selected = symptom ?? _detectSymptom();
    setState(() {
      _selectedSymptom = selected;
      _isQuestionFlow = true;
      _step = 0;
      _selectedDuration = 'Today';
      _selectedMedicine = 'No';
      _addMoreChoice = 'Submit';
      _intensity = 5;
      _answerController.clear();
      _durationAnswerController.clear();
      _intensityAnswerController.clear();
      _medicineAnswerController.clear();
      _addMoreAnswerController.clear();
    });
  }

  String _entryText(Map<String, dynamic> item) {
    final typed = item['typed']?.toString().trim() ?? '';
    final symptom = item['symptom']?.toString().trim() ?? '';
    final description = item['description']?.toString().trim() ?? '';
    final duration = item['duration']?.toString().trim() ?? '';
    final level = item['level']?.toString().trim() ?? '';
    final medicine = item['medicine']?.toString().trim() ?? '';

    return [
      if (typed.isNotEmpty) typed else 'I have $symptom',
      if (description.isNotEmpty) description,
      if (duration.isNotEmpty) 'Duration: $duration',
      if (level.isNotEmpty) 'Intensity: $level',
      if (medicine.isNotEmpty) 'Medicine: $medicine',
    ].join('. ');
  }

  String _typedSymptomsInputText() {
    return _typedSymptoms.map(_entryText).join('\n');
  }

  Future<void> _submitTypedSymptoms(String inputText) async {
    if (inputText.trim().isEmpty || _isSending) return;

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
            language: widget.language,
            onLocaleChange: widget.onLocaleChange,
            result: TriageResultData.fromApi(response),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('API error: $error')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _saveSymptom({required bool addMore}) async {
    late String inputText;

    setState(() {
      _typedSymptoms.add({
        'symptom': _selectedSymptom,
        'description': _answerController.text.trim(),
        'duration': _durationAnswerController.text.trim().isEmpty
            ? _selectedDuration
            : _durationAnswerController.text.trim(),
        'level': _intensityAnswerController.text.trim().isEmpty
            ? '${_intensity.round()}/10'
            : '${_intensity.round()}/10 - ${_intensityAnswerController.text.trim()}',
        'medicine': _medicineAnswerController.text.trim().isEmpty
            ? _selectedMedicine
            : '$_selectedMedicine - ${_medicineAnswerController.text.trim()}',
        'addMoreNote': _addMoreAnswerController.text.trim(),
        'typed': _symptomController.text.trim(),
      });
      inputText = _typedSymptomsInputText();

      _isQuestionFlow = false;
      _step = 0;
      _answerController.clear();
      _durationAnswerController.clear();
      _intensityAnswerController.clear();
      _medicineAnswerController.clear();
      _addMoreAnswerController.clear();
      if (addMore) {
        _symptomController.clear();
      }
    });

    if (!addMore) {
      await _submitTypedSymptoms(inputText);
    }
  }

  Future<void> _next() async {
    if (_isSending) return;
    if (_step == 4) {
      await _saveSymptom(addMore: _addMoreChoice == 'Yes, add more');
      return;
    }
    setState(() => _step++);
  }

  Widget _topBar() {
    final l10n = AppLocalizations.of(context)!;

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
              onPressed: () {
                if (_isQuestionFlow) {
                  setState(() => _isQuestionFlow = false);
                } else {
                  Navigator.pop(context);
                }
              },
              icon: Icon(
                _isQuestionFlow ? Icons.arrow_back_ios_new : Icons.home_rounded,
                color: kBrown,
              ),
            ),
            Expanded(
              child: Text(
                l10n.typeSymptoms,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kTextDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            SizedBox(
              width: 48,
              child: _typedSymptoms.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l10n.typedSymptomsSheetTitle,
                      onPressed: _showTypedSymptoms,
                      icon: const Icon(Icons.receipt_long_outlined),
                      color: kBrown,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typingView() {
    final l10n = AppLocalizations.of(context)!;
    final suggestions = _suggestions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Fixed top section: never scrolls ──
        _topBar(),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 4),
          child: Text(
            l10n.whatAreYouFeeling,
            style: const TextStyle(
              color: kBrown,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 2, 22, 10),
          child: Text(
            l10n.typeNaturallyExample,
            style: const TextStyle(color: kTextDark, fontSize: 14),
          ),
        ),

        // ── Search / input field ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: TextField(
            controller: _symptomController,
            minLines: 1,
            maxLines: 1,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: l10n.typeYourSymptomsHere,
              prefixIcon: const Icon(Icons.search, color: kBrown),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // ── "Suggestions" label — fixed, never scrolls ──
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 8),
          child: Text(
            l10n.suggestions,
            style: const TextStyle(
              color: kTextDark,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),

        // ── Scrollable suggestions — fills all remaining space ──
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
            child: ListView.separated(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              // No container/clip — plain list with clear item cards
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: suggestions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final symptom = suggestions[index];
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      _symptomController.text = symptom;
                      _startQuestions(symptom);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              symptom,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.add_circle_outline,
                            color: kBrown,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // ── Continue button — always pinned at bottom ──
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _symptomController.text.trim().isEmpty
                  ? null
                  : () => _startQuestions(),
              style: ElevatedButton.styleFrom(
                backgroundColor: kBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                l10n.continueText,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _questionView() {
    final l10n = AppLocalizations.of(context)!;
    final titles = [
      l10n.describeSymptomDetail,
      l10n.howLongHappening,
      l10n.howStrongIsIt,
      l10n.medicineQuestion,
      l10n.addMoreSymptomsQuestion,
    ];

    return Column(
      children: [
        _topBar(),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 12),
          child: LinearProgressIndicator(
            value: (_step + 1) / titles.length,
            minHeight: 8,
            color: kBrown,
            backgroundColor: kBrownLight.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
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
            child: Container(
              key: ValueKey(_step),
              margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
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
                    titles[_step],
                    style: const TextStyle(
                      color: kTextDark,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(child: _questionBody()),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _step == 0
                      ? () => setState(() => _isQuestionFlow = false)
                      : () => setState(() => _step--),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(_step == 0 ? l10n.cancel : l10n.back),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSending ? null : _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _isSending
                        ? l10n.checking
                        : (_step == 4 ? l10n.done : l10n.next),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _questionBody() {
    final l10n = AppLocalizations.of(context)!;

    if (_step == 0) {
      return TextField(
        controller: _answerController,
        minLines: 4,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: l10n.descriptionHint,
          filled: true,
          fillColor: const Color(0xFFF8F5F0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      );
    }

    if (_step == 1) {
      return Column(
        children: [
          _answerBox(
            controller: _durationAnswerController,
            hintText: l10n.durationHint,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _optionList(
              ['Today', '1-2 days', '3+ days', '1 week+'],
              _selectedDuration,
              (value) => setState(() => _selectedDuration = value),
            ),
          ),
        ],
      );
    }

    if (_step == 2) {
      return ListView(
        padding: EdgeInsets.zero,
        children: [
          _answerBox(
            controller: _intensityAnswerController,
            hintText: l10n.intensityHint,
          ),
          const SizedBox(height: 14),
          AnimatedScale(
            scale: 1 + (_intensity / 70),
            duration: const Duration(milliseconds: 180),
            child: Text(
              '${_intensity.round()}/10',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kBrown,
                fontSize: 54,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Slider(
            value: _intensity,
            min: 1,
            max: 10,
            divisions: 9,
            label: '${_intensity.round()}/10',
            activeColor: kBrown,
            inactiveColor: kBrownLight.withValues(alpha: 0.35),
            onChanged: (value) => setState(() => _intensity = value),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.oneMild),
              const Text('5'),
              const Text('10 strong'),
            ],
          ),
        ],
      );
    }

    if (_step == 3) {
      return Column(
        children: [
          _answerBox(
            controller: _medicineAnswerController,
            hintText: l10n.medicineHint,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _optionList(
              ['No', 'Yes'],
              _selectedMedicine,
              (value) => setState(() => _selectedMedicine = value),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _answerBox(
          controller: _addMoreAnswerController,
          hintText: l10n.finalNoteHint,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _optionList(
            ['Yes, add more', 'Submit'],
            _addMoreChoice,
            (value) => setState(() => _addMoreChoice = value),
          ),
        ),
      ],
    );
  }

  Widget _answerBox({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      minLines: 1,
      maxLines: 2,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF8F5F0),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _optionList(
    List<String> options,
    String selected,
    ValueChanged<String> onSelected,
  ) {
    return ListView.separated(
      itemCount: options.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = selected == option;
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onSelected(option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected ? kCardSelected : const Color(0xFFF8F5F0),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? kBrown : Colors.black12,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? kBrown : kTextDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? kBrown : kTextGrey,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTypedSymptoms() {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.typedSymptomsSheetTitle,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _typedSymptoms.length,
                  itemBuilder: (context, index) {
                    final item = _typedSymptoms[index];
                    return ListTile(
                      title: Text(item['symptom'].toString()),
                      subtitle: Text(
                        '${l10n.intensity}: ${item['level']} • ${l10n.medicineLabel}: ${item['medicine']}',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
              child: _isQuestionFlow ? _questionView() : _typingView(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: null,
    );
  }
}
