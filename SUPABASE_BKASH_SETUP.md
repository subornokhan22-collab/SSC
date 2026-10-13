# Legacy bKash migration note

bKash is no longer an active payment integration. Existing bKash transaction rows and the legacy Edge Function are retained only for historical migration/audit purposes.

New subscriptions must use:

- `subscription_plans`
- `subscription_transactions`
- `supabase/functions/rupantor-pay`
- `SUPABASE_RUPANTOR_SETUP.md`

Do not add new bKash credentials or call the legacy function from the application.
