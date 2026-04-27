import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../painters/bg_decoration_painter.dart';
import '../widgets/bottom_nav.dart';
import 'body_map_screen.dart';
import 'package:casa_app/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

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
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 170,
          padding: const EdgeInsets.all(14),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: kBrownLight.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 34, color: kBrown),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: kTextDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: kTextGrey,
                  fontSize: 12,
                  height: 1.2,
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.howFeeling,
                    style: TextStyle(
                      color: kBrown,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Tell us how you feel',
                    style: TextStyle(color: kTextDark, fontSize: 15),
                  ),

                  const SizedBox(height: 18),

                  // MIC BUTTON
                  Center(
                    child: GestureDetector(
                      onTap: () => setState(() => _isListening = !_isListening),
                      child: AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (_, __) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.scale(
                                scale: _isListening ? _pulse.value : 1.0,
                                child: Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    color: kBrownLight.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: kBrownLight.withOpacity(0.22),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 105,
                                height: 105,
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
                                  _isListening ? Icons.mic : Icons.mic_none,
                                  color: Colors.white,
                                  size: 42,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Center(
                    child: Text(
                      _isListening
                          ? 'Listening...'
                          : 'Tap to speak your symptoms',
                      style: const TextStyle(
                        color: kTextDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),

                  // OPTION CARDS
                  Row(
                    children: [
                      _optionCard(
                        icon: Icons.keyboard_alt_outlined,
                        title: 'Type',
                        subtitle: 'Type your symptoms',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const BodyMapScreen(openKeyboard: true),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _optionCard(
                        icon: Icons.add_circle_outline,
                        title: 'Select',
                        subtitle: 'Choose from body map',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const BodyMapScreen(openKeyboard: false),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const SacaBottomNav(currentIndex: 0),
    );
  }
}
