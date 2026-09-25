/// Deterministic display/storage cleanup. Never guesses missing math symbols or
/// drops characters from an exponent it cannot represent in Unicode.
class AiTextFormatter {
  AiTextFormatter._();
  static const _digits = '০১২৩৪৫৬৭৮৯';
  static const _plain = '0123456789+-=()nmi';
  static const _sup = '⁰¹²³⁴⁵⁶⁷⁸⁹⁺⁻⁼⁽⁾ⁿᵐⁱ';
  static const _subPlain = '0123456789+-=()aehijklmnoprstuvx';
  static const _sub = '₀₁₂₃₄₅₆₇₈₉₊₋₌₍₎ₐₑₕᵢⱼₖₗₘₙₒₚᵣₛₜᵤᵥₓ';

  static String format(String text, {bool trim = true}) {
    var s = text.replaceAllMapped(
        RegExp('[০-৯]'), (m) => '${_digits.indexOf(m[0]!)}');
    s = s.replaceAllMapped(RegExp(r'\\frac\{([^{}]+)\}\{([^{}]+)\}'),
        (m) => '(${m[1]})/(${m[2]})');
    s = s.replaceAllMapped(RegExp(r'\\sqrt\{([^{}]+)\}'), (m) => '√(${m[1]})');
    s = s.replaceAllMapped(
        RegExp(r'\\(?:mathrm|text)\{([^{}]*)\}'), (m) => m[1]!);
    const symbols = {
      'times': '×',
      'cdot': '·',
      'div': '÷',
      'pm': '±',
      'minus': '−',
      'leq': '≤',
      'geq': '≥',
      'neq': '≠',
      'pi': 'π',
      'theta': 'θ',
      'alpha': 'α',
      'beta': 'β',
      'Delta': 'Δ',
      'Omega': 'Ω',
      'mu': 'μ'
    };
    s = s.replaceAllMapped(
        RegExp(r'\\([A-Za-z]+)\b'), (m) => symbols[m[1]] ?? m[0]!);
    s = s.replaceAllMapped(
        RegExp(r'\$\$([^$]+)\$\$|\$([^$\n]+)\$'), (m) => m[1] ?? m[2]!);
    s = s.replaceAllMapped(RegExp(r'\\\((.*?)\\\)|\\\[(.*?)\\\]', dotAll: true),
        (m) => m[1] ?? m[2]!);
    s = s.replaceAllMapped(RegExp(r'\*\*([^*]+)\*\*'), (m) => m[1]!);
    // Match an entire grouped/simple script. Unsupported runs remain intact.
    s = s.replaceAllMapped(
        RegExp(
            r'([\^_])(?:\{([^{}]+)\}|\(([^()]+)\)|([+−-]?[A-Za-z0-9]+(?:\.[0-9]+)?))'),
        (m) {
      final run = (m[2] ?? m[3] ?? m[4]!).replaceAll('−', '-');
      final plain = m[1] == '^' ? _plain : _subPlain;
      final mapped = m[1] == '^' ? _sup : _sub;
      if (run.split('').any((c) => !plain.contains(c))) return m[0]!;
      return run.split('').map((c) => mapped[plain.indexOf(c)]).join();
    });
    return trim ? s.trim() : s;
  }
}
