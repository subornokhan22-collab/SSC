import 'package:flutter/material.dart';

import '../services/app_settings.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'profile_screen.dart';

/// Settings — profile (moved here from the home screen), OMR scanner
/// preferences and the default paper name.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _nameCtrl;
  String? _savedMsg;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: AppSettings.defaultName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  /// Persists the typed name (called on submit / focus loss / back).
  Future<void> _persistName() async {
    final t = _nameCtrl.text.trim();
    if (t == AppSettings.defaultName) return;
    await AppSettings.setDefaultPaperName(t);
    if (!mounted) return;
    setState(() => _savedMsg = t);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _savedMsg = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings',
            style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: RefreshIndicator(
            color: AppTheme.primary,
            backgroundColor: AppTheme.card,
            onRefresh: _persistName,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              children: [
                _section(
                  'Profile',
                  icon: Icons.person_rounded,
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen())),
                    child: Row(children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(.10),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.primary.withOpacity(.35)),
                        ),
                        child: const Icon(Icons.person_rounded,
                            color: AppTheme.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Profile & account',
                                style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800)),
                            SizedBox(height: 2),
                            Text(
                                'Details, workspace theme, Pro sync, sign out',
                                style: TextStyle(
                                    fontSize: 11.5, color: AppTheme.muted)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: AppTheme.muted),
                    ]),
                  ),
                ),
                _section(
                  'OMR scanner',
                  icon: Icons.qr_code_scanner_rounded,
                  child: GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: ValueListenableBuilder<bool>(
                      valueListenable: AppSettings.omrPrefillCodes,
                      builder: (context, on, _) => Row(children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.secondary.withOpacity(.10),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppTheme.secondary.withOpacity(.35)),
                          ),
                          child: const Icon(Icons.table_view_rounded,
                              color: AppTheme.secondary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Prefill set & subject code',
                                  style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(height: 2),
                              Text(
                                on
                                    ? 'Scanner reads the set & subject code printed on each sheet'
                                    : 'Off — set & subject code will be left blank on results',
                                style: const TextStyle(
                                    fontSize: 11.5, color: AppTheme.muted),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: on,
                          onChanged: (v) => AppSettings.setOmriPrefill(v),
                        ),
                      ]),
                    ),
                  ),
                ),
                _section(
                  'Default paper name',
                  icon: Icons.title_rounded,
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                              'Used as the default title for new question papers and OMR tests',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  color: AppTheme.muted,
                                  height: 1.4)),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _nameCtrl,
                            style: const TextStyle(
                                fontSize: 14.5, fontWeight: FontWeight.w700),
                            onSubmitted: (_) => _persistName(),
                            onEditingComplete: _persistName,
                            decoration: InputDecoration(
                              hintText: 'e.g. মডেল টেস্ট — প্রথম ধাপ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide:
                                    const BorderSide(color: AppTheme.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide:
                                    const BorderSide(color: AppTheme.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                    color: AppTheme.primary, width: 1.4),
                              ),
                            ),
                          ),
                          if (_savedMsg != null)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text('Saved ✓',
                                  style: TextStyle(
                                      fontSize: 11.5,
                                      color: AppTheme.success)),
                            ),
                        ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(String title,
      {required IconData icon, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 18, 4, 10),
          child: Row(children: [
            Icon(icon, size: 18, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textDark)),
          ]),
        ),
        child,
      ],
    );
  }
}
