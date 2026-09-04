# Fixing the release title + shrinking the APK — from your phone

Ignore the `cp` / `git commit` commands from earlier. Those are terminal
commands for a computer. You can do this entirely in your phone's browser,
in about two minutes.

You are editing **one file**, changing **four lines**.

---

## Steps

**1.** Open this link on your phone:

<https://github.com/subornokhan22-collab/SSC/edit/arena/01a06614-ssc/.github/workflows/build_apk.yml>

That opens the file directly in GitHub's editor. If it asks you to sign in,
sign in first, then open the link again.

**2.** You will see a text editor. **Select everything** in it and delete it.

On Android: long-press in the text, tap **Select all**, then delete.

**3.** Copy the block below and paste it in, replacing what you deleted.

```yaml
name: Build APK

on:
  push:
  workflow_dispatch:

permissions:
  contents: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Java 17
        uses: actions/setup-java@v4
        with:
          distribution: zulu
          java-version: '17'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable

      - name: Get packages
        run: flutter pub get

      - name: Generate launcher icons (fixes missing app icon)
        run: dart run flutter_launcher_icons

      - name: Build APK
        run: flutter build apk --release --split-per-abi

      - name: Upload APK to Releases (no storage quota!)
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          gh release create "apk-${{ github.run_id }}" \
            build/app/outputs/flutter-apk/app-*-release.apk \
            --repo "${{ github.repository }}" \
            --title "Tutor's Desk (build ${{ github.run_number }})" \
            --notes "Tutor's Desk. Most phones need app-arm64-v8a-release.apk." \
            --latest
```

**4.** Scroll to the top and tap the green **Commit changes...** button.

**5.** A box appears. Leave everything as it is — make sure
**"Commit directly to the `arena/01a06614-ssc` branch"** is selected — and
tap **Commit changes**.

Done. A new build starts automatically and takes about 9 minutes.

---

## What changes

Only four lines differ from the current file:

| Line | Before | After |
|---|---|---|
| 35 | `flutter build apk --release` | `flutter build apk --release --split-per-abi` |
| 42 | `"...app-release.apk"` | `build/...app-*-release.apk` |
| 44 | `--title "A-Learning APK ..."` | `--title "Tutor's Desk ..."` |
| 45 | `--notes "Auto-built APK..."` | `--notes "Tutor's Desk..."` |

Everything else is identical, so nothing else about the build changes.

---

## What you get

**The release stops being called "A-Learning APK"** — permanently, on every
future build, with no manual renaming.

**The download drops from ~60 MB to ~25 MB.** Right now every APK contains
the app compiled for three different phone processors; your phone uses one
and ignores the other two. This splits them apart.

---

## After the build finishes

The release page will list **three** APK files instead of one:

| File | For |
|---|---|
| **`app-arm64-v8a-release.apk`** | **almost every phone from ~2016 on — use this one** |
| `app-armeabi-v7a-release.apk` | older 32-bit phones |
| `app-x86_64-release.apk` | emulators |

If `arm64-v8a` will not install on a device, try `armeabi-v7a`.

---

## Why I could not do this for you

GitHub deliberately blocks automated tools from editing files inside
`.github/workflows/`, because those files control what runs on their
servers. The exact refusal is:

> refusing to allow a GitHub App to create or update workflow
> `.github/workflows/build_apk.yml` without `workflows` permission

It is a security rule, not something wrong with the project. A signed-in
human editing in the browser is allowed — which is why this takes you two
minutes and is impossible for me.
