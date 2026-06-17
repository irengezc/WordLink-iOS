# Pre-Upload Checklist

Use this as the must-do list before uploading WordLink to App Store Connect.

## Backend And Gameplay

- Core gameplay starts from the bundled local reservoir and does not depend on
  Supabase for first play.
- Bundled reservoir has enough chains for a meaningful first release.
- Supabase is either active and verified, or all shipping backend-dependent paths
  are disabled/removed.
- Supabase was reactivated but may take time to become available; complete
  `docs/supabase-verification.md` before upload if backend paths remain enabled.
- If Supabase remains enabled, verify:
  - Project is active.
  - Project URL and anon key in `WordLink/AppConfig.swift` are current.
  - Anonymous auth works.
  - Required tables exist.
  - Required RPCs or edge functions work.
  - Row-level security policies match the app's access pattern.
  - No private server-side secrets are in the app.
- Live generation is not the normal gameplay path.

## Apple Account And App Store

- Apple Developer Program enrollment is approved.
- Bundle ID `com.wordlink.app` is available and configured.
- Team ID `XVW2C26TQX` is confirmed.
- App Store Connect app record is created.
- Support URL is live: `https://irengezc.github.io/WordLink/`.
- Privacy policy URL is available if required by the listing or SDKs.
- App Store listing copy and screenshot plan are drafted in
  `docs/app-store-submission.md`.

## Monetization

- Version 1 upload ships without ads and without remove-ads IAP.
- No AdMob SDK is required for version 1.
- No ATT prompt is required for version 1 unless another tracking SDK is added.
- Do not add monetization code before the first upload unless this decision
  changes.
- Monetization moves to version 2.

## Product Quality

- App launches cleanly on supported iOS versions.
- Loading never hangs indefinitely.
- Offline play works from the local reservoir.
- Results/history persist locally.
- Share text does not spoil answers.
- No placeholder/debug copy is visible to users.
- README/docs match the shipping architecture.
- Privacy manifest is included in the app target.

## Validation

- Run a full Xcode build with the active developer directory set to full Xcode.
- Run on at least one simulator and one physical device if available.
- Run Supabase integration tests if Supabase remains enabled.
- Archive build succeeds.
- App Store upload validation succeeds.
