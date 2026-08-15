# Aurefold Loremaster Admin

The author dashboard lives at `/admin/loremaster.html` and uses the existing Aurefold Supabase project (`akboesleczddqdikjzbw`).

## Security model

The browser contains only the existing public/anon key. It never contains a Supabase service-role key.

An authenticated user can read internal canon data only when the JWT contains:

```json
{
  "app_metadata": {
    "aurefold_role": "author"
  }
}
```

`admin` is also accepted. Ordinary authenticated users and anonymous visitors remain denied by RLS.

Assign this app metadata from a trusted administrative environment (Supabase dashboard, server-side admin tooling, or another service-role protected process). Never add a service-role secret to this repository or to client-side JavaScript.

## Current dashboard capabilities

Phase 3 is intentionally read-only. It displays:

- canon/database counts;
- Book One and Book Two scene-control rows;
- open source-debt records;
- author-only House phrase proposals.

The dashboard is not a replacement for formal ratification. Editing/promoting canon will be added only with explicit workflow controls so a UI click cannot silently create a new Canon Lock.

## Book Two source discipline

The Road Still Open is seeded from:

- Book Two Gate Decision v1.3;
- Stormrider Civilization File v1.3;
- Book Two Scene Ledger v1.0 as a governing but revisable working base.

Two open source debts are tracked in the database:

1. Book Two Spine & Chapter Architecture v1.0 is referenced but unavailable.
2. Book Two Character & Knowledge Map v1.0 is referenced but unavailable.

Therefore the thirty Scene Ledger chapters are indexed as working structure, not publication-locked architecture. Their knowledge fields remain deliberately unfilled rather than being reconstructed from assumption.

## Public boundary

The public website can currently read only curated views. Anon verification after Phase 3 returns:

- 10 Houses;
- 13 curated Book One character profiles;
- 0 House phrase proposals;
- 0 internal scenes;
- 0 internal character-engine rows;
- 0 source-debt rows.

The English Great Houses page hydrates from `site_houses` when Supabase is available and retains its static HTML as a fail-closed fallback. Localized House pages remain static until translation-aware projections exist.
