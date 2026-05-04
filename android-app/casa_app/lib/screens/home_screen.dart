import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../painters/bg_decoration_painter.dart';
import '../widgets/bottom_nav.dart';
import 'body_map_screen.dart';
import 'package:casa_app/l10n/app_localizations.dart';
import 'speech_symptom_screen.dart';

class HomeScreen extends StatefulWidget {
  final String language;
  final ValueChanged<Locale> onLocaleChange;

  const HomeScreen({
    super.key,
    required this.language,
    required this.onLocaleChange,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;
  late String _language;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _language = widget.language;

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulse = Tween<double>(
      begin: 1.0,
      end: 1.06,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Widget _optionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool compact,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: compact ? 148 : 166,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14,
            vertical: compact ? 8 : 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: compact ? 48 : 58,
                height: compact ? 48 : 58,
                decoration: BoxDecoration(
                  color: kBrownLight.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: compact ? 26 : 30, color: kBrown),
              ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: kTextDark,
                  fontSize: compact ? 18 : 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kTextGrey,
                  fontSize: compact ? 12 : 13,
                  height: 1.12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 680;
                final micOuter = compact ? 138.0 : 180.0;
                final micMiddle = compact ? 108.0 : 140.0;
                final micInner = compact ? 82.0 : 105.0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 32,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.howFeeling,
                          style: TextStyle(
                            color: kBrown,
                            fontSize: compact ? 28 : 32,
                            fontWeight: FontWeight.w900,
                            height: 1.12,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          l10n.tellUsHowFeel,
                          style: const TextStyle(
                            color: kTextDark,
                            fontSize: 15,
                          ),
                        ),

                        SizedBox(height: compact ? 12 : 18),

                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      SpeechSymptomScreen(language: _language),
                                ),
                              );
                            },
                            child: AnimatedBuilder(
                              animation: _pulseCtrl,
                              builder: (_, __) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Transform.scale(
                                      scale: _isListening ? _pulse.value : 1.0,
                                      child: Container(
                                        width: micOuter,
                                        height: micOuter,
                                        decoration: BoxDecoration(
                                          color: kBrownLight.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: micMiddle,
                                      height: micMiddle,
                                      decoration: BoxDecoration(
                                        color: kBrownLight.withOpacity(0.22),
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
                                            color: kBrown.withOpacity(0.3),
                                            blurRadius: 18,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _isListening
                                            ? Icons.mic
                                            : Icons.mic_none,
                                        color: Colors.white,
                                        size: compact ? 34 : 42,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Center(
                          child: Text(
                            _isListening ? l10n.listening : l10n.tapToSpeak,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: kTextDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        SizedBox(height: compact ? 28 : 64),

                        Row(
                          children: [
                            _optionCard(
                              icon: Icons.keyboard_alt_outlined,
                              title: l10n.type,
                              subtitle: l10n.typeSymptoms,
                              compact: compact,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BodyMapScreen(
                                      openKeyboard: true,
                                      language: _language,
                                      onLocaleChange: widget.onLocaleChange,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            _optionCard(
                              icon: Icons.add_circle_outline,
                              title: l10n.select,
                              subtitle: l10n.chooseFromBodyMap,
                              compact: compact,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BodyMapScreen(
                                      openKeyboard: false,
                                      language: _language,
                                      onLocaleChange: widget.onLocaleChange,
                                    ),
                                  ),
                                );
                              },
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
