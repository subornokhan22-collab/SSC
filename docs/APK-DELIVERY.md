# APK delivery — standing rule

**Every change is built, published and verified as an APK in this repository.**
The owner tests on an Android phone from GitHub Releases, so a change is not
delivered until a downloadable APK exists and its signature and checksum have
been checked.

## What happens on every branch push

`.github/workflows/build_apk.yml` runs the quality gates and then, on any
non-tag push:

1. Builds **release mode** (`--release --split-per-abi`) so animation runs AOT
   exactly as it will in production. A debug build would stutter and make motion
   work impossible to judge.
2. Signs with the runner's **debug** key via `allowTestSigning=true`. This is
   what makes the build installable without keystore setup, and it is also what
   makes it undistributable: no production identity is involved.
3. Asserts with `apksigner` that every APK really carries the Android Debug
   identity — the inverse of the production rule, and the proof that no release
   key was used.
4. Uploads the APKs as a run artifact and publishes a prerelease
   `test-build-<run number>`.
5. Posts a verification table on the pull request: per-APK size, SHA-256 prefix,
   signer identity and a direct download link.

Install the **arm64-v8a** APK. If the signature differs from the build already
on the phone, Android refuses to update it — uninstall first. Since build 368
the app writes `Download/TutorsDesk/tutors_desk_backup.json` and restores from it
on a fresh install, so an uninstall no longer costs the paper library. Back up
from My Papers before uninstalling.

## What a tag still requires

Tags never take the test path. `v*` tags require the four release secrets and the
`RELEASE_CERT_SHA256` pin, verify each APK's certificate against that pin, and
fail the run rather than fall back to a debug signature. See
`RELEASE-SIGNING.md`.

## Why failures are posted to the pull request

Workflow logs and artifacts are served from blob storage that is not reachable
from every editing environment (the API returns a 302 to it). So a failed run
posts its log tails to the pull request, and a successful run posts its APK
verification table. The pull request is the record; the runner log is not.
