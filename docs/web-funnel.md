# Web Funnel

## Decision

Web's job is to drive App Store installs. Do not build a full playable web game
as a second product right now.

A full web version would split a solo builder's focus and is unlikely to pay off
early. Web ad revenue is explicitly not a near-term goal.

## Tier 1: Landing Page

This is the committed web item.

Use the existing GitHub Pages / support site:

- `https://irengezc.github.io/WordLink/`

Purpose:

- Give people a shareable link.
- Explain the game quickly.
- Emphasize the ESL / vocabulary angle.
- Drive App Store installs.

Recommended content:

- One clear explanation of the 9-word chain mechanic.
- Screenshots or a short GIF of actual gameplay.
- English-learning value: compound phrases, idioms, explanations, fluency.
- Prominent "Download on the App Store" button.
- Support/privacy links as needed for App Store review.

Design guidance:

- The first viewport should show WordLink and the actual game.
- Do not make an abstract marketing page with no gameplay evidence.
- Keep it lightweight; this should be about a day of work, not a parallel app.

## Tier 2: One Playable Demo Level

Deferred. Only consider this if Tier 1 shows meaningful traffic.

Shape:

- One browser-playable chain.
- Stop at a "continue on the app" wall.
- Make the wall feel like a natural cliffhanger.
- Do not provide a complete substitute for the mobile session.

Technical direction:

- Build as standalone plain JavaScript or a tiny React app.
- Keep it fully decoupled from the Swift codebase.
- Do not try to share iOS game logic with the web demo.

## Architecture Flag

Do not architect the iOS app for web reuse now.

Keep the iOS build clean and focused. If web ever becomes a real product, its
front end would likely be rebuilt anyway. Premature cross-platform abstraction
would slow the iOS launch for a payoff that may never happen.

## Acceptance Criteria For Tier 1

- Landing page is published on the existing GitHub Pages site.
- Page shows actual game screenshots or a short gameplay clip.
- ESL / vocabulary positioning is visible above or near the first install CTA.
- App Store CTA is prominent.
- No playable full web game is introduced.
