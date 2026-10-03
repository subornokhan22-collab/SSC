// Keep behavior aligned with AiTextFormatter and the shared fixture suite.
export function formatAiText(text: string): string {
  let s = text.replace(/[০-৯]/g, d => String('০১২৩৪৫৬৭৮৯'.indexOf(d)));
  s = s.replace(/\\frac\{([^{}]+)\}\{([^{}]+)\}/g, '($1)/($2)')
    .replace(/\\sqrt\{([^{}]+)\}/g, '√($1)')
    .replace(/\\(?:mathrm|text)\{([^{}]*)\}/g, '$1');
  const symbols: Record<string,string> = {times:'×',cdot:'·',div:'÷',pm:'±',minus:'−',leq:'≤',geq:'≥',neq:'≠',pi:'π',theta:'θ',alpha:'α',beta:'β',Delta:'Δ',Omega:'Ω',mu:'μ'};
  s = s.replace(/\\([A-Za-z]+)\b/g, (all, cmd) => symbols[cmd] ?? all)
    .replace(/\$\$([^$]+)\$\$|\$([^$\n]+)\$(?![0-9])/g, (_all, a, b) => a ?? b)
    .replace(/\\\((.*?)\\\)|\\\[(.*?)\\\]/gs, (_all, a, b) => a ?? b)
    .replace(/^\*\*([^*\n]+)\*\*/gm, '$1');
  s = s.replace(/([\^_])(?:\{([^{}]+)\}|\(([^()]+)\)|([+−-]?[A-Za-z0-9]+(?:\.[0-9]+)?))/g, (all, op, a, b, c) => {
    const run = (a ?? b ?? c).replace(/−/g, '-');
    const plain = op === '^' ? '0123456789+-=()nmi' : '0123456789+-=()aehijklmnoprstuvx';
    const mapped = op === '^' ? '⁰¹²³⁴⁵⁶⁷⁸⁹⁺⁻⁼⁽⁾ⁿᵐⁱ' : '₀₁₂₃₄₅₆₇₈₉₊₋₌₍₎ₐₑₕᵢⱼₖₗₘₙₒₚᵣₛₜᵤᵥₓ';
    if ([...run].some(ch => !plain.includes(ch))) return all;
    return [...run].map(ch => mapped[plain.indexOf(ch)]).join('');
  });
  return s.trim();
}
