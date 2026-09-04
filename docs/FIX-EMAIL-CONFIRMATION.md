# No confirmation code arriving

## Do this first — it takes one toggle

**Turn email confirmation off.** Open this on your phone:

<https://supabase.com/dashboard/project/vxexidxdoghdmzvkvgqk/auth/providers>

Expand **Email**, switch **Confirm email** to **OFF**, tap **Save**.

Now sign-up sends no email at all — the tutor types an email and password
and goes straight into the app.

**No app change is needed.** The code already handles this:

```dart
// signup_screen.dart
if (AuthService.hasSession) {   // session came back immediately
  await _finish();              // skip the code step entirely
  return;
}
```

Try signing up again straight after saving. If it works, you are done and
can ignore the rest of this file.

**Trade-off:** anyone can register with an address they do not own. For a
tutor tool with a small known user base that is normally fine.

---

## Why no email is arriving

The app is not at fault. `signUpWithPassword` really does call Supabase, and
any failure is surfaced through `friendlyError` rather than swallowed. The
config is correct too — the project URL and the anon key both point at
`vxexidxdoghdmzvkvgqk`, and the key is valid until 2036.

That leaves the mail server, and there are three usual causes.

### 1. Supabase's built-in email is rate-limited (most likely)

A free Supabase project sends through a shared testing mailer capped at
roughly **2–4 emails per hour**, across the whole project. During testing
that cap is very easy to hit, and once you do, later sign-ups silently send
nothing — no error appears in the app.

Check it here:

<https://supabase.com/dashboard/project/vxexidxdoghdmzvkvgqk/auth/rate-limits>

If "Rate limit for sending emails" is a small number, that is your answer.
Wait an hour, or switch confirmation off as above.

### 2. The template sends a link, not a code

Even when email does arrive, the default template contains a
`localhost` **link** rather than the 6-digit code the app asks for. That is
the `ERR_CONNECTION_REFUSED` page you saw.

Fix at:

<https://supabase.com/dashboard/project/vxexidxdoghdmzvkvgqk/auth/templates>

With **Confirm signup** selected, replace the body with:

```html
<h2>Confirm your email</h2>
<p>Enter this code in the app to finish signing up:</p>
<p style="font-size:28px;font-weight:bold;letter-spacing:4px">{{ .Token }}</p>
<p>The code expires in one hour.</p>
```

`{{ .Token }}` is the 6-digit code. The default `{{ .ConfirmationURL }}` is
the broken link.

Also set **Site URL** away from `localhost` at:

<https://supabase.com/dashboard/project/vxexidxdoghdmzvkvgqk/auth/url-configuration>

Any real address works, e.g. `https://tutorsdesk.app`. The app never opens
it.

### 3. The mail is in spam

Supabase's shared sender is frequently filtered. Check the spam folder
before assuming nothing was sent.

---

## Where to see the truth

The auth log shows every sign-up attempt and whether the mail was accepted:

<https://supabase.com/dashboard/project/vxexidxdoghdmzvkvgqk/logs/auth-logs>

Sign up once, then refresh that page.

- **A row appears, no email** → rate limit or spam (causes 1 and 3).
- **No row at all** → the request never reached Supabase; check the phone's
  internet.

---

## For real users later

The built-in mailer is for testing only and should not be used in
production. When you are ready, connect your own SMTP — Resend, SendGrid and
Brevo all have free tiers — at:

<https://supabase.com/dashboard/project/vxexidxdoghdmzvkvgqk/settings/auth>

Under **SMTP Settings**, enable custom SMTP and paste the host, port, user
and password your provider gives you. Delivery becomes reliable and the
hourly cap disappears.

---

## Why this could not be fixed in code

Every one of these is a setting inside your Supabase project rather than
something in this repository, and this sandbox cannot reach `supabase.co`
at all — every request to it returns `000`. The changes have to be made
from your browser while signed in to the dashboard.
