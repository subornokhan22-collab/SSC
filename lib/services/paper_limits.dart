/// Hard safety limits for the local paper composer. These are not plan
/// entitlements; every plan shares them to prevent accidental huge requests.
class PaperLimits {
  static const maxMcq = 100;
  static const maxSaq = 30;
  static const maxCq = 15;
  static const maxTotalQuestions = maxMcq + maxSaq + maxCq;

  static bool validCounts({
    required int mcq,
    required int saq,
    required int cq,
  }) {
    if (mcq < 0 || mcq > maxMcq) return false;
    if (saq < 0 || saq > maxSaq) return false;
    if (cq < 0 || cq > maxCq) return false;
    return mcq + saq + cq <= maxTotalQuestions;
  }

  static String message({
    required int mcq,
    required int saq,
    required int cq,
  }) {
    if (mcq > maxMcq) return 'A paper supports at most $maxMcq MCQs.';
    if (saq > maxSaq)
      return 'A paper supports at most $maxSaq short questions.';
    if (cq > maxCq)
      return 'A paper supports at most $maxCq creative questions.';
    return 'This paper exceeds the supported question count.';
  }
}
