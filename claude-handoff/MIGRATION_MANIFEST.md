# Aurefold — ChatGPT → Claude Migration Manifest

**Date:** 17 August 2026  
**Requested by:** project owner  
**Migration type:** Context/governance handoff through the Aurefold repository.

## Goal
Make Claude capable of continuing Aurefold without depending on ChatGPT's private memory or the owner repeating historical decisions.

## What was transferred
### Durable operating instructions
- root `CLAUDE.md`
- source-authority and non-inference rules
- delegated Loremaster/editorial role
- language/workflow expectations
- hard canon guardrails

### ChatGPT-only / conversation-heavy project context
Exported to `CHATGPT_CONTEXT_EXPORT_2026-08-17.md`, including:
- owner creative goals and quality bar;
- House attachment/fandom/language direction;
- historical inspiration matrix;
- violence/realism directive;
- character voice directives;
- Book One editorial rationale and selected consequence decisions;
- reader-test results and diagnostic conclusions;
- Book Two title/premise/Una–Roan relationship and pause;
- open continuation threads;
- appearance/visual-art policy;
- GitHub/Drive/Supabase synchronization practice;
- public website/product context;
- name/register hygiene.

### Current operational state
Exported to `ACTIVE_STATE_2026-08-17.md`, including:
- governing authority line;
- Book One master identity/hash/word count/control state;
- visual description integration status;
- character-art ratification state;
- Book Two pause/source debt;
- website/infra snapshot.

### Open gates
Exported to `OPEN_THREADS_AND_GATES.md`.

### Data-system map
Exported to `DATA_SOURCES_AND_PROVENANCE.md`.

## What did NOT need physical copying
The canonical/manuscript binaries themselves already live in the project's durable systems:
- GitHub repository `Carneteg/Aurefold`;
- Google Drive `/Aurefold New`;
- Supabase `aurefold-site`.

The handoff points Claude to the current Source Registry rather than duplicating stale binaries from ChatGPT File Library.

## File Library handling
ChatGPT File Library contained multiple generations of Aurefold/Emberworld-era files. Because many are superseded, they were **not bulk-promoted or blindly copied** into the active line. Their relevant authority/provenance is already represented through current source planting, Drive and Source Registry. Historical File Library items remain recovery/provenance material, not a hidden second canon.

## Secrets
No secrets were transferred. No API/service-role keys, OAuth tokens, passwords or `.env` values are present in the handoff.

## Known limitation
There is no supported direct mechanism here to export ChatGPT's hidden internal memory database or complete raw private conversation store into Claude as native Claude memory. This migration externalizes the **Aurefold-specific content needed to continue work** into files Claude can read.

## Completeness rule
If the owner later identifies a project decision that existed only in a prior ChatGPT conversation and is missing here, add it to the handoff through a normal PR, labeled with its authority/status. Do not silently convert remembered discussion into canon.

## Success condition
The migration is successful when:
1. this handoff PR is merged;
2. Claude reads root `CLAUDE.md` and `claude-handoff/START_HERE.md`;
3. Claude uses `canon/SOURCE_REGISTRY.md` as the authority index;
4. the owner no longer needs to restate prior Aurefold working rules for routine continuation.