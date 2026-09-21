# bKash auto-pay → Pro setup (one-time, ~30 minutes)

The app side is already built. This document finishes the last 3 pieces,
all from two dashboards — no code to change unless you want different prices.

You need two accounts:

1. **Supabase** — you already have one (the app's login uses it):
   `https://supabase.com/dashboard → project vxexidxdoghdmzvkvgqk`
2. **bKash merchant** — the part you are still applying for.

---

## Step 1 — bKash merchant account (apply now)

1. Open **https://merchant.bka.sh** and sign up (or log in).
   You can also call bKash merchant support: **16127** (from a bKash
   account) or **09614-999900**.
2. Complete the merchant registration (NID, bank account, business info —
   for an individual tutor a simple "tutoring services" description works).
3. When it is approved, open **Merchant Dashboard → Payment App** (or
   "API / Payment Application") and create an app:
   - Purpose: "Online payment — Tutor's Desk Pro subscription"
   - Environment: create **Sandbox first** for testing, **Production** for real money.
4. From the app page write down 4 values (shown once — store them safely):
   - **Merchant ID** (`merchantId`)
   - **Public Key**
   - **Private/Secret Key**
   - **Access Token**
5. Also keep the **notify/callback URL** field: use
   `https://vxexidxdoghdmzvkvgqk.supabase.co/functions/v1/bkash`

While the account is being approved you can still finish Steps 2–3 with
sandbox keys — the whole flow works end-to-end in bKash's sandbox.

## Step 2 — one SQL command in Supabase

1. Supabase dashboard → **SQL Editor → New query**.
2. Paste the whole contents of `supabase/migrations/20260921000000_bkash.sql`
   (from the app's GitHub repo) and press **Run**.
3. It should say "Success". (Safe to run more than once.)

## Step 3 — deploy the payment function

1. Supabase dashboard → **Edge Functions → New function**.
2. Name: **`bkash`** (exactly, lowercase).
3. Paste the whole contents of `supabase/functions/bkash/index.ts`
   and **Save and Deploy**.
4. Open **Edge Functions → Settings → Secrets** and add:

   | Secret name | Value |
   |---|---|
   | `BKAASH_MERCHANT_ID` | your merchant ID |
   | `BKAASH_PUBLIC_KEY` | the public key |
   | `BKAASH_PRIVATE_KEY` | the private/secret key |
   | `BKAASH_ACCESS_TOKEN` | the access token |
   | `BKAASH_NOTIFY_URL` | the URL from Step 1.5 |
   | `BKAASH_BASE_URL` | **only for sandbox testing:** `https://sandboxipgs.bka.sh/collectiongateway/api/v2.2` — remove it before going live |

5. Done. The app picks it up automatically — no app rebuild needed for
   this step.

## Step 4 — test it

1. In the app: **Upgrade to Pro → choose a plan → Pay with bKash**.
   The bKash sandbox app/portal opens. Pay with the sandbox number
   (bKash sandbox buyer number + OTP from the bKash app).
2. Come back to Tutor's Desk — the "Waiting for bKash" screen checks
   automatically every 4 seconds and Pro turns on by itself when bKash
   confirms the money.
3. If anything misbehaves, tell me what the red dialog says — the exact
   bKash error is shown in it.

## Changing the prices later

Two files must match:

- `lib/services/bkash_service.dart` → the `plans` list (the app's buy screen)
- `supabase/functions/bkash/index.ts` → the `PLANS` map (re-deploy after editing)

If a price changes **mid-subscription**, existing users keep their
current expiry (stored in `profiles.pro_until`).

## Safety notes

- The private key and token live **only** in Supabase secrets — they are
  never inside the APK, so a cracked app cannot take money.
- The app can only verify payments **it started itself** (TrxID whitelist
  in `bkash_payments`), so a random TrxID cannot unlock Pro.
- Amounts are fixed by the function; the app cannot ask for a different
  price.
