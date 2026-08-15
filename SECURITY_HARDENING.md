# Security Hardening v1

Point 13 closes the previously recorded Supabase privilege debt without changing Aurefold canon or public story data.

## Remediation

- `is_staff()` is now `SECURITY INVOKER`; it only reads trusted `app_metadata` and never required owner privileges.
- `bump_download(text)` remains a stable public RPC, but its privileged update implementation lives in the non-exposed `aurefold_private` schema behind a narrow invoker wrapper.
- Fifteen legacy author RPC implementations now live in `aurefold_private`. Their public signatures are preserved by `SECURITY INVOKER` wrappers.
- Every privileged author implementation was migration-guarded for three preconditions: fixed `search_path`, no dynamic SQL, and an explicit `is_aurefold_author()` authorization check.
- Anonymous users cannot execute any author RPC or any private author implementation.
- Default function privileges for the project-owned `postgres` role no longer auto-grant `EXECUTE` to `PUBLIC`, `anon`, or `authenticated` in `public`. New project APIs require an explicit grant. Supabase's platform-owned `supabase_admin` defaults are outside the project role's authority and remain monitored by Database Advisor.

The private implementations retain definer execution only because the older workflows write across author-only RLS tables. They are no longer directly addressable through the exposed `public` Data API schema. Public API entrypoints are invoker-secured and retain the internal author check.

## Posture controls

The author-only security workspace reads four live catalog views:

- `author_security_function_inventory`
- `author_security_rls_inventory`
- `author_security_view_inventory`
- `author_security_posture`

The posture is `hardened` only when all of the following are zero:

1. anon-executable public `SECURITY DEFINER` functions;
2. authenticated-executable public `SECURITY DEFINER` functions;
3. public tables without RLS;
4. exposed non-invoker views;
5. default function-execute grants to public client roles.

Use `/admin/security-hardening.html` for the live audit surface. This layer is operational infrastructure and deliberately does not create story-canon dependency nodes.
