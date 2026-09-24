import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/omr/omr_store.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

/// OMR class analytics built from the on-device scan history:
/// overview, subject-wise breakdown, a class leaderboard (top scorers
/// across every saved scan) and the most-missed questions per paper.
class OMrAnalyticsScreen extends StatefulWidget {
  const OMrAnalyticsScreen({super.key});

  @override
  State<OMrAnalyticsScreen> createState() => _OMrAnalyticsScreenState();
}

class _OMrAnalyticsScreenState extends State<OMrAnalyticsScreen> {
  List<OmScanRecord>? _records;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await OmrStore.loadHistory();
    if (!mounted) return;
    setState(() => _records = r);
  }

  @override
  Widget build(BuildContext context) {
    final records = _records;
    return Scaffold(
      appBar: AppBar(title: const Text('OMR Analytics')),
      body: SafeArea(
        child: records == null
            ? const Center(child: CircularProgressIndicator())
            : records.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                          'No scans yet. Grade OMR sheets from the OMR Scanner and their results will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.muted)),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                      children: [
                        _overview(records),
                        const SizedBox(height: 12),
                        _bySubject(records),
                        const SizedBox(height: 12),
                        _leaderboard(records),
                        const SizedBox(height: 12),
                        _mostMissed(records),
                      ],
                    ),
                  ),
      ),
    );
  }

  // ── overview ────────────────────────────────────────────────────────

  Widget _overview(List<OmScanRecord> r) {
    var scoreSum = 0, pctSum = 0.0, best = 0.0, durSum = 0;
    for (final x in r) {
      scoreSum += x.score;
      final pct = x.total == 0 ? 0.0 : x.score * 100.0 / x.total;
      pctSum += pct;
      if (pct > best) best = pct;
      durSum += x.durationMs;
    }
    final avgPct = pctSum / r.length;
    final avgSec = durSum / 1000.0 / r.length;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _head('Overview', Icons.summarize_rounded),
          const SizedBox(height: 10),
          Row(children: [
            _stat('${r.length}', 'scans'),
            _stat('${avgPct.toStringAsFixed(1)}%', 'avg score'),
            _stat('${best.toStringAsFixed(0)}%', 'best'),
            if (avgSec > 0) _stat('${avgSec.toStringAsFixed(1)}s', 'avg scan'),
          ]),
        ],
      ),
    );
  }

  // ── subject-wise ────────────────────────────────────────────────────

  Widget _bySubject(List<OmScanRecord> r) {
    final bySubject = <String, List<OmScanRecord>>{};
    for (final x in r) {
      bySubject
          .putIfAbsent(x.subjectName.isEmpty ? '—' : x.subjectName, () => [])
          .add(x);
    }
    final rows = bySubject.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _head('By subject', Icons.menu_book_rounded),
          const SizedBox(height: 10),
          for (final e in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Expanded(
                  flex: 3,
                  child: Text(e.key,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('${e.value.length} scans',
                      style:
                          const TextStyle(fontSize: 12, color: AppTheme.muted)),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${(_avgPct(e.value)).toStringAsFixed(1)}%',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _avgPct(e.value) >= 50
                            ? AppTheme.success
                            : AppTheme.warning),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'best ${(_bestPct(e.value)).toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                  ),
                ),
              ]),
            ),
        ],
      ),
    );
  }

  // ── leaderboard ─────────────────────────────────────────────────────

  Widget _leaderboard(List<OmScanRecord> r) {
    final ranked = r.toList()
      ..sort((a, b) {
        final pa = a.total == 0 ? 0.0 : a.score * 100.0 / a.total;
        final pb = b.total == 0 ? 0.0 : b.score * 100.0 / b.total;
        return pb.compareTo(pa);
      });
    final top = ranked.take(10).toList();
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _head('Leaderboard', Icons.emoji_events_rounded),
          const SizedBox(height: 2),
          const Text('Top 10 across all saved scans on this device',
              style: TextStyle(fontSize: 11, color: AppTheme.muted)),
          const SizedBox(height: 8),
          for (var i = 0; i < top.length; i++) _leaderRow(i + 1, top[i]),
        ],
      ),
    );
  }

  Widget _leaderRow(int rank, OmScanRecord x) {
    final pct = x.total == 0 ? 0.0 : x.score * 100.0 / x.total;
    final medals = {
      1: const Color(0xFFE8B93C),
      2: const Color(0xFFB8C2D2),
      3: const Color(0xFFC98A4B)
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: medals[rank] ?? AppTheme.border,
          ),
          alignment: Alignment.center,
          child: Text('$rank',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(x.roll.isEmpty ? 'Roll —' : 'Roll ${x.roll}',
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w800)),
              Text(
                  '${x.paperTitle.isEmpty ? '—' : x.paperTitle}${x.subjectName.isEmpty ? '' : ' • ${x.subjectName}'}',
                  style: const TextStyle(fontSize: 10.5, color: AppTheme.muted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${x.score}/${x.total}',
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary)),
            Text(
                '${pct.toStringAsFixed(1)}%   '
                'C${x.correct} W${x.wrong} B${x.blank}${x.ambiguous > 0 ? ' D${x.ambiguous}' : ''}',
                style: const TextStyle(fontSize: 10, color: AppTheme.muted)),
          ],
        ),
      ]),
    );
  }

  // ── most missed questions ───────────────────────────────────────────

  Widget _mostMissed(List<OmScanRecord> r) {
    // Aggregate per paper: attempts + correct per question number.
    final byPaper = <String, List<OmScanRecord>>{};
    for (final x in r) {
      byPaper
          .putIfAbsent(x.paperTitle.isEmpty ? '—' : x.paperTitle, () => [])
          .add(x);
    }
    final papers = byPaper.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));
    final shown = papers.take(4).toList();

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _head('Most missed questions', Icons.help_outline_rounded),
          const SizedBox(height: 2),
          const Text(
              'Questions with the lowest correct rate (needs at least 2 attempts).',
              style: TextStyle(fontSize: 11, color: AppTheme.muted)),
          const SizedBox(height: 8),
          for (final e in shown) _missedBlock(e.key, e.value),
        ],
      ),
    );
  }

  Widget _missedBlock(String paper, List<OmScanRecord> recs) {
    final attempts = <int, int>{};
    final correct = <int, int>{};
    var maxNo = 0;
    for (final x in recs) {
      final n = math.min(x.answers.length, x.key.length);
      for (var i = 0; i < n; i++) {
        final no = i + 1;
        if (no > maxNo) maxNo = no;
        attempts[no] = (attempts[no] ?? 0) + 1;
        if (x.answers[i] == x.key[i]) correct[no] = (correct[no] ?? 0) + 1;
      }
    }
    final missed = <(int, int, int)>[]; // (no, correct, attempts)
    for (var no = 1; no <= maxNo; no++) {
      final a = attempts[no] ?? 0;
      if (a < 2) continue;
      missed.add((no, correct[no] ?? 0, a));
    }
    missed.sort((a, b) => (a.$2 / a.$3).compareTo(b.$2 / b.$3));
    if (missed.isEmpty) return const SizedBox.shrink();
    final top = missed.take(6).toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(paper,
              style:
                  const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final m in top)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      m.$2 == 0 ? const Color(0x22E5484D) : AppTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: m.$2 == 0
                          ? const Color(0xFFE5484D).withOpacity(.5)
                          : AppTheme.border),
                ),
                child: Text('Q${m.$1}  ${m.$2}/${m.$3}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: m.$2 == 0
                            ? const Color(0xFFE5484D)
                            : AppTheme.textDark)),
              ),
          ]),
        ],
      ),
    );
  }

  // ── helpers ─────────────────────────────────────────────────────────

  double _avgPct(List<OmScanRecord> r) {
    if (r.isEmpty) return 0;
    var s = 0.0;
    for (final x in r) {
      s += x.total == 0 ? 0.0 : x.score * 100.0 / x.total;
    }
    return s / r.length;
  }

  double _bestPct(List<OmScanRecord> r) {
    var best = 0.0;
    for (final x in r) {
      final p = x.total == 0 ? 0.0 : x.score * 100.0 / x.total;
      if (p > best) best = p;
    }
    return best;
  }

  Widget _head(String title, IconData icon) => Row(children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 8),
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800))),
      ]);

  Widget _stat(String value, String label) => Expanded(
        child: Column(children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 10.5, color: AppTheme.muted)),
        ]),
      );
}
