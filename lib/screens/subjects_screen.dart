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
  String searchQuery = '';
  SubjectGroup selectedGroup = SubjectGroup.all;

  @override
  Widget build(BuildContext context) {
    final filteredSubjects = QuestionsData.subjects.where((subject) {
      final matchesSearch = subject.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          subject.bengaliName.contains(searchQuery);
      
      final matchesGroup = selectedGroup == SubjectGroup.all || subject.group == selectedGroup;

      return matchesSearch && matchesGroup;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('বিষয়সমূহ (Subjects)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A82BB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search & Filter Header Section
          Container(
            color: const Color(0xFF1A82BB),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) => setState(() => searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'বিষয় খুঁজুন (e.g. Physics, গণিত)...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF1A82BB)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Group Category Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildGroupFilterChip('সব', SubjectGroup.all),
                      _buildGroupFilterChip('বিজ্ঞান', SubjectGroup.science),
                      _buildGroupFilterChip('ব্যবসায় শিক্ষা', SubjectGroup.commerce),
                      _buildGroupFilterChip('মানবিক', SubjectGroup.humanities),
                      _buildGroupFilterChip('সাধারণ', SubjectGroup.general),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Subjects Grid List
          Expanded(
            child: filteredSubjects.isEmpty
                ? const Center(
                    child: Text(
                      'কোনো বিষয় পাওয়া যায়নি',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredSubjects.length,
                    itemBuilder: (context, index) {
                      final subject = filteredSubjects[index];
                      final mcqCount = QuestionsData.mcqs
                          .where((q) => q.subject == subject.id)
                          .length;
                      final cqCount = QuestionsData.cqs
                          .where((q) => q.subject == subject.id)
                          .length;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Subject Icon
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: subject.color.withOpacity(0.15),
                                child: Icon(subject.icon, color: subject.color, size: 28),
                              ),
                              const SizedBox(width: 12),

                              // Subject Title
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subject.bengaliName,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      subject.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Action Buttons (MCQ & CQ)
                              Row(
                                children: [
                                  // MCQ Button
                                  ElevatedButton(
                                    onPressed: mcqCount > 0
                                        ? () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => QuizScreen(
                                                  subjectId: subject.id,
                                                  subjectName: subject.bengaliName,
                                                ),
                                              ),
                                            );
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade700,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text('MCQ ($mcqCount)'),
                                  ),
                                  const SizedBox(width: 6),

                                  // CQ Button
                                  ElevatedButton(
                                    onPressed: cqCount > 0
                                        ? () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => CQScreen(
                                                  subjectId: subject.id,
                                                  subjectName: subject.bengaliName,
                                                ),
                                              ),
                                            );
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal.shade700,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text('CQ ($cqCount)'),
                                  ),
                                ],
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
    final isSelected = selectedGroup == group;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF1A82BB) : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedColor: Colors.white,
        backgroundColor: Colors.white.withOpacity(0.2),
        onSelected: (selected) {
          if (selected) {
            setState(() => selectedGroup = group);
          }
        },
      ),
    );
  }
}
