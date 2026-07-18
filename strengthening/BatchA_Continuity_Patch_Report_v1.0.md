# Aurefold — Book One Continuity Patch Report v1.0 (Batch A)

**Manuscript authority:** `Master v2.0` (85,937 words). v1.7 is superseded.
**Method:** each author-supplied audit item was **independently verified** against
Master v2.0, Constitution/Ledger v1.8, Object Ledger v1.0, Timeline v1.0, and
Character & Knowledge Map v1.0. **No master, control file, live site, or locked
canon was modified.** Everything below is a *proposal* with before/after text.

**Classes:** `EDITORIAL` · `CONTINUITY` · `CANON-AFFECTING (needs approval)` ·
`UNRESOLVED (pending source files)`.

## Summary table

| # | Audit item | Verified? | Class | Approval |
|---|---|---|---|---|
| 1 | Earth weekday names | ✅ 10 in Master v2.0 | EDITORIAL | Recommend; show-before-apply |
| 2 | Two "Month Two" references | ✅ 2 (lines 4258, 5196) | CONTINUITY (proposal) | **UNRESOLVED** — timeline has no month grid |
| 3 | "eleven years" line | ✅ 1 (line 5641) | EDITORIAL | Confirm not intentional |
| 4 | Swedish "LÅST" in English Object Ledger | ✅ 7 in Object Ledger | EDITORIAL | Recommend |
| 5 | Missing "Interlude:" prefixes in Character Map | ✅ (0 found) | EDITORIAL/CONTINUITY | Recommend |
| 6 | Recurring characters missing from Character Map | ✅ 8 absent | CONTINUITY (proposal) | Author confirm scope |
| 7 | Word count consistency | Master = 85,937 | EDITORIAL | Use "approximately 86,000" |
| 8 | Roche / Oath-hold / the Called / Mother Ilse | text-entered, unlogged | HOLD | Keep unlogged; quote-only |
| 9 | Constitution v1.0-vs-v1.1 subordinate refs / v1.7 provenance | — | UNRESOLVED | Needs Series Architecture + subordinate files |
| 10 | Two governing Book One questions | — | UNRESOLVED | Needs Series Architecture v1.3 |
| 11 | miles/km | intentional local units | NO ACTION | Do not standardize |

---

## 1. Earth weekday names → contextual internal day language (EDITORIAL)
Per instruction: replace with context-based internal expressions; **no new formal
calendar lock**; show each in context. The manuscript already ties days to
routines, so in-world names fall out naturally (Tuesday = the bread-cart day;
Thursday = Nessa's flour day).

| Master line | Before | Proposed | Basis |
|---|---|---|---|
| 360 | "**Tuesday** meant east byre, then breakfast… before the bread cart came." | "**Bread day** meant east byre…" | Tuesday IS the bread-cart day |
| 361 | "went to find her **Tuesday**." | "went to find her **bread day**." | matches 360 |
| 446 | "the **Tuesday** bread sledge" | "the **bread-day** sledge" | " |
| 1830 | "Every **Thursday** for five years." | "Every **flour day** for five years." | Thursday = Nessa/flour (3623/3627) |
| 2347 | "…arrived on a **Tuesday**." | "…arrived on a **bread day**." | keeps the ordinary-day irony |
| 3623 | "**Thursday** brought Nessa with flour." | "**Flour day** brought Nessa with flour." | " |
| 3627 | "every **Thursday**." | "every **flour day**." | " |
| 4581 | "wanted a **Tuesday** with a goat refusing the north pen." | "wanted a **bread day** with a goat…" | Sela longing for ordinary days |
| 2472 | "Yesterday isn't **Monday**." | relative rephrase — **confirm wording** (e.g. "Yesterday isn't the rest day.") | needs the 2-line exchange to fix the intended day |
| 2530 | "left the following **Monday** before daylight" | "left at the **next week's turn** before daylight" (or a named market day) | needs the weekly anchor to finalize |

→ **Recommended:** approve rows 360–4581 as-is; I'll pull the surrounding lines
for 2472 & 2530 and bring exact wording before applying. Patches go into an
**edited copy** (`Master_v2.1_proposed`), never Master v2.0.

## 2. "Month Two" (CONTINUITY — UNRESOLVED)
Two uses: line 4258 (the early cell/onions memory) and line 5196 (Wren's trial
reconstruction, later in the book). Recommended correction = the **later** one
(5196) → **"Month Three"**. **Blocked:** Timeline v1.0 contains no explicit
month grid to confirm which scene falls in which month. Holding as a proposal
until the month structure is supplied/confirmed.

## 3. "eleven years" (EDITORIAL)
Line 5641: *"It has caught your thumb for eleven years. You can survive another
road."* A casual number that can echo the Eleventh motif. **Proposed:** "ten
years" or "twelve years." Apply only if you confirm it is **not** an intentional
Eleventh reference.

## 4. "LÅST" → "LOCKED" (EDITORIAL)
Object Ledger v1.0 uses Swedish **LÅST** 7× (lines 21, 27, 51, 75, 81, 147, 153)
inside an English control file. **Proposed:** produce `Object_Ledger_v1.1` with
LÅST→LOCKED. Ready to generate as an edited copy on your go.

## 5. Interlude prefixes (EDITORIAL/CONTINUITY)
Character & Knowledge Map v1.0 has **no "Interlude:"** labels; Chapters 2 and 18
are Alaine interludes in Master v2.0. **Proposed:** restore prefixes in a
`Character_Knowledge_Map_v1.1`.

## 6. Recurring characters missing from the Character Map (CONTINUITY)
Confirmed **absent** from Character & Knowledge Map v1.0 but present in the
manuscript: **Sinnet, Aldous, Lysa, Pell, Jeren, Kessa, Moss, Bryn Corr.**
**Proposed:** add stub entries in `Character_Knowledge_Map_v1.1`, marked
**TEXT-ENTERED / UNLOGGED** — name + one-line manuscript role only, **no invented
biography, office, date, or location** (per the Canon/Spoiler Gate).

## 7. Word count (EDITORIAL)
Master v2.0 = **85,937 words**. Standardize all public/control references to
**"approximately 86,000 words."**

## 8. Text-entered but unlogged — HOLD
**Roche, Oath-hold, "the Called," Mother Ilse** (and the names in #6): may be
**quoted from excerpts** but must **not** be expanded into encyclopedia/world
copy or SEO pages until logged in the relevant control files and approved.

## 9–11. Pending / no-action
- **9 (UNRESOLVED):** Constitution subordinate refs pointing at v1.0 where v1.1
  exists, and the v1.7 provenance/supersession wording — need the subordinate
  files + Series Architecture v1.3 to verify.
- **10 (UNRESOLVED):** the two governing Book One questions — need Series
  Architecture v1.3.
- **11 (NO ACTION):** miles/kilometres are intentional local units — do not
  standardize.

## Still-required files (block full completion of 9–10)
`Series Architecture v1.3`; the Constitution **subordinate/appendix** files it
references; `06_VISUAL_MOTION_AND_ASSET_SPEC.md` (referenced by the kit, not
uploaded).

## Author decisions required
1. Approve weekday replacements (rows 360–4581) and let me finalize 2472 & 2530.
2. Confirm "eleven years" is **not** intentional → change to ten/twelve.
3. Approve generating edited copies: `Master_v2.1_proposed`, `Object_Ledger_v1.1`,
   `Character_Knowledge_Map_v1.1`.
4. Provide month grid (or ruling) to resolve Month Two→Three.
