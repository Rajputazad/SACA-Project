import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../painters/bg_decoration_painter.dart';
import '../widgets/bottom_nav.dart';

class TriageResultData {
  final String inputText;
  final String detectedLanguage;
  final List<String> inputSymptoms;
  final String predictedSeverity;
  final int? triageLevel;
  final List<String> suggestion;
  final List<String> importantDetails;

  const TriageResultData({
    required this.inputText,
    required this.detectedLanguage,
    required this.inputSymptoms,
    required this.predictedSeverity,
    required this.triageLevel,
    required this.suggestion,
    required this.importantDetails,
  });

  factory TriageResultData.fromApi(Map<String, dynamic> json) {
    List<String> readList(String key) {
      final value = json[key];
      if (value is List) return value.map((item) => item.toString()).toList();
      if (value is String && value.trim().isNotEmpty) return [value.trim()];
      return const [];
    }

    return TriageResultData(
      inputText: (json['input_text'] ?? json['processed_text'] ?? '')
          .toString(),
      detectedLanguage: (json['detected_language'] ?? 'auto').toString(),
      inputSymptoms: readList('input_symptoms'),
      predictedSeverity: (json['predicted_severity'] ?? 'Needs attention')
          .toString(),
      triageLevel: json['triage_level'] is num
          ? (json['triage_level'] as num).round()
          : int.tryParse((json['triage_level'] ?? '').toString()),
      suggestion: readList('suggestion').isNotEmpty
          ? readList('suggestion')
          : readList('suggestions'),
      importantDetails: readList('important_details').isNotEmpty
          ? readList('important_details')
          : readList('importantDetails'),
    );
  }

  String get symptomSummary {
    if (inputSymptoms.isNotEmpty) return inputSymptoms.join(', ');
    if (inputText.trim().isNotEmpty) return inputText.trim();
    return 'Reported symptoms';
  }
}

class ResultsScreen extends StatelessWidget {
  final String language;
  final ValueChanged<Locale>? onLocaleChange;
  final TriageResultData result;

  const ResultsScreen({
    super.key,
    required this.language,
    this.onLocaleChange,
    this.result = const TriageResultData(
      inputText: 'I have fever, cough and headache',
      detectedLanguage: 'english',
      inputSymptoms: ['headache', 'cough', 'fever'],
      predictedSeverity: 'Moderate',
      triageLevel: 2,
      suggestion: ['Consult a healthcare provider within 24-48 hours.'],
      importantDetails: [
        'Matched symptoms are normalized to the trained model vocabulary.',
        'For emergency warning signs such as chest pain, trouble breathing, collapse, or severe bleeding, seek urgent care immediately.',
      ],
    ),
  });

  String _mainEmoji(String text) {
    final value = text.toLowerCase();
    if (value.contains('fever') ||
        value.contains('flu') ||
        value.contains('cold')) {
      return '🤒';
    }
    if (value.contains('head') ||
        value.contains('migraine') ||
        value.contains('dizz')) {
      return '🤕';
    }
    if (value.contains('cough') ||
        value.contains('breath') ||
        value.contains('chest')) {
      return '🫁';
    }
    if (value.contains('stomach') ||
        value.contains('nausea') ||
        value.contains('diarr')) {
      return '🤢';
    }
    if (value.contains('skin') ||
        value.contains('rash') ||
        value.contains('burn')) {
      return '🩹';
    }
    if (value.contains('anxiety') ||
        value.contains('depression') ||
        value.contains('stress')) {
      return '🧠';
    }
    if (value.contains('pain') ||
        value.contains('joint') ||
        value.contains('back')) {
      return '💪';
    }
    return '🩺';
  }

  String _stepEmoji(String text) {
    final value = text.toLowerCase();
    if (value.contains('water') || value.contains('drink')) {
      return '💧';
    }
    if (value.contains('rest') || value.contains('sleep')) {
      return '🛏️';
    }
    if (value.contains('warm') || value.contains('comfortable')) {
      return '🧥';
    }
    if (value.contains('monitor') || value.contains('watch')) {
      return '📈';
    }
    if (value.contains('medicine') || value.contains('tablet')) {
      return '💊';
    }
    if (value.contains('doctor') || value.contains('health worker')) {
      return '👩‍⚕️';
    }
    if (value.contains('food') || value.contains('eat')) {
      return '🍲';
    }
    return '✅';
  }

  Color _severityColor(String severity) {
    final value = severity.toLowerCase();
    if (value.contains('emergency') ||
        value.contains('severe') ||
        value.contains('high')) {
      return const Color(0xFFC84D3F);
    }
    if (value.contains('moderate') || value.contains('attention')) {
      return const Color(0xFFC77738);
    }
    return const Color(0xFF3F914A);
  }

  void _goHome(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = _severityColor(result.predictedSeverity);
    final mainEmoji = _mainEmoji(
      '${result.symptomSummary} ${result.predictedSeverity}',
    );

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
                final compact = constraints.maxHeight < 720;
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(22, compact ? 18 : 28, 22, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your results',
                        style: TextStyle(
                          color: kTextDark,
                          fontSize: compact ? 42 : 52,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 26),
                      _ConditionCard(
                        emoji: mainEmoji,
                        symptoms: result.symptomSummary,
                        severity: result.predictedSeverity,
                        triageLevel: result.triageLevel,
                        detectedLanguage: result.detectedLanguage,
                        severityColor: severityColor,
                      ),
                      const SizedBox(height: 24),
                      _SectionCard(
                        title: 'Suggestion',
                        child: Column(
                          children: result.suggestion
                              .map(
                                (step) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _StepTile(
                                    emoji: _stepEmoji(step),
                                    text: step,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _SectionCard(
                        title: 'Important details',
                        child: Column(
                          children: result.importantDetails
                              .map(
                                (detail) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _WarningBanner(text: detail),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Health worker call will be connected later',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.call_rounded, size: 30),
                          label: const Text('Call Health Worker'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF438F4D),
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: OutlinedButton.icon(
                          onPressed: () => _goHome(context),
                          icon: const Icon(Icons.home_outlined, size: 30),
                          label: const Text('Go to Home'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kTextDark,
                            side: BorderSide(
                              color: kBrownLight.withValues(alpha: 0.45),
                              width: 2,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SacaBottomNav(
        currentIndex: 1,
        onHomeTap: () => _goHome(context),
        onLocaleChange: onLocaleChange,
      ),
    );
  }
}

class _ConditionCard extends StatelessWidget {
  final String emoji;
  final String symptoms;
  final String severity;
  final int? triageLevel;
  final String detectedLanguage;
  final Color severityColor;

  const _ConditionCard({
    required this.emoji,
    required this.symptoms,
    required this.severity,
    required this.triageLevel,
    required this.detectedLanguage,
    required this.severityColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PREDICTED SEVERITY',
            style: TextStyle(
              color: kTextGrey.withValues(alpha: 0.9),
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 92,
                height: 92,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kBrownLight.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 46)),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      severity,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: kTextDark,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      symptoms,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: kTextGrey,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Language: $detectedLanguage',
                      style: const TextStyle(
                        color: kTextGrey,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: severityColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        triageLevel == null
                            ? severity
                            : '$severity • Level $triageLevel',
                        style: TextStyle(
                          color: severityColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(24),
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
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final String emoji;
  final String text;

  const _StepTile({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardSelected,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: kTextDark,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  final String text;

  const _WarningBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0E3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: kTextDark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
