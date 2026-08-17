# Aurefold — Data Sources and Provenance Map

**Date:** 17 August 2026  
**Purpose:** Tell Claude where the durable project data lives and how to interpret it.

## 1. GitHub
**Repository:** `Carneteg/Aurefold`

Primary purposes:
- readable canon/control mirrors;
- Source Registry and checksums;
- implementation records;
- review packages;
- migrations/tests;
- public website and community code;
- PR history / adoption provenance.

Recent active base branch used throughout current work:
- `claude/interactive-house-map-rzboaq`

Do not infer authority from branch/file age alone. `canon/SOURCE_REGISTRY.md` is the active index.

### Important directories/files
- `canon/SOURCE_REGISTRY.md` — START HERE for authority.
- `canon/SHA256SUMS.txt` — checksum registry.
- `canon/` — current readable control files and administrative records.
- `review/` — historical/editorial review evidence; not canon merely by existence.
- `sources/` — source planting/provenance; may include stale historical lines.
- `claude-handoff/` — this ChatGPT-to-Claude administrative context transfer.
- root `CLAUDE.md` — Claude operating instructions.

Recent relevant PR lineage before handoff includes:
- #75 adopt Book One Master v1.7.
- #76 revalidate v1.7 control layer.
- #77/#78 Kimi BOSSDOM two-passage patch + sync.
- #80 add Appearance Bible v1.0.
- #83 appearance expansion + manuscript visual anchors.
- #85 close visual recognition blind spots; add v1.2.
- #87 ratify 36 character-art references.
- #88 latest website design-council pass.

## 2. Google Drive
Active workspace is **`/Aurefold New`**.

Older duplicates and `/Aurefold Old` are provenance/archive unless current registry explicitly says otherwise.

### Critical known IDs
- Governing Book One master v1.7: `1PWNoFCCwW4c0fHzNFSjK-BNp__I9huR9`
- Active Aurefold New folder: `1udEMENbIrHQJFssZDbzgZqpTQDGbELTP`
- Constitution v1.9: `1VAw1iJmZGPGKtwaGWQTtwUQhfC9MqWmz`
- Canon Ledger v1.9: `1LHiAsvNewYLS1crOH8Sl2MrMr9X4Ah7P`
- Character Voice & Rhythm Canon v1.0: `1KJ7Ve5I_jHp0YakrFqwfcJULeZB36vcC`

Use the live Source Registry/checksum record for current file hashes and authority; do not rely on an ID alone to infer version/content.

## 3. Supabase
**Project:** `aurefold-site`  
**Project ref:** `akboesleczddqdikjzbw`  
**Region:** eu-north-1 at last observed project metadata.

Supabase stores structured operational/control data including:
- canon documents;
- canon locks;
- manuscript versions/sections;
- section-body hashes;
- scene scorecards and control state;
- character/lore entities;
- appearance prose / motifs / guardrails;
- site/community data;
- polls;
- character art metadata;
- Storage bucket `character-art`.

### Character art
At handoff:
- 78 tracked images.
- 36 `ratified`.
- 42 `proposal`.
- current owner-directed bucket state: **public**.

A prior Kimi workflow generated temporary 7-day signed QC URLs when the bucket was private. Those fields may still exist but are not the current access model.

### Hash discipline
Many author-control tables bind analysis to exact manuscript-section SHA-256 values. If prose changes, old hash-bound analysis must be considered stale until explicitly rebound/revalidated. Never mass-update hashes just to make status green; first prove the underlying analysis remains valid.

## 4. ChatGPT File Library / uploaded files
The prior ChatGPT project had many Aurefold source and archive files uploaded across conversations. Important discovered examples include:
- Aurefold Constitution / Canon Ledger versions;
- Series Architecture files;
- Book One Canon Appendix / reconstruction/control packages;
- Stormrider civilization and Book Two gate/scene materials;
- Living Archive proposal compilation;
- renaming/migration gates;
- historical editorial analyses.

Many File Library versions are now stale or superseded. They should be used for provenance or recovery, **not as an authority shortcut**. Active sources have been planted/indexed in GitHub/Drive through the current Source Registry.

## 5. ChatGPT memory/context
ChatGPT held project-specific memory about:
- owner working style and delegated authority;
- creative preferences;
- House-language/fandom goals;
- reader-test conclusions;
- Book Two pause;
- author-only historical inspiration matrix;
- open continuation threads;
- migration/sync habits;
- rationale behind visual/character decisions.

That content is externalized in `CHATGPT_CONTEXT_EXPORT_2026-08-17.md` and companion handoff files. Claude should no longer need hidden ChatGPT memory for ordinary project continuation.

## 6. Public website
The website and community surfaces live in this repository and are actively edited through Claude Code.

Public content is **reader-facing**, spoiler-controlled and subordinate to author-only canon. Never use the website as evidence to override a governing source.

## 7. No secrets transferred
This handoff intentionally contains:
- project IDs;
- file IDs;
- paths;
- hashes;
- public/administrative metadata;

It intentionally does **not** contain:
- service-role keys;
- private API keys;
- passwords;
- `.env` contents;
- OAuth tokens.

Claude should use existing connected environments/approved secret stores rather than committing credentials.

## 8. Provenance rule
When sources disagree:
1. current owner instruction;
2. Constitution / current canon hierarchy;
3. live Source Registry;
4. current governing source file;
5. current subordinate control within scope;
6. handoff context for rationale;
7. historical review/archive for provenance only.

Do not silently reconcile a contradiction. Record it and resolve through the appropriate authority path.