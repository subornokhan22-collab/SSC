/// Subject catalogue used across the teacher paper builders.
/// Extracted from the old student 'subjects' screen so the teacher
/// portal owns this data on its own.

enum SubjectGroup { science, general, business, humanities }

class SubjectInfo {
  final String id;
  final String name;
  final String bengaliName;
  final String icon;
  final int colorHex;
  final SubjectGroup group;

  const SubjectInfo({
    required this.id,
    required this.name,
    required this.bengaliName,
    required this.icon,
    required this.colorHex,
    required this.group,
  });
}

const List<SubjectInfo> allSubjects = [
  // Only the subjects with a question bank are offered. The others were
  // removed along with their questions; add them back here if their banks
  // are ever restored.

  SubjectInfo(
      id: 'physics',
      name: 'Physics',
      bengaliName: 'পদার্থবিজ্ঞান',
      icon: '⚛️',
      colorHex: 0xFF1A82BB,
      group: SubjectGroup.science),

  SubjectInfo(
      id: 'chemistry',
      name: 'Chemistry',
      bengaliName: 'রসায়ন',
      icon: '🧪',
      colorHex: 0xFF2E7D32,
      group: SubjectGroup.science),

  SubjectInfo(
      id: 'higher_math',
      name: 'Higher Math',
      bengaliName: 'উচ্চতর গণিত',
      icon: '📐',
      colorHex: 0xFF6A1B9A,
      group: SubjectGroup.science),

  SubjectInfo(
      id: 'biology',
      name: 'Biology',
      bengaliName: 'জীববিজ্ঞান',
      icon: '🧬',
      colorHex: 0xFFD84315,
      group: SubjectGroup.science),

  SubjectInfo(
      id: 'general_math',
      name: 'General Math',
      bengaliName: 'গণিত',
      icon: '🔢',
      colorHex: 0xFF0288D1,
      group: SubjectGroup.general),

];

/// Convenience lookup used by the paper builders.
SubjectInfo? subjectById(String? id) {
  if (id == null) return null;
  for (final s in allSubjects) {
    if (s.id == id) return s;
  }
  return null;
}
