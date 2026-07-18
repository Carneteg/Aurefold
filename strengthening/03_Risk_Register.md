# Aurefold — Risk Register (Top 10, Phase 1)

**Status:** Phase 1 · Task 1.3 · nothing changed on the live site yet

Classes: CRITICAL CANON · CONTINUITY · PUBLIC SPOILER · CONVERSION ·
LEGAL/RIGHTS · ACCESSIBILITY · PERFORMANCE · LOW POLISH.
"Approval" = whether an author decision is required before I apply it.

| # | Class | Finding | Source / location | Why it matters | Recommended action | Approval |
|---|---|---|---|---|---|---|
| **R1** | PUBLIC SPOILER | The **full 34-chapter title list is published** on the book page. Titles telegraph protected beats: *The Blank Page*, *The Divided Record*, *The Gate*, *Nine Days*, *East*. | `book.html` "Contents" (I added it) | Brief Phase 5.5 says don't publish a chapter list that creates unnecessary spoilers; several protected Book One facts are hinted. | Replace the flat list with a **spoiler-safe structure** (three movements + a few non-spoiler titles). | Editorial — recommend; low-risk |
| **R2** | CONTINUITY / CANON | Site asserts **House heads & heirs** (Alder/Wren, Sabra/Lyra, Roderick/Kael, Garron, Halvard/Senna, Aldous/Vaela, Torvald/Rurik, Maren/Espen, Signe/Idun) sourced from the **superseded v27 map**, not verified against v1.8. | `data/houses.js`, `characters.html` | Publishing unconfirmed succession as fact risks contradicting locked canon; v1.8 warns characters aren't House mouthpieces. | Verify each name vs Constitution/Ledger v1.8; demote or remove unsupported ones. | **Canon-affecting** for removals |
| **R3** | CONTINUITY (manuscript) | **Earth weekday names** (Monday/Tuesday/Thursday…) appear **10×** in v1.7. | `..._Editorial_v1.7.md` | Breaks the Aurefold calendar convention (Phase 2.1 #1). | Prepare an editorial patch (replace with in-world day references) in an **edited copy**. | Author approval to change |
| **R4** | CONVERSION | **Homepage does not lead with Sela's human conflict.** Hero is atmospheric ("AUREFOLD" + tagline + genre line). | `index.html` | Brief: main entry must be Sela; preferred framing *"She may have heard a voice. The world decided what it meant."* Homepage should answer What/Who/Conflict/Read/Follow fast. | Draft a restructured homepage (staging only) leading with Sela + the hook. | Show draft; approval to publish |
| **R5** | CONVERSION | **Funnel collapses to a single paid CTA.** "Support on Patreon" points at paid; there is **no email list** and no "follow free" step. | `index.html`, `support.html`, `data/community.js` | Brief's path: Read → Join email list → Follow free → Paid → Crowdfund. "Don't send every visitor to a paid tier." | Build funnel: sample → email capture → free-follow framing. (Email = Phase 6, needs platform choice.) | Approval + platform choice |
| **R6** | AUTHORITY / SOURCE | **Public canon was derived from the superseded v27 apparatus**, not re-verified against v1.8 + v1.7. | Faces/Houses/History pages | Root cause of R2; risk of stale or contradicted facts on the public site. | Re-derive the public-safe canon from v1.8 Constitution + v1.7; reconcile page-by-page. | Per-change |
| **R7** | BLOCKER / SOURCE | **Governing files missing:** Series Architecture v1.3, the supplied continuity audit, Object Ledger, current Character & Knowledge Map, Comet/Patreon file, media/campaign/civilization files. | See `02_Access_Blockers…` | Phases 2, 3, 8, 10, 11 cannot be fully or accurately completed. | Request uploads; proceed only on present sources; mark gaps OPEN QUESTION. | You provide files |
| **R8** | BLOCKER / ACCESS | **Patreon page & live-URL browsing not accessible** here (no login; proxy 403). | Patreon; aurefold.com | Phase 8.1 audit can't be done; live perf can't be measured. | Paste Patreon tier/benefit text; I audit site from source. **Will not fabricate.** | You provide content |
| **R9** | PUBLIC CANON | **"The name" section on the homepage is placeholder wordplay I wrote** (aure + fold), presented as if meaningful. | `index.html` "The name" | Not author canon; risks reading as established lore. | Mark NON-CANON; replace with your intended meaning, or cut. | Author meaning |
| **R10** | PERFORMANCE / POLISH | **Cover is an interim raster edit** (plain serif AUREFOLD, not the bespoke title) — and it is also the **OG share image**; **11 Book One cast lack portraits**. | `assets/cover_bell_of_silence.jpg`, `assets/og-image.jpg`, `characters.html` | The cover is the #1 visual and the social preview; interim quality caps presentation. | Production cover (needs your wrap/font); generate the 11 portraits. | You provide assets |

**Not in the top 10 but logged:** reduced-motion support for the scroll hint;
structured data (JSON-LD Book/Person) for SEO; image compression pass; the
"ten seals — some say eleven" line vs the Hall-of-Eleven framing (verify the
public wording keeps the mystery unsolved — currently consistent).
