# Phase 2 — architecture progress

**Implementation update:** the new teacher workspace, paper/AI controllers, shared
operation state, named primary routes, bank validation and hard format gate are
now implemented. See [the current delivery notes](TEACHER-WORKSPACE-2026-09-24.md)
for the working paths, tests and remaining legacy/deployment limitations. The
slice-1 report below is retained as historical context, not the current backlog.

Started 2026-09-24 after Phase 1 CI passed at `65dec3b`:
https://github.com/subornokhan22-collab/SSC/actions/runs/35976648526

## Slice 1: shared design foundation

- `lib/theme/design_tokens.dart` centralizes the current semantic colors,
  workspace palettes, UI/paper font families, core text styles, spacing, and radii.
- `AppTheme` retains its public constants as aliases, so existing screens do not
  break. The theme and workspace presets consume the tokens.
- Workspace preset order is preserved because its index is persisted on devices.
- `pubspec.yaml` registers the existing Hind Siliguri and Noto Serif Bengali files
  as Flutter font families. Listing them only as assets did not register families.
- The shared `AppButton` consumes the tokens, exposes button/disabled semantics,
  and blocks its tap handler during loading (previously it only looked disabled).
- Added theme/preset/font-registration checks and button loading/tap widget tests.

The palette is deliberately unchanged. Phase 4's seven-color Paper + Ink + Indigo
rebrand and decorative-animation reduction remain separate visual work. Typography
now actually uses the declared Bengali fonts, so a device visual smoke test is
recommended before release.

## Next slices (not complete)

1. **Formatting:** run `dart format lib test tool` with the same Flutter/Dart
   toolchain as CI; commit the mechanical changes separately, then make CI's
   format report a hard gate. Local SDK downloads are unavailable in this sandbox;
   the current workflow reports drift but does not claim it is already formatted.
2. **Shared operation state:** immutable idle/loading/success/error state and a
   lifecycle-safe ChangeNotifier base/hook; reuse the existing problem dialog.
3. **AI controller:** move routing, history/persistence and stream state out of
   `ai_tutor_screen.dart`; inject a gateway for tests; extract view widgets. Cover
   delayed replies, disposal, retry, signed-out and unconfigured-server cases.
4. **Paper controllers:** split `custom_paper_screen.dart` and
   `question_paper_screen.dart`; preserve question distribution, total marks,
   saved papers, answer keys, and PDF output with regression tests.
5. **Navigation:** named routes with typed argument validation, preserving the
   auth/root gate and existing back-stack behavior. Avoid moving all routes at once.
6. **Validation:** extend the reusable AI validation into bank-load boundaries;
   include an explicit aggregate batch result so even empty responses fail a
   positive requested-count check. The current per-question list alone cannot
   represent a batch-level error when it is empty.

Use ordinary ChangeNotifier/controllers/widgets, as the original tracker requests;
no additional state-management framework. End each slice with analyze and tests,
and keep the recovered originals' provenance separate from later corrections.

## Still blocked on deployment access (not Phase 2 code)

Production RLS migration/audit, `mimi` deployment + `GEMINI_API_KEY`, and release
signing secrets have not been configured by this session. CI exercises an isolated
PostgreSQL database. Its APK keystore-restoration step was skipped; the app still
uses the existing debug-signing fallback until the owner supplies signing setup.
