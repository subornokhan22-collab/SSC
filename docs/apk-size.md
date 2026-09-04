# APK size

## Where the 60 MB goes

| Part | Size |
|---|---|
| `assets/questions/*.json` | ~14 MB |
| `assets/fonts/` (5 PDF fonts) | ~2.2 MB |
| icons | ~0.5 MB |
| **native code — 3 CPU builds** | **~43 MB** |

Roughly 70% of the download is `libflutter.so` + `libapp.so` compiled
three times over: `arm64-v8a`, `armeabi-v7a` and `x86_64`. Every phone
uses exactly one of them and ignores the other two.

## Done

- deleted 2,670 lines of dead Dart (`lib/data/paper_pdf.dart`,
  `lib/services/english_board_pdf.dart`)
- dropped `webview_flutter` and `cupertino_icons` — both unused, and
  webview pulls in a heavy native component
- stopped bundling `assets/fonts/` wholesale, which was shipping an unused
  287 KB font
- enabled R8 (`isMinifyEnabled` + `isShrinkResources`) with keep rules in
  `android/app/proguard-rules.pro`

Measured effect: 60.01 MB -> 59.93 MB. Small, because none of it touches
the native libraries that dominate the file.

## The change that actually matters

Splitting per architecture takes the download from ~60 MB to **~25 MB**.
It needs one line in `.github/workflows/build_apk.yml`, which the agent
token cannot edit (`refusing to allow a GitHub App to ... without
'workflows' permission`).

`docs/build_apk.yml.proposed` is the finished file. To apply it:

```bash
cp docs/build_apk.yml.proposed .github/workflows/build_apk.yml
git commit -am "ci: split APK per ABI" && git push
```

The three changes it makes:

1. `flutter build apk --release` -> `flutter build apk --release --split-per-abi`
2. uploads `app-*-release.apk` instead of the single fat `app-release.apk`
3. titles releases "Mentor's Companion" instead of "A-Learning APK"

Each release then carries three files. Users on modern phones want
`app-arm64-v8a-release.apk`.

## Not worth doing

- **The question JSON.** 14 MB of Bengali text is close to irreducible.
  The redundant `bank` key costs only 2.5% and keeps the per-bank tests
  exact.
- **The PDF fonts.** All five are genuinely loaded by
  `services/paper_pdf.dart`; dropping any breaks glyphs in printed papers.
