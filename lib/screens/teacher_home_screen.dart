import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../models/paper_draft.dart';
import '../controllers/paper_controller.dart';
import '../theme/design_tokens.dart';
import '../widgets/animations.dart';
import '../widgets/app_icon.dart';
import '../services/app_style.dart';
import '../widgets/alive_tab_stack.dart';
import '../widgets/aurora_ribbons.dart';
import '../widgets/motion_policy.dart';
import '../navigation/app_routes.dart';
import '../services/auth_service.dart';
import '../services/paper_library.dart';
import '../services/paper_license.dart';
import '../services/promotion_service.dart';
import '../theme/app_theme.dart';
import 'ai_tools_screen.dart';
import 'omr_scanner_screen.dart';
import 'papers_library_screen.dart';
import 'saved_paper_screen.dart';

/// Four predictable destinations. Lazy tabs avoid permission prompts and
/// network work for tools the teacher has not opened.
class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});
  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen>
    with WidgetsBindingObserver {
  int tab = 0;
  int libraryVisit = 0;
  String? draftTitle;
  int loadGeneration = 0;
  final visited = <int>{0};
  List<PaperEntry> recent = [];
  PromotionFeed promotions = const PromotionFeed();
  bool loading = true;
  bool devicePro = false;
  String? error;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) load();
  }

  Future<void> load() async {
    final generation = ++loadGeneration;
    final localPro = await PaperLicense.isPro();
    String? storedTitle;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(PaperController.draftKey);
      if (raw != null) {
        final snapshot = jsonDecode(raw) as Map<String, dynamic>;
        if (snapshot['version'] == 1 && snapshot['draft'] is Map) {
          storedTitle = (snapshot['draft']['title'] as String?)?.trim();
        }
      }
    } catch (_) {
      // A corrupt draft must not hide the saved-paper library.
    }
    // Keep promotions independent from the local paper library. A slow or
    // corrupt paper index must not prevent a newly signed-in account from
    // receiving an active in-app offer popup.
    List<PaperEntry> entries = const [];
    var libraryFailed = false;
    try {
      entries = await PaperLibrary.loadEntries();
    } catch (_) {
      libraryFailed = true;
    }
    PromotionFeed feed = const PromotionFeed();
    try {
      feed = await PromotionService.load();
    } catch (_) {
      // Promotions are optional network content; they must never hide papers.
    }
    if (mounted && generation == loadGeneration) {
      setState(() {
        draftTitle = storedTitle;
        recent = entries.take(4).toList();
        promotions = feed;
        devicePro = localPro;
        loading = false;
        error = libraryFailed
            ? 'Your papers could not be loaded. Pull down to retry.'
            : null;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && generation == loadGeneration) _showOfferPopup(feed);
      });
    }
  }

  Future<void> _showOfferPopup(PromotionFeed feed) async {
    // A promotion may be text-only. Requiring an image here made valid active
    // ads silently disappear even though the database and RLS query succeeded.
    if (feed.ads.isEmpty) return;
    final ad = feed.ads.first;
    final prefs = await SharedPreferences.getInstance();
    // Seen state belongs to the account, not only the physical device: a new
    // tutor signing in on a shared phone must still receive the offer.
    final account = AuthService.userId ?? 'signed_out';
    final safeAccount = account.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final seenKey = 'promotion_ad_seen_${safeAccount}_${ad.id}';
    if (prefs.getBool(seenKey) == true || !mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    await prefs.setBool(seenKey, true);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(ad.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ad.imageUrl.startsWith('https://')) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    ad.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      height: 120,
                      child: Center(child: Icon(PhosphorIcons.imageBroken)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (ad.body.trim().isNotEmpty)
                Text(ad.body)
              else
                const Text('Open this offer to learn more.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (ad.buttonUrl == '/plans' && mounted)
                Navigator.pushNamed(context, AppRoutes.plans);
            },
            child: Text(ad.buttonText),
          ),
        ],
      ),
    );
  }

  Future<void> create({bool quick = false}) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.createPaper,
      arguments: quick
          ? const CreatePaperArgs(
              quickStart: true,
              subjectId: 'physics',
              format: PaperFormat.board,
            )
          : null,
    );
    // The editor can move the workspace tint (English is pink); coming back to
    // the desk restores the accent for the tab the teacher is actually on.
    AppStyle.mood.value = _moods[tab % _moods.length];
    if (mounted) load();
  }

  /// Tab index to the colour the backdrop should drift towards. Colour is the
  /// navigation cue: indigo desk, sky library, teal scanner, purple AI.
  static const List<WorkspaceMood> _moods = [
    WorkspaceMood.home,
    WorkspaceMood.papers,
    WorkspaceMood.omr,
    WorkspaceMood.ai,
  ];

  void select(int i) {
    if (i == tab) return;
    FocusManager.instance.primaryFocus?.unfocus();
    if (i == 1) libraryVisit++;
    setState(() {
      tab = i;
      visited.add(i);
    });
    AppStyle.mood.value = _moods[i % _moods.length];
    if (i == 0) load();
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: tab == 0,
        onPopInvoked: (didPop) {
          if (!didPop) select(0);
        },
        child: Scaffold(
          body: AliveTabStack(
            index: tab,
            children: [
              home(),
              // Recreate the library on each visit so a just-saved paper is visible.
              visited.contains(1)
                  ? PapersLibraryScreen(key: ValueKey(libraryVisit))
                  : const SizedBox.shrink(),
              visited.contains(2)
                  ? const OMrScannerScreen()
                  : const SizedBox.shrink(),
              visited.contains(3)
                  ? const AiToolsScreen()
                  : const SizedBox.shrink(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            animationDuration: MotionPolicy.duration(context, 180),
            selectedIndex: tab,
            onDestinationSelected: select,
            destinations: const [
              NavigationDestination(
                icon: Icon(PhosphorIcons.house),
                selectedIcon: Icon(PhosphorIcons.house),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(PhosphorIcons.folder),
                selectedIcon: Icon(PhosphorIcons.folder),
                label: 'My Papers',
              ),
              NavigationDestination(
                icon: Icon(PhosphorIcons.scan),
                label: 'Scan',
              ),
              NavigationDestination(
                icon: Icon(PhosphorIcons.magicWand),
                label: 'AI Tools',
              ),
            ],
          ),
        ),
      );
  Widget _notificationCard(AppNotificationItem item) => Card(
        color: const Color(0xFFF5F3FF),
        child: ListTile(
          leading: const Icon(PhosphorIcons.bellRinging, color: AppColors.ai),
          title: Text(item.title,
              style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle:
              Text(item.message, maxLines: 3, overflow: TextOverflow.ellipsis),
          trailing: item.actionUrl == '/plans'
              ? const Icon(PhosphorIcons.caretRight)
              : null,
          onTap: item.actionUrl == '/plans'
              ? () => Navigator.pushNamed(context, AppRoutes.plans)
              : null,
        ),
      );

  Widget _prizeCard(PromotionPrize prize) => Card(
        color: const Color(0xFFFFFBEB),
        child: ListTile(
          leading: prize.imageUrl.startsWith('https://')
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(prize.imageUrl,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                          PhosphorIcons.trophy,
                          color: Colors.amber)),
                )
              : const Icon(PhosphorIcons.trophy, color: Colors.amber),
          title: Text(prize.title,
              style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text(
            [prize.valueText, prize.description]
                .where((text) => text.trim().isNotEmpty)
                .join(' · '),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );

  Widget home() => Scaffold(
        appBar: AppBar(
          title: const Text("Tutor’s Desk"),
          actions: [
            IconButton(
              tooltip: 'Settings',
              onPressed: () async {
                await Navigator.pushNamed(context, AppRoutes.settings);
                if (mounted) load();
              },
              icon: const Icon(PhosphorIcons.gear),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: load,
          child: ListView(
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(),
            children: Stagger.list([
              Text(
                AuthService.isLoggedIn
                    ? 'Welcome, ${AuthService.displayName.isEmpty ? 'teacher' : AuthService.displayName}'
                    : 'Your teaching workspace',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Prepare a paper. Review the answers. Start your class.',
                style: TextStyle(color: AppTheme.muted),
              ),
              const SizedBox(height: 24),
              Card(
                color: const Color(0xFFEEF2FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: AppTheme.primary.withOpacity(.18)),
                ),
                // The one place on the desk that earns atmosphere. Kept faint
                // and clipped to the hero so the rest of the screen stays a
                // still, printable surface.
                child: AuroraRibbons(
                  enabled: true,
                  opacity: .34,
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          AppDuotoneIcon(
                            PhosphorIcons.fileTextDuotone,
                            size: 34,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                              child: Text('FROM YOUR DESK TO THE CLASSROOM',
                                  style: TextStyle(
                                      fontSize: 10,
                                      letterSpacing: 1.1,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primary))),
                        ]),
                        const SizedBox(height: 14),
                        Text(
                          'Create a Question Paper',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Board Pattern, Chapter Test or MCQ + OMR — one guided workflow.',
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => create(),
                            icon: const Icon(PhosphorIcons.plus),
                            label: Text(draftTitle == null
                                ? 'Create a paper'
                                : 'Create / resume paper'),
                          ),
                        ),
                        TextButton(
                          onPressed: () => create(quick: true),
                          child: const Text('Start a Physics Model Test →'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!devicePro) ...[
                const SizedBox(height: 14),
                Card(
                  color: const Color(0xFFF4F1FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: AppTheme.primary.withOpacity(.22),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              PhosphorIcons.crown,
                              color: AppTheme.accent,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Unlock Tutor\'s Desk Pro',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Full papers, PDF export, printing and no watermark.',
                          style: TextStyle(color: AppTheme.muted),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () async {
                              await Navigator.pushNamed(
                                context,
                                AppRoutes.plans,
                              );
                              if (mounted) load();
                            },
                            icon: const Icon(
                              PhosphorIcons.wallet,
                              size: 19,
                            ),
                            label: const Text('Buy Pro plan'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (promotions.notifications.isNotEmpty) ...[
                const SizedBox(height: 12),
                for (final item in promotions.notifications.take(3))
                  _notificationCard(item),
              ],
              if (promotions.prizes.isNotEmpty) ...[
                const SizedBox(height: 4),
                _prizeCard(promotions.prizes.first),
              ],
              if (draftTitle != null)
                Card(
                    child: ListTile(
                  leading: const Icon(PhosphorIcons.notePencil,
                      color: AppTheme.primary),
                  title: const Text('Continue your draft'),
                  subtitle: Text(
                      '${draftTitle!.isEmpty ? 'Untitled paper' : draftTitle!} · On this device',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  trailing: const Icon(PhosphorIcons.arrowRight),
                  onTap: () => create(),
                )),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: quickAction(
                      PhosphorIcons.scan,
                      'Scan OMR',
                      'Review & grade',
                      () => select(2),
                      AppColors.omr,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: quickAction(
                      PhosphorIcons.magicWand,
                      'AI Tools',
                      'Create · Improve · Check',
                      () => select(3),
                      AppColors.ai,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              quickAction(
                PhosphorIcons.folderOpen,
                'My Papers',
                'Saved · PDF · OMR keys',
                () => select(1),
                AppColors.science,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Recent papers',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => select(1),
                    child: const Text('View all'),
                  ),
                ],
              ),
              if (loading)
                const Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(children: [
                      ActivityIndicator(),
                      SizedBox(width: 12),
                      Text('Loading your papers…')
                    ]))
              else if (error != null)
                Card(
                    child: ListTile(
                        title: Text(error!),
                        trailing: IconButton(
                            tooltip: 'Retry loading papers',
                            onPressed: load,
                            icon: const Icon(PhosphorIcons.arrowClockwise))))
              else if (recent.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No saved papers yet. Create your first paper; it will appear here.',
                    ),
                  ),
                ),
              for (final entry in recent)
                Card(
                  child: ListTile(
                    leading: const Icon(
                      PhosphorIcons.fileText,
                      color: AppTheme.primary,
                    ),
                    title: Text(
                      entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      'Saved · ${entry.subject} · ${entry.pages} pages · ${entry.createdAt.day}/${entry.createdAt.month}',
                    ),
                    trailing: const Icon(PhosphorIcons.caretRight),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SavedPaperScreen(entry: entry),
                        ),
                      );
                      if (mounted) load();
                    },
                  ),
                ),
            ]),
          ),
        ),
      );
  Widget quickAction(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback action,
    Color color,
  ) =>
      Card(
        child: PressableScale(
          onTap: action,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: AppColors.onColor),
                ),
                const SizedBox(height: 10),
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
}
