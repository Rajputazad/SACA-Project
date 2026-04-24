import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../painters/home_bg_painter.dart';

import '../widgets/bottom_nav.dart';

class BodyMapScreen extends StatefulWidget {
  const BodyMapScreen({super.key});

  @override
  State<BodyMapScreen> createState() => _BodyMapScreenState();
}

class _BodyMapScreenState extends State<BodyMapScreen> {
  void _showSymptomsSheet(String bodyPart) {
  final symptoms = _symptomsByBodyPart[bodyPart] ?? [];

  final Set<String> selectedSymptoms = {};

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: kBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'What are you feeling?',
                          style: const TextStyle(
                            color: kTextDark,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 30),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Chip(
                    label: Text(bodyPart),
                    backgroundColor: kBrownLight.withOpacity(0.3),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Type your symptom',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Expanded(
                    child: ListView.separated(
                      itemCount: symptoms.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final symptom = symptoms[index];
                        final selected =
                            selectedSymptoms.contains(symptom);

                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              if (selected) {
                                selectedSymptoms.remove(symptom);
                              } else {
                                selectedSymptoms.add(symptom);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 18,
                            ),
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
                                    symptom,
                                    style: const TextStyle(
                                      color: kTextDark,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Icon(
                                  selected
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: selected ? kBrown : kTextGrey,
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selected.addAll(selectedSymptoms);
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBrown,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Confirm selection',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
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
  final Set<String> _selected = {};
  final TextEditingController _searchCtrl = TextEditingController();

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
final Map<String, List<String>> _symptomsByBodyPart = {
  'Head': [
    'Headache',
    'Migraine',
    'Dizziness',
    'Blurred vision',
    'Eye pain',
    'Fever',
    'Confusion',
  ],
  'Neck': [
    'Neck pain',
    'Stiff neck',
    'Swelling',
    'Sore throat',
  ],
  'Chest': [
    'Chest pain',
    'Shortness of breath',
    'Cough',
    'Heartburn',
  ],
  'Abdomen': [
    'Stomach pain',
    'Nausea',
    'Vomiting',
    'Diarrhea',
    'Bloating',
  ],
  'Left Arm': [
    'Arm pain',
    'Weakness',
    'Numbness',
    'Swelling',
  ],
  'Right Arm': [
    'Arm pain',
    'Weakness',
    'Numbness',
    'Swelling',
  ],
  'Left Leg': [
    'Leg pain',
    'Knee pain',
    'Numbness',
    'Swelling',
  ],
  'Right Leg': [
    'Leg pain',
    'Knee pain',
    'Numbness',
    'Swelling',
  ],
  'Lower Back': [
    'Back pain',
    'Lower back pain',
    'Stiffness',
    'Pain while moving',
  ],
};
  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // void _onBodyTap(TapDownDetails details, BoxConstraints constraints) {
  //   final size = Size(constraints.maxWidth, constraints.maxHeight);

  //   final norm = Offset(
  //     details.localPosition.dx / size.width,
  //     details.localPosition.dy / size.height,
  //   );

  //   for (final entry in _bodyParts.entries) {
  //     if (entry.value.contains(norm)) {
  //       setState(() {
  //         if (_selected.contains(entry.key)) {
  //           _selected.remove(entry.key);
  //         } else {
  //           _selected.add(entry.key);
  //         }
  //       });
  //       break;
  //     }
  //   }
  // }
void _onBodyTap(TapDownDetails details, BoxConstraints constraints) {
  final size = Size(constraints.maxWidth, constraints.maxHeight);

  final norm = Offset(
    details.localPosition.dx / size.width,
    details.localPosition.dy / size.height,
  );

  for (final entry in _bodyParts.entries) {
    if (entry.value.contains(norm)) {
      _showSymptomsSheet(entry.key);
      break;
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: HomeBgPainter(),
          ),

          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: kTextGrey,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            decoration: const InputDecoration(
                              hintText: 'e.g., Headache',
                              hintStyle: TextStyle(color: kTextGrey),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.fromLTRB(32, 24, 32, 4),
                child: Text(
                  'Where do you feel\npain?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: kBrown,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
              ),

              const Text(
                'Select the body areas below',
                style: TextStyle(color: kTextDark, fontSize: 15),
              ),

              const SizedBox(height: 16),

              if (_selected.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    children: _selected
                        .map(
                          (part) => Chip(
                            label: Text(
                              part,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            backgroundColor: kBrown,
                            deleteIcon: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white70,
                            ),
                            onDeleted: () {
                              setState(() => _selected.remove(part));
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onTapDown: (details) =>
                            _onBodyTap(details, constraints),
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

              const SizedBox(height: 8),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const SacaBottomNav(currentIndex: 0),
    );
  }
}
