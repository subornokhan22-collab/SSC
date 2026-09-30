# Content Studio update — 2026-09-27

The admin panel was the deferred half of the Alive UI work. Same discipline as
the app: motion only where it carries information, colour from the existing
tokens, and nothing that loops forever.

## What changed

**Motion, gated by a real preference.** Entrances stagger (capped at four steps,
so a long table never takes longer to settle than to load), badges and the
notice bar cross-fade, and a pressed button gives way. Reduced motion is applied
when the operating system asks for it **or** when the teacher chooses it in
Settings → Studio motion; the choice persists in `localStorage` and the state
line says which one is active.

**Skeleton loading.** `render()` paints the shape of the incoming content with
`aria-busy`, instead of a line of text.

**Dashboard counters** ease up to the exact total the server returned. The
easing lives in `content-core.js` as `countUpFrame`, which is pure and covered by
Node tests, so the displayed number cannot overshoot or invent a value.

**Scoped task locking — a bug fix.** `task()` used to disable *every* button on
the page and then re-enable *every* button, which silently re-enabled buttons
that were disabled for a reason of their own. It now locks only the nearest
`dialog` or `#main`, marks what it locked, and unlocks only those.

**Drop zones.** Every file input is wrapped in a target that answers while a
file is hovering, and hands the dropped file to the existing handler.

**Off-canvas navigation** below 900px, with `aria-expanded`, a scrim, Escape to
close, focus moved into the drawer and focus returned to the toggle. The
pre-existing narrow-screen rules assumed the sidebar stayed in flow, so the
reserved margin and horizontal nav strip are corrected.

**`Ctrl`+`K` command centre** for every workspace plus the common actions, with
arrow-key navigation and `aria-selected`.

**Session expiry** is now named: an auth error says the session expired and
offers to sign in again, instead of surfacing as a generic failure under
whatever the teacher happened to be doing.

**Blob URL leak fixed.** The figure preview created a new object URL per
selection and never revoked one; it now releases the previous URL on
replacement. Validation workers were already terminated on both paths.

## Verification

- `node --test web-admin/tests/*.test.cjs` — **10 passed** locally, including the
  new `motion.test.cjs` covering count-up bounds and the motion preference
  resolution.
- Playwright specs (`web-admin/tests/studio-motion.spec.cjs`) cover the counter
  settling on the real total, the drawer opening/navigating/closing, `Ctrl+K`
  navigation, the drop zone, the scoped-lock regression and the motion switch
  persisting across a reload. These run in CI only; this environment has no
  Node modules or browser.
- Skeleton loading has **no** automated test: in demo mode the view resolves too
  fast to observe the intermediate state reliably, and asserting a DOM node I had
  just written myself would have proved nothing.
- The Netlify bundle and the complete update package were rebuilt and
  `SHA256SUMS` regenerated; all eight entries verify.

## Still open

Upload progress with cancellation, and a distinct success state on save/publish.
