import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../constants/app_colors.dart';
import '../painters/bg_decoration_painter.dart';
import '../services/nlp_api_service.dart';

class SpeechSymptomScreen extends StatefulWidget {
  final String language;

  const SpeechSymptomScreen({super.key, required this.language});

  @override
  State<SpeechSymptomScreen> createState() => _SpeechSymptomScreenState();
}

class _SpeechSymptomScreenState extends State<SpeechSymptomScreen> {
  stt.SpeechToText _speech = stt.SpeechToText();

  bool _isListening = false;
  bool _isSending = false;
  String _spokenText = '';
  String _status = 'Tap the microphone to start';

  String get _languageName {
    return widget.language == 'yolngu' ? 'Yolŋu' : 'English';
  }

  String get _localeId {
    // Android/iOS speech may not support Yolŋu.
    // Use English recognition, then send language='yolngu' to your backend.
    return 'en_US';
  }

  Future<void> _startListening() async {
    if (_isListening) return;

    if (!mounted) return;

    setState(() {
      _spokenText = '';
      _status = 'Preparing microphone...';
    });

    final available = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;

        if (status == 'done' || status == 'notListening') {
          setState(() {
            _isListening = false;
            _status = _spokenText.trim().isEmpty
                ? 'Tap microphone to try again'
                : 'Tap microphone to speak again';
          });
        }
      },
      onError: (error) {
        if (!mounted) return;

        setState(() {
          _isListening = false;
          _status = 'Mic error: ${error.errorMsg}';
        });
      },
    );

    if (!mounted) return;

    if (!available) {
      setState(() {
        _status = 'Speech is not available';
      });
      return;
    }

    setState(() {
      _isListening = true;
      _status = 'Listening...';
    });

    await _speech.listen(
      localeId: 'en_US',
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
        }
      },
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();

    if (!mounted) return;

    setState(() {
      _isListening = false;
      _status = _spokenText.trim().isEmpty
          ? 'Tap microphone to try again'
          : 'Tap microphone to speak again';
    });
  }

  Future<void> _sendToApi() async {
    if (_spokenText.trim().isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      final result = await NlpApiService.triage(
        text: _spokenText,
        language: widget.language,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Triage Result'),
          content: Text(
            'Language: $_languageName\n\n'
            'Symptoms: ${result['symptoms']}\n\n'
            'Severity: ${result['severity']}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('API Error: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }

  bool get _hasText => _spokenText.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: BgDecorationPainter(),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: kBrown,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Language: $_languageName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  GestureDetector(
                    onTap: _isListening ? _stopListening : _startListening,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            color: kBrownLight.withOpacity(0.18),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 195,
                          height: 195,
                          decoration: BoxDecoration(
                            color: kBrownLight.withOpacity(0.28),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 130,
                          height: 130,
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
                            size: 64,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 34),

                  Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: kTextDark,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kBrown, width: 1.4),
                    ),
                    child: Text(
                      _spokenText.trim().isEmpty
                          ? 'Example: I have headache and fever'
                          : _spokenText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _spokenText.trim().isEmpty
                            ? kTextGrey
                            : kTextDark,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.35,
                      ),
                    ),
                  ),

                  const Spacer(),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 58,
                          child: ElevatedButton(
                            onPressed: () async {
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
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: SizedBox(
                          height: 58,
                          child: ElevatedButton(
                            onPressed: _hasText && !_isSending
                                ? _sendToApi
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kBrown,
                              disabledBackgroundColor: kBrownLight.withOpacity(
                                0.55,
                              ),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              _isSending ? 'Checking...' : 'Done',
                              style: const TextStyle(
                                fontSize: 18,
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
          ),
        ],
      ),
    );
  }
}
