# Fixing "localhost refused to connect" on the confirmation email

## What is going wrong

The app asks new users for a **6-digit code**. Supabase is instead emailing
a **confirmation link**, and that link points at `localhost` — a web address
that only means anything on the machine that generated it. Your phone has
nothing running there, so Chrome shows `ERR_CONNECTION_REFUSED`.

Nothing is broken in the app. Supabase's default email template sends a
link, and its default Site URL is `http://localhost:3000`. Both are dashboard
settings.

This is a one-time change and takes about two minutes on your phone.

---

## The fix: make Supabase send a code instead of a link

**1.** Open the email template settings:

<https://supabase.com/dashboard/project/vxexidxdoghdmzvkvgqk/auth/templates>

**2.** Make sure the **Confirm signup** template is selected.

**3.** Delete everything in the message box and paste this in:

```html
<h2>Confirm your email</h2>
<p>Enter this code in the app to finish signing up:</p>
<p style="font-size:28px;font-weight:bold;letter-spacing:4px">{{ .Token }}</p>
<p>The code expires in one hour. If you did not create an account, ignore this email.</p>
```

**4.** Tap **Save**.

The important part is `{{ .Token }}` — that is the 6-digit code. The default
template uses `{{ .ConfirmationURL }}`, which is the link that fails.

---

## Also set the Site URL

Even with the code template, Supabase warns when the Site URL is still
`localhost`.

**1.** Open:

<https://supabase.com/dashboard/project/vxexidxdoghdmzvkvgqk/auth/url-configuration>

**2.** Change **Site URL** from `http://localhost:3000` to:

```
https://tutorsdesk.app
```

The app never opens this address — it only needs to be a real URL rather
than localhost. Any domain you own works.

**3.** Tap **Save**.

---

## Test it

1. Open Tutor's Desk and create an account with an email you can read.
2. The email should now contain **a 6-digit number, not a button**.
3. Type the number into the app.

You should land in the app with your workspace created.

---

## The quicker alternative: skip confirmation entirely

If you would rather people sign up and get straight in with no email at all:

**1.** Open:

<https://supabase.com/dashboard/project/vxexidxdoghdmzvkvgqk/auth/providers>

**2.** Expand **Email**.

**3.** Turn **Confirm email** OFF, and save.

The app already handles this. `signUpWithPassword` checks whether a session
came back immediately:

```dart
final res = await _c.auth.signUp(email: e, password: password);
// When email confirmation is disabled in the Supabase project the session
// arrives immediately and no code needs to be entered.
if (res.session != null) _profileCache = null;
```

and `signup_screen.dart` skips the code step when that happens. So turning
confirmation off needs no code change at all.

**Trade-off:** anyone can sign up with an address they do not own. For a
tutor tool with a small, known user base that is usually fine. Keep
confirmation on if you plan to open sign-ups publicly.

---

## Why this could not be fixed in code

Both the email template and the Site URL live in your Supabase project, not
in the repository. This sandbox also cannot reach `supabase.co` at all
(every request returns `000`), so the change has to be made from your
browser while signed in to the dashboard.
