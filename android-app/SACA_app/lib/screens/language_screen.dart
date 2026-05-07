import 'package:flutter/material.dart';
import 'package:casa_app/l10n/app_localizations.dart';

import '../constants/app_colors.dart';
import '../painters/bg_decoration_painter.dart';
import 'home_screen.dart';

class LanguageScreen extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  const LanguageScreen({super.key, required this.onLocaleChange});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen>
    with SingleTickerProviderStateMixin {
  String _selectedLanguage = 'English';
  bool _agreeToShare = true;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _selectLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
    });

    if (language == 'English') {
      widget.onLocaleChange(const Locale('en'));
    } else {
      widget.onLocaleChange(const Locale('en', 'YN'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: kBackground,
      body: FadeTransition(
        opacity: _fade,
        child: Stack(
          children: [
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: BgDecorationPainter(),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 28),

                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: kBrown,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: kBrown.withOpacity(0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'SACA',
                      style: TextStyle(
                        color: kBrown,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 5,
                      ),
                    ),

                    const SizedBox(height: 36),

                    Text(
                      l10n.chooseLanguage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: kTextDark,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 36),

                    _languageCard(
                      title: 'English',
                      subtitle: l10n.easyToRead,
                      icon: Icons.chat_bubble_outline_rounded,
                      isSelected: _selectedLanguage == 'English',
                      onTap: () => _selectLanguage('English'),
                    ),

                    const SizedBox(height: 14),

                    _languageCard(
                      title: 'Yolŋu',
                      subtitle: l10n.localLanguage,
                      icon: Icons.people_outline_rounded,
                      isSelected: _selectedLanguage == 'Yolŋu',
                      onTap: () => _selectLanguage('Yolŋu'),
                    ),

                    const SizedBox(height: 36),

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _agreeToShare = !_agreeToShare;
                        });
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _agreeToShare
                                  ? kBrown
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: kBrown, width: 2),
                            ),
                            child: _agreeToShare
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              l10n.agreeHealthInfo,
                              style: const TextStyle(
                                color: kTextDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _agreeToShare
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HomeScreen(
                                      language: _selectedLanguage == 'Yolŋu'
                                          ? 'yolngu'
                                          : 'english',
                                      onLocaleChange: widget.onLocaleChange,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBrown,
                          disabledBackgroundColor: kBrownLight.withOpacity(0.5),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: kBrown.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          l10n.continueText,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _languageCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? kCardSelected : kCardUnselected,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? kBrown : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.08 : 0.04),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? kBrown : const Color(0xFFDDD0C0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : kTextGrey,
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: kTextDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(color: kTextGrey, fontSize: 14),
                  ),
                ],
              ),
            ),

            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? kBrown : const Color(0xFFE0D0BC),
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
