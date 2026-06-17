# Monetization Spec

## Goal

Add a real revenue mechanism without harming the core word-puzzle experience.
The committed model is:

- Free app.
- Non-intrusive ads.
- One-time in-app purchase to remove ads.

Subscriptions are explicitly out of scope for the near term. A puzzle game needs
trust and repeat habit before a subscription can be justified.

## Release Timing

Monetization is deferred to version 2. The first App Store upload should ship
without ads and without remove-ads IAP.

This keeps the first review and launch simpler while the core gameplay,
reservoir, Supabase status, and App Store listing are stabilized.

## Ad Model

Use AdMob for the iOS app.

Baseline placement:

- Interstitial ad between completed levels / chains.
- Never interrupt a player mid-chain.
- Do not show an ad before the first meaningful play session.
- Do not show ads to users who bought remove-ads.

Initial frequency:

- Start conservative: one interstitial after completing a chain.
- Add cooldown logic if the app later adds shorter sessions or retries.
- Rewarded ads are not part of the first monetization pass.

Policy and business notes from the handover:

- There is no minimum user count required to integrate AdMob.
- The account holder must be 18+.
- Payout begins only after the AdMob minimum balance threshold is reached.
- Early earnings will be small until daily active users grow.
- Web ads would use AdSense, not AdMob, and are not in scope.

## iOS Implementation Notes

Expected implementation areas:

| Need | Likely Location |
|---|---|
| Ad SDK setup | App entry / app delegate equivalent |
| Interstitial loading and display | New ad service, called from results transition |
| Remove-ads entitlement | New purchase service using StoreKit |
| Purchase UI | Results/home/settings surface, depending on UX decision |
| Purchase persistence | StoreKit transaction state, not only UserDefaults |
| ATT prompt | App launch or first ad-relevant moment |

Current repo status verified on 2026-06-17:

- No Google Mobile Ads SDK integration found.
- No StoreKit remove-ads purchase flow found.
- No ATT usage-description key found in the scanned project files.
- The Xcode project targets iOS 16.0.

Version 1 decision:

- Do not add AdMob for the first upload.
- Do not add remove-ads IAP for the first upload.
- Do not add ATT unless another tracking dependency makes it necessary.

Version notes from the handover:

- Google Mobile Ads iOS SDK v12.0.0 requires Xcode 16.0+.
- Re-verify current SDK and Xcode requirements at implementation time.

## Remove-Ads IAP

Product shape:

- One-time non-consumable purchase.
- Clear label: remove ads permanently.
- Purchase should remove interstitial ads only; it should not gate content.
- Restore purchases must be available.

Behavior:

- If entitlement is active, do not load or present ads.
- If purchase state cannot be verified, fail gracefully and avoid blocking play.
- Do not store the purchase as the only source of truth in UserDefaults.

## ATT And Privacy

ATT is required for tracking-based ad personalization on iOS. Implement the
consent flow before or alongside AdMob.

Guidelines:

- Use clear `NSUserTrackingUsageDescription` copy.
- Ask at a contextually reasonable moment, not during a puzzle.
- The app should work if the user denies tracking.
- Non-personalized ads should remain possible when tracking is denied.

## Credential And Config Prerequisite

Keep this pattern before adding AdMob IDs, IAP identifiers, or other
monetization config.

Current status:

- Supabase client config is centralized in `WordLink/AppConfig.swift`.
- Existing services and Supabase integration tests read from `AppConfig`.
- Supabase host is reachable and `start-game` returned a valid response on
  2026-06-17. Anonymous sign-in currently returns `422` because anonymous
  sign-ins are disabled.

Notes:

- Supabase anon keys are public-client credentials, but keeping them duplicated
  as source literals makes rotation/config changes brittle and encourages
  adding more sensitive config the same way.
- Keep environment/config access centralized before adding monetization
  identifiers.
- Do not commit private API keys or server-side secrets to the app.

## Acceptance Criteria

- Ads display only between chains/levels and never mid-chain.
- Remove-ads purchase disables ads after purchase and after restore.
- ATT prompt and usage description are present where required.
- App remains playable with no network, ad load failure, or purchase failure.
- Config is centralized and avoids newly duplicated literals.
- Monetization behavior is documented in this file after implementation.
