# Ironlog

Workout, nutrition, and bodyweight tracker. Static PWA on GitHub Pages, data in Supabase (free tier).

## Phase 1 scope

Email/password accounts, bodyweight logging (one entry per day, edit by tapping a row), trend chart with a 7-day average, lb/kg toggle, JSON export, installable on iPhone home screen.

## Files

| File | Purpose |
|---|---|
| `index.html` | The whole app (HTML, CSS, JS) |
| `schema.sql` | Tables, row level security policies, signup trigger |
| `sw.js` | Service worker: offline app shell, caches libraries and fonts, never caches API calls |
| `manifest.webmanifest` | PWA install metadata |
| `icons/` | App icons |

## Setup

1. Create a free project at supabase.com. Pick the region closest to you (US East is fine for Tampa). Keep the Data API on, leave "Automatically expose new tables" off (the schema grants access explicitly), and turn on automatic RLS as a safety net.
2. Open the SQL Editor, paste all of `schema.sql`, and run it.
3. In Authentication URL settings, set the Site URL to your GitHub Pages URL (for example `https://<user>.github.io/ironlog/`) and add the same URL to the allowed redirect URLs. This is where account confirmation emails send people.
4. In the project's API keys settings, copy the Project URL and the publishable key (older projects call it the anon key). Paste both into the two constants near the top of the script in `index.html`. Do not use the secret or service_role key.
5. Push the folder to a GitHub repo and enable Pages for the main branch root.
6. On iPhone, open the URL in Safari, tap Share, then Add to Home Screen.

Note: an iPhone home-screen app has its own storage separate from Safari. Confirm your account from the email (it opens Safari), then sign in inside the home-screen app.

## Security notes

- The publishable key is meant to be public. Row level security is what protects data, and every table has it enabled with owner-only policies.
- Verify isolation before inviting anyone: create two test accounts, log a weigh-in on each, and confirm neither can see the other's entries.
- Supabase's built-in email sender is rate limited to a few emails per hour. Fine for a handful of users; add a custom SMTP provider before opening signups wider.
- Free projects pause after about a week with no activity. Regular logging keeps it awake, and a paused project can be restored from the dashboard.

## Deploying updates

Bump `VERSION` in `sw.js` on every deploy so installed copies fetch the new files.

## Status

**Tested** (headless Chromium at iPhone size, against a mock Supabase client):
- Sign-in flow, data load, and routing between setup, sign-in, and app views
- Saving, updating (same date), and deleting weigh-ins
- lb/kg toggle, conversions, and range validation
- Chart rendering with 7-day average and range buttons
- JavaScript syntax for `index.html` and `sw.js`

**Not yet tested:**
- `schema.sql` against a live Supabase project (no database available in the build environment)
- Real Supabase auth, including email confirmation and session refresh
- Service worker offline behavior and install on a physical iPhone
- Google Fonts loading (the test environment had no internet, so screenshots used fallback fonts)

**Deferred to later phases:**
- Saving weigh-ins while offline (currently view-only offline, from the last synced copy)
- Onboarding, exercise library, program generator, calendar scheduling (Phase 2)
- Workout logging and progressive overload (Phase 3)
- Nutrition and local AI food scan (Phase 4)
- Buddy sharing (Phase 5)
