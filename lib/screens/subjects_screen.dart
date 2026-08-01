import 'package:flutter/material.dart';

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

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  final List<SubjectInfo> _allSubjects = const [
    SubjectInfo(id: 'physics', name: 'Physics', bengaliName: 'পদার্থবিজ্ঞান', icon: '⚛️', colorHex: 0xFF1A82BB, group: SubjectGroup.science),
    SubjectInfo(id: 'chemistry', name: 'Chemistry', bengaliName: 'রসায়ন', icon: '🧪', colorHex: 0xFF2E7D32, group: SubjectGroup.science),
    SubjectInfo(id: 'higher_math', name: 'Higher Math', bengaliName: 'উচ্চতর গণিত', icon: '📐', colorHex: 0xFF6A1B9A, group: SubjectGroup.science),
    SubjectInfo(id: 'biology', name: 'Biology', bengaliName: 'জীববিজ্ঞান', icon: '🧬', colorHex: 0xFFD84315, group: SubjectGroup.science),
    SubjectInfo(id: 'general_math', name: 'General Math', bengaliName: 'সাধারণ গণিত', icon: '🔢', colorHex: 0xFF0288D1, group: SubjectGroup.general),
    SubjectInfo(id: 'bangla_1st', name: 'Bangla 1st', bengaliName: 'বাংলা ১ম পত্র', icon: '📚', colorHex: 0xFFC2185B, group: SubjectGroup.general),
    SubjectInfo(id: 'bangla_2nd', name: 'Bangla 2nd', bengaliName: 'বাংলা ২য় পত্র', icon: '📖', colorHex: 0xFFAD1457, group: SubjectGroup.general),
    SubjectInfo(id: 'english_1st', name: 'English 1st', bengaliName: 'ইংরেজি ১ম পত্র', icon: '🔤', colorHex: 0xFF5D4037, group: SubjectGroup.general),
    SubjectInfo(id: 'english_2nd', name: 'English 2nd', bengaliName: 'ইংরেজি ২য় পত্র', icon: '📝', colorHex: 0xFF4E342E, group: SubjectGroup.general),
    SubjectInfo(id: 'bgs', name: 'BGS', bengaliName: 'বাংলাদেশ ও বিশ্বপরিচয়', icon: '🌏', colorHex: 0xFF00838F, group: SubjectGroup.general),
    SubjectInfo(id: 'religion', name: 'Religion & Moral Ed.', bengaliName: 'ইসলাম ও নৈতিক শিক্ষা', icon: '🕌', colorHex: 0xFF2E7D32, group: SubjectGroup.general),
    SubjectInfo(id: 'ict', name: 'ICT', bengaliName: 'তথ্য ও যোগাযোগ প্রযুক্তি', icon: '💻', colorHex: 0xFF00796B, group: SubjectGroup.general),
    SubjectInfo(id: 'accounting', name: 'Accounting', bengaliName: 'হিসাববিজ্ঞান', icon: '📊', colorHex: 0xFFE65100, group: SubjectGroup.business),
    SubjectInfo(id: 'finance', name: 'Finance & Banking', bengaliName: 'ফিন্যান্স ও ব্যাংকিং', icon: '🏦', colorHex: 0xFF1B5E20, group: SubjectGroup.business),
    SubjectInfo(id: 'history', name: 'History of Bangladesh', bengaliName: 'বাংলাদেশের ইতিহাস ও বিশ্বসভ্যতা', icon: '🏛️', colorHex: 0xFF4E342E, group: SubjectGroup.humanities),
    SubjectInfo(id: 'civics', name: 'Civics & Citizenship', bengaliName: 'পৌরনীতি ও নাগরিকতা', icon: '⚖️', colorHex: 0xFF37474F, group: SubjectGroup.humanities),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subjects')),
      body: ListView.builder(
        itemCount: _allSubjects.length,
        itemBuilder: (context, index) {
          final subject = _allSubjects[index];
          return ListTile(
            leading: Text(subject.icon, style: const TextStyle(fontSize: 24)),
            title: Text(subject.name),
            subtitle: Text(subject.bengaliName),
          );
        },
      ),
    );
  }
}
