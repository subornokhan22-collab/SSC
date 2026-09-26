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

List<SubjectInfo> remoteSubjects = const [];
List<SubjectInfo> get allSubjects => [
      for (final s in bundledSubjects)
        if (!remoteSubjects.any((r) => r.id == s.id)) s,
      ...remoteSubjects
    ];
const List<SubjectInfo> bundledSubjects = [
  // ——— Science (with practical 75+25) ———
  SubjectInfo(
    id: 'physics',
    name: 'Physics',
    bengaliName: 'পদার্থবিজ্ঞান',
    icon: '⚛️',
    colorHex: 0xFF1A82BB,
    group: SubjectGroup.science,
  ),
  SubjectInfo(
    id: 'chemistry',
    name: 'Chemistry',
    bengaliName: 'রসায়ন',
    icon: '🧪',
    colorHex: 0xFF2E7D32,
    group: SubjectGroup.science,
  ),
  SubjectInfo(
    id: 'higher_math',
    name: 'Higher Math',
    bengaliName: 'উচ্চতর গণিত',
    icon: '📐',
    colorHex: 0xFF6A1B9A,
    group: SubjectGroup.science,
  ),
  SubjectInfo(
    id: 'biology',
    name: 'Biology',
    bengaliName: 'জীববিজ্ঞান',
    icon: '🧬',
    colorHex: 0xFFD84315,
    group: SubjectGroup.science,
  ),

  // ——— General (100 marks: 70 written + 30 MCQ) ———
  SubjectInfo(
    id: 'general_math',
    name: 'General Math',
    bengaliName: 'গণিত',
    icon: '🔢',
    colorHex: 0xFF0288D1,
    group: SubjectGroup.general,
  ),
  SubjectInfo(
    id: 'bangla_1st',
    name: 'Bangla 1st',
    bengaliName: 'বাংলা প্রথম পত্র',
    icon: '📚',
    colorHex: 0xFFC2185B,
    group: SubjectGroup.general,
  ),
  SubjectInfo(
    id: 'bangla_2nd',
    name: 'Bangla 2nd',
    bengaliName: 'বাংলা দ্বিতীয় পত্র',
    icon: '📖',
    colorHex: 0xFFAD1457,
    group: SubjectGroup.general,
  ),
  SubjectInfo(
    id: 'english_1st',
    name: 'English 1st',
    bengaliName: 'ইংরেজি ১ম পত্র',
    icon: '🔤',
    colorHex: 0xFF5D4037,
    group: SubjectGroup.general,
  ),
  SubjectInfo(
    id: 'english_2nd',
    name: 'English 2nd',
    bengaliName: 'ইংরেজি ২য় পত্র',
    icon: '📝',
    colorHex: 0xFF4E342E,
    group: SubjectGroup.general,
  ),
  SubjectInfo(
    id: 'bgs',
    name: 'BGS',
    bengaliName: 'বাংলাদেশ ও বিশ্বপরিচয়',
    icon: '🌏',
    colorHex: 0xFF00838F,
    group: SubjectGroup.general,
  ),
  SubjectInfo(
    id: 'religion',
    name: 'Religion & Moral Ed.',
    bengaliName: 'ইসলাম ও নৈতিক শিক্ষা',
    icon: '🕌',
    colorHex: 0xFF2E7D32,
    group: SubjectGroup.general,
  ),

  // ——— Business (from your PDF 2027 – Lalmonirhat) ———
  SubjectInfo(
    id: 'general_science',
    name: 'General Science',
    bengaliName: 'বিজ্ঞান',
    icon: '🔬',
    colorHex: 0xFF00695C,
    group: SubjectGroup.business,
  ), // 127
  SubjectInfo(
    id: 'agriculture',
    name: 'Agriculture',
    bengaliName: 'কৃষিশিক্ষা',
    icon: '🌾',
    colorHex: 0xFF33691E,
    group: SubjectGroup.business,
  ), // 134 – 50 theory +25 MCQ +25 practical
  SubjectInfo(
    id: 'business_ent',
    name: 'Business Entre.',
    bengaliName: 'ব্যবসায় উদ্যোগ',
    icon: '💼',
    colorHex: 0xFF4A148C,
    group: SubjectGroup.business,
  ), // 143
  SubjectInfo(
    id: 'accounting',
    name: 'Accounting',
    bengaliName: 'হিসাববিজ্ঞান',
    icon: '📊',
    colorHex: 0xFFE65100,
    group: SubjectGroup.business,
  ), // 146 – special compulsory
  SubjectInfo(
    id: 'finance',
    name: 'Finance & Banking',
    bengaliName: 'ফিন্যান্স ও ব্যাংকিং',
    icon: '🏦',
    colorHex: 0xFF1B5E20,
    group: SubjectGroup.business,
  ), // 152 – finance division quota
  SubjectInfo(
    id: 'ict',
    name: 'ICT',
    bengaliName: 'তথ্য ও যোগাযোগ প্রযুক্তি',
    icon: '💻',
    colorHex: 0xFF00796B,
    group: SubjectGroup.general,
  ), // 154 – New 2025 circular: MCQ 25 only + 25 practical =50
  SubjectInfo(
    id: 'physical_edu',
    name: 'Physical Education',
    bengaliName: 'শারীরিক শিক্ষা',
    icon: '⚽',
    colorHex: 0xFFBF360C,
    group: SubjectGroup.general,
  ), // 147 – continuous 50
  SubjectInfo(
    id: 'career',
    name: 'Career Education',
    bengaliName: 'ক্যারিয়ার শিক্ষা',
    icon: '🎯',
    colorHex: 0xFF3E2723,
    group: SubjectGroup.general,
  ), // 156 – continuous 50
  // ——— Humanities ———
  SubjectInfo(
    id: 'history',
    name: 'History of Bangladesh',
    bengaliName: 'বাংলাদেশের ইতিহাস ও বিশ্বসভ্যতা',
    icon: '🏛️',
    colorHex: 0xFF4E342E,
    group: SubjectGroup.humanities,
  ),
  SubjectInfo(
    id: 'civics',
    name: 'Civics & Citizenship',
    bengaliName: 'পৌরনীতি ও নাগরিকতা',
    icon: '⚖️',
    colorHex: 0xFF37474F,
    group: SubjectGroup.humanities,
  ),
];

/// Convenience lookup used by the paper builders.
SubjectInfo? subjectById(String? id) {
  if (id == null) return null;
  for (final s in allSubjects) {
    if (s.id == id) return s;
  }
  return null;
}
