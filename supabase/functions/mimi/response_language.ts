export class ResponseLanguageError extends Error {}

export function isEnglishSubject(subjectId: string): boolean {
  return subjectId === "english_1st" || subjectId === "english_2nd";
}

export function responseLanguageInstruction(subjectId: string): string {
  const prose = isEnglishSubject(subjectId)
    ? "OUTPUT LANGUAGE: English. This is an English subject. Write questions, prose choices, explanations, checker reasons, review summaries and findings in English, not Bengali."
    : "OUTPUT LANGUAGE: Bengali (বাংলা). This is NOT an English subject. Write every question, prose choice, explanation, checker reason, review summary and finding in natural Bengali. Do NOT write English sentences or translate the answer into English, even if the reference files or user instructions are English. Standard scientific symbols, units, formulas, abbreviations and proper names may remain Latin. English digits do NOT mean English prose.";
  return prose + " NUMERALS ONLY: use English digits 0-9, NOT Bengali digits ০-৯. Digit style must not change the OUTPUT LANGUAGE above. Keep supplied chapter metadata and JSON field names/enum values unchanged.";
}

/** Script/language guard, not a translator. Allows formulas, units and names,
 * but rejects missing target-language prose and obvious foreign sentences. */
export function assertResponseLanguage(text: string, subjectId: string, requireProse = false): void {
  const bengali = /[\u0985-\u09b9\u09ce\u09dc-\u09df\u09f0-\u09f1]/;
  const english = /[A-Za-z]/;
  if (isEnglishSubject(subjectId)) {
    if ((requireProse && !english.test(text)) || bengali.test(text)) {
      throw new ResponseLanguageError("Expected English prose for an English subject.");
    }
    return;
  }
  if (requireProse && !bengali.test(text)) {
    throw new ResponseLanguageError("Expected Bengali prose; English digits must not change the language.");
  }
  for (const sentence of text.split(/[.!?।\n]+/)) {
    // Three or more Latin words generally indicate prose rather than kg/m²,
    // F = ma, SI, NaCl, Newton, etc. Mixed scientific Bengali remains valid.
    if (!bengali.test(sentence) && (sentence.match(/[A-Za-z]{2,}/g)?.length ?? 0) >= 3) {
      throw new ResponseLanguageError("An English sentence appeared in a Bengali response.");
    }
  }
}
