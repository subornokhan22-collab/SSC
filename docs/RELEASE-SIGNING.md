# Production-only release signing

Release builds now **fail closed**. There is no debug-key fallback and CI does
not distribute unsigned, debug or preview APKs. Ordinary branch pushes still
run quality checks when signing is unavailable; the run summary explicitly says
**APK delivery blocked**. Green quality checks alone do not mean an Android
release has been compiled or delivered.

## Secure configuration — repository owner / trusted maintainer

Use the **existing intended production keystore**, if one exists. Do not replace
it, generate a new identity automatically, commit it, or send passwords/keys in
chat. Keep an encrypted backup outside this repository. A first production key
requires a deliberate owner decision if no production identity exists yet.

Configure these in GitHub → this repository → Settings → Secrets and variables
→ Actions. This is a maintainer task; it does not require Termux or changes to
Supabase/Netlify.

| Actions secret | Purpose |
| --- | --- |
| `RELEASE_KEYSTORE_BASE64` | Base64 of the approved PKCS12 keystore |
| `RELEASE_KEYSTORE_PASSWORD` | Keystore password |
| `RELEASE_KEY_ALIAS` | Existing release key alias |
| `RELEASE_KEY_PASSWORD` | Existing private-key password |

Also configure the **Actions variable** `RELEASE_CERT_SHA256`: the public SHA-256
fingerprint of the approved release certificate (64 hex digits; colons accepted).
The fingerprint is not a secret. Obtain it from the trusted release certificate
or a known production APK, not an arbitrary new build. This pin prevents an
incorrectly configured signing identity from being distributed.

## Enforcement

- Gradle always selects `release-ci` for release variants.
- `validateProductionSigning` runs before release preparation/signing. It checks
  required values, keystore presence, private-key access, certificate validity,
  absence of the Android debug identity and the approved certificate pin.
- CI restores the keystore only when all four secrets and the pin exist. It
  verifies each APK with `apksigner` and compares the certificate before upload.
- Restored keystores are deleted in an `always()` step and ignored by Git.
- Without signing, CI validates Android Gradle configuration and runs a negative
  test proving that the release-signing guard rejects missing credentials. No
  substitute APK is built or uploaded. CI also compiles native debug-variant
  classes to check Kotlin/plugin compatibility, without packaging an APK.
- Version-tag releases and manual runs with **Require production APK delivery**
  enabled fail if signing is unavailable; they cannot report release success.
- Normal local debug development remains possible, but those builds are not
  production deliverables.

## Existing installations

Older CI builds could be debug-signed. Android rejects an in-place update whose
signing certificate differs, so moving a phone to the first production-signed
build usually requires uninstalling the current one — and Android deletes the
app’s private folder when that happens.

Do this **before** uninstalling:

1. Open the app → **My Papers** → tap the backup icon
   (tooltip: “Copy backup to Download folder”), or allow the one-time permission
   prompt. The library is copied to `Download/TutorsDesk/tutors_desk_backup.json`
   through MediaStore (no permission on Android 10+). The app reports the real
   location on success and a failure dialog when the device refuses.
2. Confirm that file exists in the Download folder.
3. Uninstall, install the production-signed APK, and start it. An empty library
   is restored automatically from that shared copy, including OMR answer keys.

The automatic in-app backup alone is **not** enough: Android deletes it on
uninstall. Automatic saves therefore also write the shared copy, and the app no
longer claims an uninstall-surviving copy that was never written. On devices
older than Android 10 without the all-files permission the shared copy can fail;
the app says so instead of implying the papers are safe.

No production signing credentials have been created, replaced or exposed by
this update. The previous successful workflow skipped release-keystore restore;
a new signed APK must wait for configuration and positive certificate checks.
