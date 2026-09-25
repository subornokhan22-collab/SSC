# Content Studio — GitHub download files

Release deliverables live in GitHub, not only in chat attachments. This package contains the approved application source from commit `b5711ca46236253fdf494c1a83f744e53dc3c5ac`.

## Downloads

- [Complete update package](content-studio-update.zip) — download and extract this on your phone.
- [Website-only ZIP for Netlify](content-studio-netlify.zip) — deploy this ZIP, **not** the complete update package.
- [Supabase database update](database-update.sql) — paste the entire file into the SQL Editor.
- [Single-file Supabase AI function](admin-content.ts) — use as `index.ts` for the function named `admin-content`.
- [Short dashboard instructions](START-HERE.txt).
- [Detailed instructions included with this release](SOURCE-README.md).
- [File checksums](SHA256SUMS).

On GitHub, open a file and use **Download raw file**. For SQL or TypeScript, use **Raw** / **Copy raw file** to obtain the actual code, not the GitHub HTML page.

## Deployment order

1. Review backup options, then apply the SQL migration. It changes schema and permissions; it is not itself a backup. Stop if it reports an error.
2. Deploy the AI function and configure `GEMINI_API_KEY` in Supabase secrets for automatic photo/scan extraction. The generated single-file function bundles its local dependencies; it still imports the Supabase SDK over HTTPS.
3. Deploy the website ZIP to the existing Netlify site.
4. Test PDF/image intake, human review, publication and sync with a compatible APK.

Preparing or uploading these files to GitHub does **not** deploy Supabase or Netlify. The website ZIP must have `index.html` at the deployed root; keep `vendor/` intact. No private credentials or database backups are included. The browser's Supabase anon key is intentionally public and is not an administrator credential.

## Future delivery convention

- Upload release code, setup scripts, instructions and deployment ZIPs to GitHub with each approved update. Do not leave the only copy in a chat attachment.
- Refresh this directory's packages, source revision, instructions and checksums together whenever their contents change. These files are a versioned release snapshot, not automatically regenerated from later source edits.
- Keep passwords, private API keys, signing keys, private database backups, dependency directories and temporary test files out of Git.
- Large APK binaries belong in GitHub Actions artifacts or GitHub Releases rather than repeatedly copying them into Git history. Include their download links in the handoff.

Canonical sources: [website](../../web-admin/), [migration](../../supabase/migrations/20260925000001_content_manager.sql), [AI function](../../supabase/functions/admin-content/). Current development instructions: [web-admin/README.md](../../web-admin/README.md).
