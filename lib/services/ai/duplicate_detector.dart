import '../../data/questions_data.dart';

/// One near-duplicate finding.
class DuplicateHit {
  /// The generated question that looks like a copy.
  final Question generated;
  /// The bank question it resembles.
  final Question source;
  /// 0.0 (unrelated) … 1.0 (identical after normalization).
  final double similarity;

  const DuplicateHit(this.generated, this.source, this.similarity);
}

/// Near-duplicate detection for AI-generated questions (review item #5).
///
/// The prompt asking the model to "make different questions every time"
/// is not enforcement. Before generated questions are accepted they are
/// compared against the existing bank, previous AI questions and the
/// current paper — with similarity, not just exact text equality, so
/// "Photosynthesis occurs mainly in…" vs "Where does photosynthesis
/// primarily occur?" is caught as effectively the same question.
class DuplicateDetector {
  DuplicateDetector._();

  /// Jaccard similarity over normalized word tokens (order-independent,
  /// so rewording that keeps the words still scores high).
  static double similarity(String a, String b) {
    final ta = _tokens(a);
    final tb = _tokens(b);
    if (ta.isEmpty || tb.isEmpty) return 0;
    final inter = ta.intersection(tb).length;
    final uni = ta.union(tb).length;
    return uni == 0 ? 0 : inter / uni;
  }

  /// Two questions are "the same" above this similarity. 0.75 catches
  /// light rephrasing without flagging two questions that merely share
  /// the topic's vocabulary.
  static const double defaultThreshold = 0.75;

  static bool isDuplicate(String a, String b,
      {double threshold = defaultThreshold}) {
    final na = _norm(a);
    final nb = _norm(b);
    if (na.isEmpty) return false;
    if (na == nb) return true;
    return similarity(na, nb) >= threshold;
  }

  /// Compares every generated question against [bank] (existing bank
  /// rows, previous AI questions, the current paper — caller's choice).
  /// Returns only the hits above [threshold], best match first per
  /// generated question.
  static List<DuplicateHit> findDuplicates(
    List<Question> generated,
    Iterable<Question> bank, {
    double threshold = defaultThreshold,
  }) {
    final bankList = bank.toList();
    final hits = <DuplicateHit>[];
    for (final g in generated) {
      Question? best;
      var bestScore = 0.0;
      for (final b in bankList) {
        final s = isDuplicateFast(g.questionText, b.questionText, threshold)
            ? similarity(g.questionText, b.questionText)
            : 0.0;
        if (s >= threshold && s > bestScore) {
          bestScore = s;
          best = b;
        }
      }
      if (best != null) {
        hits.add(DuplicateHit(g, best, bestScore));
      }
    }
    return hits;
  }

  /// Cheap pre-filter before the Jaccard pass (token-count gate) —
  /// similarity can only exceed [threshold] when the token sets overlap
  /// a lot, which is impossible for very different lengths.
  static bool isDuplicateFast(String a, String b, double threshold) {
    final ta = _tokens(a);
    final tb = _tokens(b);
    if (ta.isEmpty || tb.isEmpty) return false;
    final minLen = ta.length < tb.length ? ta.length : tb.length;
    final maxLen = ta.length > tb.length ? ta.length : tb.length;
    // max(inter) ≤ minLen; need inter/union ≥ t  ⇒  minLen/maxLen ≥ t
    return minLen / maxLen >= threshold * 0.9;
  }

  static Set<String> _tokens(String s) =>
      _norm(s).split(' ').where((w) => w.isNotEmpty).toSet();

  static String _norm(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\u0980-\u09FF]+'), ' ').trim();
}
