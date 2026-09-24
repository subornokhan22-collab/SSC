# Release signing (review item #31)

Your CI is already set up for proper release signing — it only waits for
the four secrets. Until they exist, every APK is **debug-signed** (works
on your phone, but must be uninstalled before a signed build can be
installed over it, and is not Play-Store ready).

## One-time setup (~5 minutes, on any computer)

### 1. Generate the keystore (ONLY ONCE — never lose this file)

```bash
keytool -genkeypair -v \
  -keystore release.keystore \
  -storetype pkcs12 \
  -alias tutorsdesk \
  -keyalg RSA -keysize 2048 -validity 10000
```

- When asked for a "distinguished name", the organization can be your
  name; the important fields are the **store password** and the alias
  (`tutorsdesk`).
- **Back up `release.keystore` somewhere safe** (password manager,
  encrypted drive). If it is ever lost, you can never update the app on
  existing phones — a new key means a fresh install for every user.
- Do **not** commit it to the repo.

### 2. Base64-encode it

```bash
# Linux / macOS
base64 -i release.keystore    # (macOS: base64 -i; Linux: base64 -w0)
# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("release.keystore"))
```

Copy the whole single line.

### 3. Add the 4 secrets to the GitHub repo

<https://github.com/subornokhan22-collab/SSC/settings/secrets/actions>

| Secret name                  | Value                          |
|------------------------------|--------------------------------|
| `RELEASE_KEYSTORE_BASE64`    | the base64 line from step 2    |
| `RELEASE_KEYSTORE_PASSWORD`  | the keystore password          |
| `RELEASE_KEY_ALIAS`          | `tutorsdesk` (your alias)      |
| `RELEASE_KEY_PASSWORD`       | the key password (usually the same) |

### 4. Push once

The next build signs with the real key. From that point on,
**uninstall the app once** on each phone and install the new build —
Android refuses to update an app whose signature changed. Every build
after that updates normally.

## How CI uses it

`android/app/build.gradle.kts` signs release builds with `release-ci`
when the keystore + password are present (restored by the workflow from
`RELEASE_KEYSTORE_BASE64`), and falls back to debug signing otherwise —
so local development builds keep working with nothing configured.

## Also set (same Secrets page, for Phase 1 AI)

| Secret / location                                   | Value            |
|-----------------------------------------------------|------------------|
| Supabase → Edge Functions → Secrets → `GEMINI_API_KEY` | your Gemini key |

(The Supabase edge-function secrets are **not** GitHub secrets — they
live in <https://supabase.com/dashboard/project/vxexidxdoghdmzvkvgqk/functions>.)
