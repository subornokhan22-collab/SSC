import 'package:flutter/material.dart';
import '../data/questions_data.dart';
import 'quiz_screen.dart';
import 'cq_screen.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({Key? key}) : super(key: key);

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  String _searchQuery = '';
  SubjectGroup _selectedGroup = SubjectGroup.all;

  // List of all SSC subjects
  final List<SubjectInfo> _allSubjects = const [
    SubjectInfo(id: 'physics', name: 'Physics', bengaliName: 'পদার্থবিজ্ঞান', icon: '⚛️', colorHex: 0xFF1A82BB, group: SubjectGroup.science),
    SubjectInfo(id: 'chemistry', name: 'Chemistry', bengaliName: 'রসায়ন', icon: '🧪', colorHex: 0xFF2E7D32, group: SubjectGroup.science),
    SubjectInfo(id: 'higher_math', name: 'Higher Math', bengaliName: 'উচ্চতর গণিত', icon: '📐', colorHex: 0xFF6A1B9A, group: SubjectGroup.science),
    SubjectInfo(id: 'biology', name: 'Biology', bengaliName: 'জীববিজ্ঞান', icon: '🧬', colorHex: 0xFFD84315, group: SubjectGroup.science),
    SubjectInfo(id: 'general_math', name: 'General Math', bengaliName: 'সাধারণ গণিত', icon: '🔢', colorHex: 0xFF0288D1, group: SubjectGroup.general),
    SubjectInfo(id: 'bangla_1st', name: 'Bangla 1st', bengaliName: 'বাংলা ১ম পত্র', icon: '📚', colorHex: 0xFFC2185B, group: SubjectGroup.general),
    SubjectInfo(id: 'english_1st', name: 'English 1st', bengaliName: 'ইংরেজি ১ম পত্র', icon: '🔤', colorHex: 0xFF5D4037, group: SubjectGroup.general),
    SubjectInfo(id: 'ict', name: 'ICT', bengaliName: 'তথ্য ও যোগাযোগ প্রযুক্তি', icon: '💻', colorHex: 0xFF00796B, group: SubjectGroup.general),
    SubjectInfo(id: 'accounting', name: 'Accounting', bengaliName: 'হিসাববিজ্ঞান', icon: '📊', colorHex: 0xFFE65100, group: SubjectGroup.business),
    SubjectInfo(id: 'finance', name: 'Finance & Banking', bengaliName: 'ফিন্যান্স ও ব্যাংকিং', icon: '🏦', colorHex: 0xFF1B5E20, group: SubjectGroup.business),
    SubjectInfo(id: 'history', name: 'History of Bangladesh', bengaliName: 'বাংলাদেশের ইতিহাস ও বিশ্বসভ্যতা', icon: '🏛️', colorHex: 0xFF4E342E, group: SubjectGroup.humanities),
    SubjectInfo(id: 'civics', name: 'Civics & Citizenship', bengaliName: 'পৌরনীতি ও নাগরিকতা', icon: '⚖️', colorHex: 0xFF37474F, group: SubjectGroup.humanities),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredSubjects = _allSubjects.where((subject) {
      final matchesSearch = subject.bengaliName.contains(_searchQuery) ||
          subject.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesGroup = _selectedGroup == SubjectGroup.all || subject.group == _selectedGroup;
      return matchesSearch && matchesGroup;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('বিষয়সমূহ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A82BB),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'বিষয় খুঁজুন (যেমন: পদার্থবিজ্ঞান)...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                fillColor: Colors.grey.shade100,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Group Filter Choice Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _buildGroupFilterChip('সব', SubjectGroup.all),
                _buildGroupFilterChip('বিজ্ঞান', SubjectGroup.science),
                _buildGroupFilterChip('ব্যবসায় শিক্ষা', SubjectGroup.business),
                _buildGroupFilterChip('মানবিক', SubjectGroup.humanities),
                _buildGroupFilterChip('সাধারণ', SubjectGroup.general),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Subjects List
          Expanded(
            child: filteredSubjects.isEmpty
                ? const Center(child: Text('কোনো বিষয় খুঁজে পাওয়া যায়নি।'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredSubjects.length,
                    itemBuilder: (context, index) {
                      final subject = filteredSubjects[index];
                      final mcqCount = sampleQuestions.where((q) => q.subject == subject.id).length;
                      final cqCount = sampleCreativeQuestions.where((q) => q.subject == subject.id).length;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: Color(subject.colorHex).withOpacity(0.15),
                            child: Text(subject.icon, style: const TextStyle(fontSize: 20)),
                          ),
                          title: Text(
                            subject.bengaliName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            '${subject.name} • MCQ: $mcqCount | CQ: $cqCount',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.quiz, color: Color(0xFF1A82BB)),
                                tooltip: 'MCQ Practice',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QuizScreen(
                                        subjectId: subject.id,
                                        subjectName: subject.bengaliName,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.article, color: Color(0xFF2E7D32)),
                                tooltip: 'Creative Questions',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CQScreen(
                                        subjectId: subject.id,
                                        subjectName: subject.bengaliName,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupFilterChip(String label, SubjectGroup group) {
    final isSelected = _selectedGroup == group;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF1A82BB),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedGroup = group);
          }
        },
      ),
    );
  }
}
