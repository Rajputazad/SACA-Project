import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../constants/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';
import '../painters/bg_decoration_painter.dart';
import '../services/nlp_api_service.dart';
import '../services/result_history_service.dart';
import '../widgets/bottom_nav.dart';
import 'results_history_screen.dart';
import 'results_screen.dart';

class SpeechSymptomScreen extends StatefulWidget {
  final String language;
  final ValueChanged<Locale>? onLocaleChange;

  const SpeechSymptomScreen({
    super.key,
    required this.language,
    this.onLocaleChange,
  });

  @override
  State<SpeechSymptomScreen> createState() => _SpeechSymptomScreenState();
}

class _SpeechSymptomScreenState extends State<SpeechSymptomScreen> {
  stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  bool _isSending = false;
  late String _language;
  String _spokenText = '';
  String _status = '';
  int _questionStep = 0;
  final List<String> _answers = [];

  String get _languageName {
    return _language == 'yolngu' ? 'Yolŋu' : 'English';
  }

  AppLocalizations get _l10n {
    return _language == 'yolngu'
        ? AppLocalizationsEnYn()
        : AppLocalizationsEn();
  }

  String get _localeId {
    // Android/iOS speech may not support Yolŋu.
    // Use English recognition, then send language='yolngu' to your backend.
    return 'en_US';
  }

  String _textForTts(String text) {
    return text
        .replaceAll('Ŋ', 'Ng')
        .replaceAll('ŋ', 'ng')
        .replaceAll('ä', 'a')
        .replaceAll('Ḏ', 'D')
        .replaceAll('ḏ', 'd')
        .replaceAll('ṯ', 't')
        .replaceAll('ṉ', 'n')
        .replaceAll('Ḻ', 'L')
        .replaceAll('ḻ', 'l');
  }

  Future<void> _configureTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
  }

  Future<void> _speakPrompt() async {
    if (!mounted) return;

    final l10n = _l10n;
    final prompt = _isAddMoreQuestion
        ? _questionText(l10n)
        : '${_questionText(l10n)}. ${l10n.tapMicStart}.';
    final ttsText = _language == 'yolngu' ? _textForTts(prompt) : prompt;

    await _tts.stop();
    await _tts.speak(ttsText);
  }

  bool get _isAddMoreQuestion => _questionStep == 3;

  bool _isYesAnswer(String value) {
    final answer = value.trim().toLowerCase();
    return answer == 'yes' ||
        answer.contains('yes') ||
        answer == 'yo' ||
        answer.contains('add more');
  }

  bool _isSubmitAnswer(String value) {
    final answer = value.trim().toLowerCase();
    return answer == 'submit' ||
        answer.contains('submit') ||
        answer == 'no' ||
        answer.contains('no') ||
        answer.contains('done') ||
        answer.contains('finish');
  }

  Future<void> _handleAddMoreVoiceAnswer([String? spoken]) async {
    final answer = (spoken ?? _spokenText).trim();
    if (answer.isEmpty) return;

    if (_isYesAnswer(answer)) {
      await _askAnotherSymptom();
      return;
    }

    if (_isSubmitAnswer(answer)) {
      await _showSymptomsAlert();
    }
  }

  String _questionText(AppLocalizations l10n) {
    if (_questionStep == 1) return l10n.symptomDetailsQuestion;
    if (_questionStep == 2) return l10n.medicineQuestion;
    if (_questionStep == 3) return l10n.addMoreSymptomsQuestion;
    if (_questionStep == 4) return l10n.additionalSymptomQuestion;
    return l10n.howFeeling;
  }

  String _exampleText(AppLocalizations l10n) {
    if (_questionStep == 1) return l10n.exampleStartedMorning;
    if (_questionStep == 2) return l10n.exampleMedicine;
    if (_questionStep == 3) return '';
    return l10n.examplePainFever;
  }

  String get _combinedSymptomText {
    final allAnswers = [..._answers];
    if (_spokenText.trim().isNotEmpty) {
      allAnswers.add(_spokenText.trim());
    }

    return allAnswers.join('\n');
  }

  Future<void> _goToNextQuestion() async {
    final answer = _spokenText.trim();
    if (answer.isEmpty) return;

    await _speech.stop();

    if (!mounted) return;

    final l10n = _l10n;

    setState(() {
      _isListening = false;
      _answers.add(answer);
      _spokenText = '';
      _status = l10n.tapMicStart;

      if (_questionStep == 0) {
        _questionStep = 1;
      } else if (_questionStep == 1) {
        _questionStep = 2;
      } else if (_questionStep == 2 || _questionStep == 4) {
        _questionStep = 3;
      }
    });

    await _speakPrompt();
  }

  Future<void> _askAnotherSymptom() async {
    final l10n = _l10n;

    setState(() {
      _questionStep = 4;
      _spokenText = '';
      _status = l10n.tapMicStart;
      _isListening = false;
    });

    await _speakPrompt();
  }

  Future<void> _startListening() async {
    if (_isListening) return;

    if (!mounted) return;

    final l10n = _l10n;

    await _tts.stop();
    await _speech.cancel();

    if (!mounted) return;

    setState(() {
      _spokenText = '';
      _status = l10n.preparingMic;
    });

    final available = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;

        if (status == 'done' || status == 'notListening') {
          setState(() {
            _isListening = false;
            _status = _spokenText.trim().isEmpty
                ? l10n.tapMicTryAgain
                : l10n.tapMicSpeakAgain;
          });
        }
      },
      onError: (error) {
        if (!mounted) return;

        setState(() {
          _isListening = false;
          _status = error.errorMsg == 'error_no_match'
              ? l10n.noSpeechMatch
              : '${l10n.micError}: ${error.errorMsg}';
        });
      },
    );

    if (!mounted) return;

    if (!available) {
      setState(() {
        _status = l10n.speechUnavailable;
      });
      return;
    }

    setState(() {
      _isListening = true;
      _status = l10n.listening;
    });

    await _speech.listen(
      localeId: _localeId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      cancelOnError: false,
      listenMode: stt.ListenMode.dictation,
      onResult: (result) {
        if (!mounted) return;

        final words = result.recognizedWords.trim();

        if (words.isNotEmpty) {
          setState(() {
            _spokenText = words;
          });

          if (_isAddMoreQuestion && result.finalResult) {
            _handleAddMoreVoiceAnswer(words);
          }
        }
      },
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();

    if (!mounted) return;

    final l10n = _l10n;

    setState(() {
      _isListening = false;
      _status = _spokenText.trim().isEmpty
          ? l10n.tapMicTryAgain
          : l10n.tapMicSpeakAgain;
    });
  }

  // ignore: unused_element
  Future<void> _sendToApi() async {
    if (_spokenText.trim().isEmpty && _answers.isEmpty) return;

    final l10n = _l10n;

    setState(() {
      _isSending = true;
    });

    try {
      final result = await NlpApiService.triage(
        text: _combinedSymptomText,
        language: _language,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(l10n.triageResult),
          content: Text(
            '${l10n.languageLabel}: $_languageName\n\n'
            '${l10n.symptomsLabel}: ${result['symptoms']}\n\n'
            '${l10n.severityLabel}: ${result['severity']}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.ok),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.apiError}: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _showSymptomsAlert() async {
    final inputText = _combinedSymptomText.trim();
    if (inputText.isEmpty || _isSending) return;

    final l10n = _l10n;

    setState(() => _isSending = true);
    try {
      final response = await NlpApiService.triage(
        text: inputText,
        language: 'auto',
      );
      if (!mounted) return;
      await ResultHistoryService.save(response);
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.apiError}: $error')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _language = widget.language;
    _configureTts();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakPrompt();
    });
  }

  @override
  void dispose() {
    _tts.stop();
    _speech.cancel();
    super.dispose();
  }

  bool get _hasText => _spokenText.trim().isNotEmpty;

  String get _primaryButtonText {
    final l10n = _l10n;
    if (_isSending) return l10n.checking;
    return l10n.next;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = _l10n;

    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: BgDecorationPainter(),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 700;
                final micOuter = compact ? 190.0 : 240.0;
                final micMiddle = compact ? 142.0 : 180.0;
                final micInner = compact ? 96.0 : 122.0;

                return SingleChildScrollView(
                  padding: EdgeInsets.all(compact ? 18 : 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - (compact ? 36 : 48),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _questionText(l10n),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: kBrown,
                            fontSize: compact ? 27 : 31,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                        ),

                        SizedBox(height: compact ? 16 : 22),

                        GestureDetector(
                          onTap: _isListening
                              ? _stopListening
                              : _startListening,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: micOuter,
                                height: micOuter,
                                decoration: BoxDecoration(
                                  color: kBrownLight.withOpacity(0.18),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: micMiddle,
                                height: micMiddle,
                                decoration: BoxDecoration(
                                  color: kBrownLight.withOpacity(0.28),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: micInner,
                                height: micInner,
                                decoration: BoxDecoration(
                                  color: kBrown,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: kBrown.withOpacity(0.35),
                                      blurRadius: 22,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _isListening ? Icons.mic : Icons.mic_none,
                                  color: Colors.white,
                                  size: compact ? 50 : 60,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: compact ? 18 : 28),

                        Text(
                          _status.isEmpty ? l10n.tapMicStart : _status,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: kTextDark,
                            fontSize: compact ? 24 : 29,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                        ),

                        SizedBox(height: compact ? 14 : 18),

                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(compact ? 14 : 18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: kBrown, width: 1.4),
                          ),
                          child: Text(
                            _spokenText.trim().isEmpty
                                ? (_isAddMoreQuestion
                                      ? '${l10n.yes} / ${l10n.submit}'
                                      : _exampleText(l10n))
                                : _spokenText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _spokenText.trim().isEmpty
                                  ? kTextGrey
                                  : kTextDark,
                              fontSize: compact ? 18 : 21,
                              fontWeight: FontWeight.w800,
                              height: 1.28,
                            ),
                          ),
                        ),

                        SizedBox(height: compact ? 18 : 28),

                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: compact ? 52 : 58,
                                child: ElevatedButton(
                                  onPressed: _isAddMoreQuestion
                                      ? _askAnotherSymptom
                                      : () async {
                                          await _speech.stop();
                                          await _speech.cancel();
                                          if (!mounted) return;
                                          Navigator.pop(context);
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: kTextDark,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: const BorderSide(color: kBrown),
                                    ),
                                  ),
                                  child: Text(
                                    _isAddMoreQuestion ? l10n.yes : l10n.cancel,
                                    style: TextStyle(
                                      fontSize: compact ? 16 : 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: SizedBox(
                                height: compact ? 52 : 58,
                                child: ElevatedButton(
                                  onPressed:
                                      (_isAddMoreQuestion ||
                                          (_hasText && !_isSending))
                                      ? () async {
                                          if (_isAddMoreQuestion) {
                                            if (_isYesAnswer(_spokenText)) {
                                              await _askAnotherSymptom();
                                            } else {
                                              await _showSymptomsAlert();
                                            }
                                          } else {
                                            await _goToNextQuestion();
                                          }
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kBrown,
                                    disabledBackgroundColor: kBrownLight
                                        .withOpacity(0.55),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    _isAddMoreQuestion
                                        ? l10n.submit
                                        : _primaryButtonText,
                                    style: TextStyle(
                                      fontSize: compact ? 16 : 18,
                                      fontWeight: FontWeight.w900,
                                    ),
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
            ),
          ),
        ],
      ),
      bottomNavigationBar: SacaBottomNav(
        currentIndex: 0,
        onHomeTap: () => Navigator.pop(context),
        onLocaleChange: widget.onLocaleChange,
        onResultsTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResultsHistoryScreen(
                language: _language,
                onLocaleChange: widget.onLocaleChange,
              ),
            ),
          );
        },
        onLanguageChange: (language) {
          setState(() {
            _language = language;
            _status = _l10n.tapMicStart;
          });
          _speakPrompt();
        },
      ),
    );
  }
}
