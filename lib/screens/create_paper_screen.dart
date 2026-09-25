import 'dart:async';
import 'dart:convert';
import '../controllers/ai_controller.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../controllers/paper_controller.dart';
import '../data/questions_data.dart';
import '../data/english_paper_sync.dart';
import '../models/paper_draft.dart';
import '../models/subject_info.dart';
import '../services/paper_composer.dart';
import '../services/paper_export.dart';
import '../services/paper_library.dart';
import '../services/paper_license.dart';
import '../services/paper_pdf.dart';
import '../theme/app_theme.dart';
import '../widgets/paper_question_card.dart';
import '../widgets/written_question_card.dart';
import '../widgets/workflow_progress.dart';
import 'omr_scanner_screen.dart';
import 'subscription_screen.dart';
import 'ai_tools_screen.dart';

class CreatePaperScreen extends StatefulWidget {
  final bool quickStart;
  final String? initialSubjectId;
  final PaperFormat? initialFormat;
  final List<Question>? initialQuestions;
  const CreatePaperScreen(
      {super.key,
      this.quickStart = false,
      this.initialSubjectId,
      this.initialFormat,
      this.initialQuestions});
  @override
  State<CreatePaperScreen> createState() => _CreatePaperScreenState();
}

class _CreatePaperScreenState extends State<CreatePaperScreen> {
  late final PaperController c;
  final title = TextEditingController();
  int step = 0;
  int page = 0;
  RenderedPaper? preview;
  static const steps = [
    'Subject',
    'Chapters & format',
    'Question counts',
    'Review questions',
    'Paper preview'
  ];
  @override
  void initState() {
    super.initState();
    final sid = widget.initialSubjectId ?? 'physics';
    final counts = PaperComposer.defaults(sid);
    c = PaperController(
        composer:
            PaperComposer(mcqBank: allMCQs, saqBank: allSAQs, cqBank: allCQs),
        initial: PaperDraft(
            subjectId: sid,
            format: widget.initialFormat ?? PaperFormat.board,
            mcqCount: counts.$1,
            saqCount: counts.$2,
            cqCount: counts.$3));
    c.addListener(sync);
    unawaited(initialize());
  }

  Future<void> initialize() async {
    await c.initialize(
        restore: widget.initialSubjectId == null &&
            widget.initialFormat == null &&
            widget.initialQuestions == null);
    if (!mounted) return;
    if (widget.initialQuestions?.isNotEmpty == true) {
      c.useAiQuestions(widget.initialQuestions!);
      step = 3;
    }
    if (widget.quickStart && widget.initialQuestions == null) {
      if (await c.generate() && mounted) step = 3;
    }
    sync();
  }

  void sync() {
    if (!mounted) return;
    if (title.text != c.draft.title)
      title.value = TextEditingValue(
          text: c.draft.title,
          selection: TextSelection.collapsed(offset: c.draft.title.length));
    setState(() {});
  }

  @override
  void dispose() {
    c.removeListener(sync);
    c.dispose();
    title.dispose();
    super.dispose();
  }

  Future<void> next() async {
    if (step == 2) {
      if (c.paper == null && !await c.generate()) return;
    }
    if (step == 3) {
      if (c.paper == null) return;
      final ok = await c.run('Rendering the exact print layout…', () async {
        final result = await PaperExport.render(c.draft, c.paper!);
        if (mounted) {
          preview = result;
          page = 0;
        }
      });
      if (!ok) return;
    }
    if (mounted) setState(() => step = (step + 1).clamp(0, 4).toInt());
  }

  Future<bool> allowExport() async {
    if (await PaperLicense.isPro()) return mounted;
    if (!mounted) return false;
    final upgrade = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: const Text('Export with Pro'),
                content: const Text(
                    'You can create and review the complete paper for free. Pro unlocks saving, PDF export, printing and OMR sheets.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Keep reviewing')),
                  FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('View plans'))
                ]));
    if (upgrade == true && mounted)
      await Navigator.push(context,
          MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
    return false;
  }

  Future<void> export(String action) async {
    if (c.busy || preview == null || c.paper == null) return;
    if (!await allowExport()) return;
    await c.run(action == 'save' ? 'Saving your paper…' : 'Preparing export…',
        () async {
      final d = c.draft;
      final p = c.paper!;
      if (action == 'save') {
        await PaperLibrary.addSavedPaper(
            SavedPaper(
                id: 'sp_${DateTime.now().microsecondsSinceEpoch}',
                title: d.title,
                subject: c.subject!.bengaliName,
                subjectId: d.subjectId,
                subjectCode: PaperComposer.codes[d.subjectId] ?? '',
                setCode: d.setCode,
                total: p.mcqs.length,
                key: p.mcqs.map((q) => q.correctIndex).toList(),
                questions: [
                  for (final q in p.mcqs)
                    SavedQuestion(
                        text: q.questionText,
                        options: q.options,
                        answer: q.correctIndex)
                ],
                createdAt: DateTime.now(),
                pages: preview!.pages.length),
            pageImages: preview!.pages);
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Saved in My Papers with its answer key.')));
      } else if (action == 'omr') {
        await PaperPdf.printOmrSheet(
            total: p.mcqs.length,
            title: d.title,
            subjectCode: PaperComposer.codes[d.subjectId],
            setCode: d.setCode);
      } else if (action == 'print') {
        await Printing.layoutPdf(onLayout: (_) async => preview!.pdf);
      } else {
        await Printing.sharePdf(
            bytes: preview!.pdf, filename: 'question-paper.pdf');
      }
    });
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: step == 0 && !c.busy,
      onPopInvoked: (didPop) {
        if (!didPop && !c.busy && step > 0) setState(() => step--);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Create Paper'), actions: [
          IconButton(
              tooltip: 'Undo',
              onPressed: c.canUndo
                  ? () {
                      c.undo();
                      if (step == 4) setState(() => step = 3);
                    }
                  : null,
              icon: const Icon(Icons.undo)),
          IconButton(
              tooltip: 'Redo',
              onPressed: c.canRedo
                  ? () {
                      c.redo();
                      if (step == 4) setState(() => step = 3);
                    }
                  : null,
              icon: const Icon(Icons.redo)),
        ]),
        body: !c.initialized
            ? const Center(child: CircularProgressIndicator())
            : Column(children: [
                WorkflowProgress(steps: steps, current: step),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(children: [
                      const Icon(Icons.cloud_done_outlined,
                          size: 14, color: AppTheme.muted),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Text(
                              c.saveError ??
                                  (c.savedAt == null
                                      ? 'Draft saves automatically on this device'
                                      : 'Auto-saved ${TimeOfDay.fromDateTime(c.savedAt!).format(context)}'),
                              style: TextStyle(
                                  fontSize: 11,
                                  color: c.saveError == null
                                      ? AppTheme.muted
                                      : AppTheme.danger))),
                    ])),
                Expanded(
                    child: AbsorbPointer(
                        absorbing: c.busy,
                        child: step == 4
                            ? previewBody()
                            : ListView(
                                padding: const EdgeInsets.all(20),
                                children: [
                                    OperationNotice(
                                        error: c.error, activity: c.activity),
                                    if (step == 0) subjectStep(),
                                    if (step == 1) chapterStep(),
                                    if (step == 2) countsStep(),
                                    if (step == 3) reviewStep(),
                                  ]))),
                if (step == 4)
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: OperationNotice(
                          error: c.error, activity: c.activity)),
              ]),
        bottomNavigationBar: SafeArea(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                child: step < 4
                    ? Row(children: [
                        if (step > 0)
                          TextButton(
                              onPressed:
                                  c.busy ? null : () => setState(() => step--),
                              child: const Text('Back')),
                        const Spacer(),
                        FilledButton.icon(
                            onPressed: c.busy || !c.initialized ? null : next,
                            icon: c.busy
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : Icon(
                                    step == 3
                                        ? Icons.visibility_outlined
                                        : Icons.arrow_forward,
                                    size: 18),
                            label: Text(c.busy
                                ? 'Working…'
                                : step == 2
                                    ? 'Select questions'
                                    : step == 3
                                        ? 'Preview paper'
                                        : 'Continue')),
                      ])
                    : Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        children: [
                            FilledButton.icon(
                                onPressed: c.busy ? null : () => export('pdf'),
                                icon: const Icon(Icons.picture_as_pdf_outlined,
                                    size: 18),
                                label: const Text('Export PDF')),
                            OutlinedButton.icon(
                                onPressed: c.busy ? null : () => export('save'),
                                icon:
                                    const Icon(Icons.bookmark_border, size: 18),
                                label: const Text('Save')),
                            IconButton(
                                tooltip: 'Print',
                                onPressed:
                                    c.busy ? null : () => export('print'),
                                icon: const Icon(Icons.print_outlined)),
                            if (c.paper?.mcqs.isNotEmpty == true)
                              PopupMenuButton<String>(
                                  enabled: !c.busy,
                                  onSelected: (value) {
                                    if (value == 'scan')
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => OMrScannerScreen(
                                                  initialKey: c.paper!.mcqs
                                                      .map(
                                                          (q) => q.correctIndex)
                                                      .toList(),
                                                  paperTitle: c.draft.title,
                                                  initialSubject:
                                                      c.subject!.bengaliName)));
                                    else
                                      export('omr');
                                  },
                                  itemBuilder: (_) => const [
                                        PopupMenuItem(
                                            value: 'omr',
                                            child: Text('Print OMR sheet')),
                                        PopupMenuItem(
                                            value: 'scan',
                                            child: Text('Scan answers'))
                                      ]),
                          ]))),
      ));

  Widget subjectStep() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('What are you teaching?',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('Choose a subject. Questions come from the saved SSC bank.'),
        const SizedBox(height: 20),
        for (final s in allSubjects)
          Card(
              child: RadioListTile<String>(
                  title: Text(s.name),
                  subtitle: Text(
                      '${s.bengaliName} · ${PaperComposer.isEnglish(s.id) ? 'English sections available' : '${allMCQs.where((q) => q.subjectId == s.id).length} MCQs in bank'}'),
                  value: s.id,
                  groupValue: c.draft.subjectId,
                  onChanged: (id) => c.selectSubject(id!))),
      ]);
  Widget chapterStep() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Choose the paper format',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        if (PaperComposer.isEnglish(c.draft.subjectId)) ...[
          DropdownButtonFormField<String>(
              value: EnglishPaperSync.choices(c.draft.subjectId)
                      .containsKey(c.draft.englishPaperId)
                  ? c.draft.englishPaperId
                  : '',
              isExpanded: true,
              decoration: const InputDecoration(
                  labelText: 'Board / year · synced English papers'),
              items: [
                const DropdownMenuItem(
                    value: '', child: Text('Mixed practice set')),
                for (final e
                    in EnglishPaperSync.choices(c.draft.subjectId).entries)
                  DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value, overflow: TextOverflow.ellipsis))
              ],
              onChanged: (id) => c.update(c.draft
                  .copyWith(englishPaperId: id, clearEnglishPaper: id == ''))),
          const SizedBox(height: 16),
        ],
        for (final f in PaperFormat.values)
          Card(
              child: RadioListTile<PaperFormat>(
                  title: Text(switch (f) {
                    PaperFormat.board => 'Board Pattern',
                    PaperFormat.chapter => 'Chapter Test',
                    PaperFormat.custom => 'Custom Paper',
                    PaperFormat.mcq => 'MCQ + OMR'
                  }),
                  subtitle: Text(switch (f) {
                    PaperFormat.board =>
                      'Complete subject pattern from the saved bank',
                    PaperFormat.chapter => 'Practice selected chapters',
                    PaperFormat.custom =>
                      'Choose your MCQ, short-answer and CQ counts',
                    PaperFormat.mcq => 'Up to 100 MCQs with an answer key'
                  }),
                  value: f,
                  groupValue: c.draft.format,
                  onChanged: PaperComposer.isEnglish(c.draft.subjectId) &&
                          f != PaperFormat.board
                      ? null
                      : (f) =>
                          c.update(c.draft.copyWith(format: f, chapters: [])))),
        if (c.draft.format != PaperFormat.board) ...[
          const SizedBox(height: 20),
          Text('Chapters', style: Theme.of(context).textTheme.titleLarge),
          Text(c.draft.format == PaperFormat.chapter
              ? 'Select at least one chapter.'
              : 'Leave all unchecked to use the whole bank.'),
          if (c.chapters.isEmpty)
            const OperationNotice(
                error: 'No questions are available for this subject yet.'),
          for (final ch in c.chapters)
            CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(ch),
                value: c.draft.chapters.contains(ch),
                onChanged: (selected) {
                  final next = [...c.draft.chapters];
                  if (selected == true)
                    next.add(ch);
                  else
                    next.remove(ch);
                  c.update(c.draft.copyWith(chapters: next));
                }),
        ],
      ]);
  Widget countsStep() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Set up your paper',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 18),
        TextField(
            controller: title,
            decoration: const InputDecoration(labelText: 'Paper title'),
            onChanged: (v) =>
                c.update(c.draft.copyWith(title: v), preserveQuestions: true)),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
            value: c.draft.setCode,
            decoration: const InputDecoration(labelText: 'Set code'),
            items: [
              for (final s in const ['ক', 'খ', 'গ', 'ঘ'])
                DropdownMenuItem(value: s, child: Text(s))
            ],
            onChanged: (s) => c.update(c.draft.copyWith(setCode: s),
                preserveQuestions: true)),
        const SizedBox(height: 16),
        if (c.draft.format == PaperFormat.board)
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(PaperComposer.isEnglish(c.draft.subjectId)
                      ? 'Reading / Grammar and Writing • 100 marks. Complete English sections are preserved.'
                      : 'Board Pattern uses the subject’s fixed distribution and answer counts. Practical marks are not part of the printed theory paper.')))
        else ...[
          count('MCQ', c.draft.mcqCount, 100,
              (v) => c.update(c.draft.copyWith(mcqCount: v))),
          if (c.draft.format != PaperFormat.mcq) ...[
            count('Short answer · 2 marks', c.draft.saqCount, 30,
                (v) => c.update(c.draft.copyWith(saqCount: v))),
            count('Creative question · 10 marks', c.draft.cqCount, 15,
                (v) => c.update(c.draft.copyWith(cqCount: v))),
          ],
        ],
        SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Include MCQ answer key in PDF'),
            subtitle: const Text(
                'Keep off for the student copy. The key is always saved with your paper.'),
            value: c.draft.answerKey,
            onChanged: (v) => c.update(c.draft.copyWith(answerKey: v),
                preserveQuestions: true)),
      ]);
  Widget count(String label, int value, int max, ValueChanged<int> change) =>
      Card(
          child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(children: [
                Expanded(child: Text(label)),
                IconButton(
                    tooltip: 'Fewer $label',
                    onPressed: value > 0 ? () => change(value - 1) : null,
                    icon: const Icon(Icons.remove_circle_outline)),
                SizedBox(
                    width: 32,
                    child: Text('$value', textAlign: TextAlign.center)),
                IconButton(
                    tooltip: 'More $label',
                    onPressed: value < max ? () => change(value + 1) : null,
                    icon: const Icon(Icons.add_circle_outline)),
              ])));
  Widget reviewStep() {
    final p = c.paper;
    if (p == null)
      return Column(children: [
        const Text('Choose counts and select questions to continue.'),
        TextButton(
            onPressed: () => setState(() => step = 2),
            child: const Text('Back to counts'))
      ]);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Review before printing',
          style: Theme.of(context).textTheme.headlineSmall),
      Text(
          '${p.marks} marks · ${p.minutes} minutes · ${p.mcqs.length} MCQ · ${p.saqs.length} short · ${p.cqs.length} CQ'),
      const SizedBox(height: 8),
      const Text(
          'Verify the question wording and answer key. Undo is available for every change.',
          style: TextStyle(color: AppTheme.muted)),
      if (!PaperComposer.isEnglish(c.draft.subjectId))
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: OutlinedButton.icon(
                onPressed: () async {
                  final questions = await Navigator.push<List<Question>>(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AiToolsScreen(
                              subjectId: c.draft.subjectId,
                              chapter: c.draft.chapters.isEmpty
                                  ? null
                                  : c.draft.chapters.first,
                              currentPaper: p.mcqs,
                              forSelection: true)));
                  if (mounted && questions != null) c.addAiQuestions(questions);
                },
                icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                label: const Text('Add reviewed AI questions'))),
      for (var i = 0; i < p.mcqs.length; i++)
        PaperQuestionCard(
            question: p.mcqs[i],
            number: i + 1,
            onReplace: () => c.replaceQuestion(i),
            onImprove: () async {
              final q = p.mcqs[i];
              final edited = await Navigator.push<List<Question>>(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AiToolsScreen(
                          subjectId: q.subjectId,
                          chapter: q.chapter,
                          currentPaper: p.mcqs,
                          forSelection: true,
                          replaceSelection: true,
                          initialCommand: TeacherCommand.improve,
                          initialText: jsonEncode({
                            'question': q.questionText,
                            'options': q.options
                          }))));
              if (mounted && edited?.length == 1)
                c.editQuestion(i, edited!.single);
            },
            onEdit: (q) => c.editQuestion(i, q),
            onDelete: c.draft.format == PaperFormat.board
                ? null
                : () => c.removeQuestion(i)),
      if (p.saqs.isNotEmpty)
        Text('Short answers · answer ${p.saqAnswers}',
            style: Theme.of(context).textTheme.titleLarge),
      for (var i = 0; i < p.saqs.length; i++)
        WrittenQuestionCard(
            question: p.saqs[i],
            number: i + 1,
            onEdit: (q) => c.editWritten(i, q),
            onReplace: () => c.replaceWritten(i, creative: false),
            onDelete: c.draft.format == PaperFormat.board
                ? null
                : () => c.removeWritten(i, creative: false)),
      if (p.cqs.isNotEmpty)
        Text('সৃজনশীল প্রশ্ন · answer ${p.cqAnswers}',
            style: Theme.of(context).textTheme.titleLarge),
      for (var i = 0; i < p.cqs.length; i++)
        WrittenQuestionCard(
            question: p.cqs[i],
            number: i + 1,
            onEdit: (q) => c.editWritten(i, q),
            onReplace: () => c.replaceWritten(i, creative: true),
            onDelete: c.draft.format == PaperFormat.board
                ? null
                : () => c.removeWritten(i, creative: true)),
      if (p.english.isNotEmpty ||
          p.literature.isNotEmpty ||
          p.written.isNotEmpty)
        const Card(
            child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                    'Language-paper sections are preserved in full. Review their complete layout in the next step.'))),
    ]);
  }

  Widget previewBody() {
    if (preview == null)
      return const Center(child: Text('Return to review to render the paper.'));
    return Column(children: [
      Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
              'Page ${page + 1} of ${preview!.pages.length} · Pinch to zoom · Swipe for next page',
              style: const TextStyle(color: AppTheme.muted, fontSize: 12))),
      Expanded(
          child: PageView.builder(
              itemCount: preview!.pages.length,
              onPageChanged: (i) => setState(() => page = i),
              itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: Image.memory(preview!.pages[i],
                          fit: BoxFit.contain)))))
    ]);
  }
}
