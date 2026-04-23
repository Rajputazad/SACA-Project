import 'package:flutter/material.dart';
import 'package:casa_app/ language_screen.dart';

void main() {
  runApp(const SacaApp());
}

class SacaApp extends StatelessWidget {
  const SacaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SACA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Georgia', useMaterial3: true),
      home: const WelcomeScreen(),
    );
  }
}

// ─── Colors ─────────────────────────────────────────────────────
const Color kAccentRed = Color(0xFFBF4A28);
const Color kButtonRed = Color(0xFFCC5533);

// ─── Welcome Screen ─────────────────────────────────────────────
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final AnimationController _slideCtrl;

  late final Animation<double> _logoFade;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _buttonFade;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _logoFade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

    _titleFade = CurvedAnimation(
      parent: _slideCtrl,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _slideCtrl,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
          ),
        );

    _buttonFade = CurvedAnimation(
      parent: _slideCtrl,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeCtrl.forward();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      _slideCtrl.forward();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
  
          Image.asset(
            'assets/images/bg.png', // 🔥 your image path
            fit: BoxFit.cover,
          ),

         
          Container(color: Colors.black.withOpacity(0.3)),

          // ── UI CONTENT ─────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Logo
                FadeTransition(
                  opacity: _logoFade,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: kAccentRed,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // App name
                FadeTransition(
                  opacity: _logoFade,
                  child: const Text(
                    'SACA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                    ),
                  ),
                ),

                const Spacer(),

                // Welcome Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      SlideTransition(
                        position: _titleSlide,
                        child: FadeTransition(
                          opacity: _titleFade,
                          child: const Text(
                            'Welcome',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 44,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      FadeTransition(
                        opacity: _titleFade,
                        child: const Text(
                          'Connecting community and health together.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Start Button
                      FadeTransition(
                        opacity: _buttonFade,
                        child: SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LanguageScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kButtonRed,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
