import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../painters/bg_decoration_painter.dart';
import '../services/result_history_service.dart';
import '../widgets/bottom_nav.dart';
import 'results_screen.dart';

class ResultsHistoryScreen extends StatefulWidget {
  final String language;
  final ValueChanged<Locale>? onLocaleChange;

  const ResultsHistoryScreen({
    super.key,
    required this.language,
    this.onLocaleChange,
  });

  @override
  State<ResultsHistoryScreen> createState() => _ResultsHistoryScreenState();
}

class _ResultsHistoryScreenState extends State<ResultsHistoryScreen> {
  late Future<List<ResultHistoryItem>> _resultsFuture;

  @override
  void initState() {
    super.initState();
    _resultsFuture = ResultHistoryService.all();
  }

  void _reload() {
    setState(() {
      _resultsFuture = ResultHistoryService.all();
    });
  }

  String _dateLabel(String isoDate) {
    final date = DateTime.tryParse(isoDate)?.toLocal();
    if (date == null) return '';
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day}/${date.month}/${date.year} $hour:$minute';
  }

  Color _severityColor(String severity) {
    final value = severity.toLowerCase();
    if (value.contains('severe') || value.contains('high')) {
      return const Color(0xFFC84D3F);
    }
    if (value.contains('moderate') || value.contains('attention')) {
      return const Color(0xFFC77738);
    }
    return const Color(0xFF3F914A);
  }

  Future<void> _delete(ResultHistoryItem item) async {
    await ResultHistoryService.delete(item.id);
    if (!mounted) return;
    _reload();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Result deleted')));
  }

  void _open(ResultHistoryItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultsScreen(
          language: widget.language,
          onLocaleChange: widget.onLocaleChange,
          result: TriageResultData.fromApi(item.rawResult),
        ),
      ),
    );
  }

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
            child: FutureBuilder<List<ResultHistoryItem>>(
              future: _resultsFuture,
              builder: (context, snapshot) {
                final results = snapshot.data ?? const <ResultHistoryItem>[];

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Previous results',
                              style: TextStyle(
                                color: kTextDark,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                            ),
                          ),
                          IconButton.filledTonal(
                            onPressed: _reload,
                            icon: const Icon(Icons.refresh_rounded),
                            color: kBrown,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child:
                            snapshot.connectionState == ConnectionState.waiting
                            ? const Center(child: CircularProgressIndicator())
                            : results.isEmpty
                            ? const _EmptyHistory()
                            : ListView.separated(
                                itemCount: results.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final item = results[index];
                                  final severityColor = _severityColor(
                                    item.predictedSeverity,
                                  );
                                  return Dismissible(
                                    key: ValueKey(item.id),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      decoration: BoxDecoration(
                                        color: kAccentRed,
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      child: const Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                    confirmDismiss: (_) async {
                                      await _delete(item);
                                      return false;
                                    },
                                    child: _ResultHistoryCard(
                                      item: item,
                                      dateLabel: _dateLabel(item.createdAt),
                                      severityColor: severityColor,
                                      onTap: () => _open(item),
                                      onDelete: () => _delete(item),
                                    ),
                                  );
                                },
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
        onHomeTap: () => Navigator.pop(context),
        onLocaleChange: widget.onLocaleChange,
      ),
    );
  }
}

class _ResultHistoryCard extends StatelessWidget {
  final ResultHistoryItem item;
  final String dateLabel;
  final Color severityColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ResultHistoryCard({
    required this.item,
    required this.dateLabel,
    required this.severityColor,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final title = item.symptoms.trim().isEmpty ? item.inputText : item.symptoms;

    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  item.predictedSeverity.toLowerCase().contains('severe')
                      ? '!'
                      : item.predictedSeverity.toLowerCase().contains(
                          'moderate',
                        )
                      ? '~'
                      : '+',
                  style: TextStyle(
                    color: severityColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: kTextDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${item.predictedSeverity} • $dateLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: kTextGrey,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                color: kAccentRed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.description_outlined, color: kBrown, size: 54),
            SizedBox(height: 12),
            Text(
              'No previous results yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kTextDark,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Submit symptoms first, then results will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kTextGrey, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
