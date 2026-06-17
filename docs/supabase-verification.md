# Supabase Verification

The Supabase project has been reactivated, but it may take time before all
services are available. Use this checklist after the project is fully awake and
before relying on backend behavior for App Store upload.

## Current Shipping Role

Version 1 should remain local-first:

- Normal gameplay starts from the bundled reservoir.
- Supabase must not be required for first play.
- Backend failures should not block the puzzle loop.

## Verify When Project Is Ready

Project:

- Project host is reachable.
- Project URL matches `WordLink/AppConfig.swift`.
- Anon key matches `WordLink/AppConfig.swift`.

Auth:

- Anonymous sign-in currently returns `422` with `Anonymous sign-ins are
  disabled`.
- Enable anonymous sign-ins before using `AuthService` or `ChainProgressService`
  in the shipping app.
- Refresh token flow works.
- Existing stored sessions do not break launch if refresh fails.

Database:

- `chains` table exists if still used.
- `user_progress` table exists if still used.
- Required columns match app/RPC expectations.
- Row-level security policies allow only intended anonymous-user access.

Functions/RPC:

- `start-game` edge function returned `200` with `session_id`, 9 chain words,
  and 8 explanations on 2026-06-17.
- `check-guess` edge function works if kept enabled.
- `generate-chain` edge function is either working or removed/de-emphasized.
- `get_chain` RPC is either working or removed/de-emphasized.

App Behavior:

- Launch with network off.
- Start a game with network off.
- Start a game with Supabase unavailable.
- Start a game with Supabase available.
- Confirm no indefinite loading state.

## Version 1 Decision Point

Before upload, choose one:

- Keep Supabase enabled as optional backend support after verification.
- Disable backend calls for version 1 and ship fully local-first.

Do not upload with unverified backend calls that can delay or break gameplay.
