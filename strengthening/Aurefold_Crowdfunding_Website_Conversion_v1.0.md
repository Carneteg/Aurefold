# Aurefold — Crowdfunding Website Conversion v1.0 (staging deliverable)

**Status:** STAGED on working branch `claude/emberwold-wiki-project-twfx9i`.
**Not deployed.** The live site (default/deploy branch) is unchanged. Nothing was
published, no payments touched, no Patreon post made, no DNS/hosting changed.

**Authority:** Constitution v1.8 → Ledger v1.8 → Master v2.0 + control package →
media/campaign → website (lowest, not canon). Website source is audit-only.

---

## 1. What changed (page by page)

| Page | Before | After (staged) |
|---|---|---|
| **support.html** | "Channels being set up," thin | Full pre-crowdfunding funnel: road-to-publication hero, project-status board, what-support-carries, four tiers (Traveller free / Witness 49 SEK / Chronicler 99 SEK / Keeper of the Blank Page 249 SEK), membership-vs-crowdfunding, no-cost ways to help, creative-independence note, 10-item spoiler-safe FAQ, **non-publishing** creator placeholder, closing CTA |
| **index.html** | Opened on abstract world-philosophy; invented "aure+fold" etymology; "ten seals — some say eleven" | Opens on **Sela** and the human conflict, with Read/About CTAs; adds a "road to publication" support section; world framing moved lower; **etymology removed**; Hall-of-Eleven wording ("eleven places, ten recognized voices; the eleventh remains unresolved") |
| **book.html** | Full 34-chapter list (spoiler titles), "turns east," "completed developmental draft" | Spoiler-free story pitch + reader-promise list + **publication-status** section; status corrected to **completed manuscript ~86,000 words**; chapter list and ending language removed |
| **read.html** | Two excerpts, no funnel | Same excerpts (**re-verified line-for-line against Master v2.0**) + three conversion modules (before / between / after) ending on Join-free / Follow-journey / Read-when-published |
| **houses.html** | Head + Heir named for all 10 houses (unverified/legacy) | **All leadership fields removed**; philosophy + promise/cost kept; verified Book One relevance note on Whitehart & Blackcrest; intro states leaders are held back until publication |
| **characters.html** | "Heads of the Ten Houses" roster + heir list (incl. legacy Halvard/Maren/Signe) | **Roster and heir list removed**; only verified Book One valley/Whitehart figures kept; Sela epithet softened to approved framing; Nella de-affiliated to "Duskport trader" |
| **vote.html** (Moot) | Bare "needs JavaScript" note | Scope boundary stated (polls shape **presentation only**, never canon/plot/fates/mysteries); no-JS fallback now has a real next action |
| **all pages** | Nav item "The Houses" | Renamed "**The Great Houses**" (IA naming) |
| **assets/style.css** | — | Added button, status-grid, tier-grid, FAQ-accordion, skip-link, read-module, house-relevance styles + reduced-motion + mobile rules |

## 2. Spoiler-safety verification (against Batch B matrix)

Removed from public pages: full chapter list, "The Blank Page"/"East" titles,
"Sela turns east," invented Aurefold etymology, unverified House heads/heirs,
legacy names as active, Nella=Ravenshade overstatement. No protected ending,
Eleventh-House solution, or Book Two promise appears in the staged copy.

## 3. Accessibility & SEO status
- **Done:** skip-link on support.html; `prefers-reduced-motion` honored; FAQ uses
  native `<details>` (keyboard-operable); Moot no-JS fallback; per-page canonical +
  OpenGraph + Twitter cards already present on every page; descriptive alt text.
- **Proposed (needs approval / not done):** skip-link on the remaining pages;
  WebP versions of the cover/OG/portraits for performance; map accessible
  text-list fallback + provenance line.

---

## 4. Requires YOUR decision or content (NOT done, by design)

1. **Creator/About block** — `support.html` has a marked placeholder
   (`data-placeholder="true"`) that will not go live until you supply: name,
   author photo, location, why you're making this, background, contact/press email.
2. **Full IA / "Explore" dropdown + new pages** — the prompt's 7-item nav with an
   Explore group (Map/Faces/History/Moot) and new **Journal** and **About-the-Creator**
   pages is *proposed, not built*: Journal needs first entries; About needs the creator
   details above; the dropdown is a UX choice. Staged nav keeps the flat bar with
   corrected labels in the meantime.
3. **Patreon tiers** — staged in **SEK** (49/99/249) per your currency. Confirm the
   currency and the tier names before anything goes live. Prices are **not** set on
   Patreon by me.
4. **Email/waitlist platform** — ranking below; pick one before wiring a signup.
5. **Analytics** — event plan below; **not installed** on the live site.
6. **Master v2.1 patches** — Batch A continuity fixes await your go (see
   `BatchA_Continuity_Patch_Report_v1.0.md`).

### Email platform ranking (recommendation)
1. **MailerLite** — best free tier for authors, clean automations, simple landing/embed forms. *Recommended.*
2. **Kit (ConvertKit)** — author-focused, strong sequences; free tier now usable.
3. **Buttondown** — minimal, privacy-friendly, Markdown; great for a plain dev-log.
4. **Substack** — zero setup and discovery, but weakest ownership/segmentation.

### Analytics event plan (to install only on approval)
Privacy-light (e.g. Plausible/GA4) tracking: `read_excerpt_view`,
`cta_join_free_click`, `cta_support_click`, `tier_click{tier}`, `moot_vote`,
`patreon_outbound`. No PII; no tracking added to the live site yet.

---

## 5. Approval-required before ANY deploy (per your standing constraints)
Publishing/deploying, changing DNS/hosting, setting Patreon prices/currency,
publishing Patreon posts, activating email automations, installing live tracking,
or launching crowdfunding — none done, all await explicit approval.

## 6. How to deploy (when you approve)
Live GitHub Pages serves the **default/deploy branch only**. To publish this staged
set, fast-forward the deploy branch to this working commit (as done for the earlier
rename). Until then the live site is untouched.

## 7. Rollback plan
Every change is an ordinary commit on the working branch; nothing was force-pushed
and the deploy branch is unmoved. Rollback = don't fast-forward (no-op), or
`git revert` specific staged commits, or reset the working branch to `d82c521`
(the pre-conversion "Site polish" commit). No asset was destructively overwritten.

## 8. Preview artifacts
Desktop + mobile screenshots of the staged Support, Home, and Read pages were
rendered during staging (headless Chromium) and reviewed; the pages render on-brand
in the parchment/ember system in both widths.
