# AUREFOLD — promotional site

Static promotional website for the fantasy series **AUREFOLD**
(Book One: *The Bell of Silence*). Plain HTML/CSS/JS — no frameworks,
no build step, no external assets. Open `index.html` in a browser, or serve
the folder with any static file server (works as-is on GitHub Pages).

## Canon source files

> **Naming:** the world and series are **Aurefold** (Canon Lock #001, author
> decision 18 July 2026 — an editorial change, not an in-world event).
> *Aurelion* is the ancient pre-House empire and the internal project name,
> never the world. The retired dev names *Emberwold* / *Vareld* survive only as
> provenance.

**Live authority (v1.8 / v1.7):**

| File | Purpose |
| --- | --- |
| [`Aurefold_Constitution_v1.8_Canonical.docx`](Aurefold_Constitution_v1.8_Canonical.docx) | **The supreme canon.** Canon Locks #001–#084; replaces all earlier Constitutions. Confirms Aurefold (world) / Aurelion (project + ancient empire) and the **Tenfold Compact**. |
| [`Aurefold_Canon_Ledger_v1.8.docx`](Aurefold_Canon_Ledger_v1.8.docx) | Running index of the locks. |
| [`Aurefold_Book_One_The_Bell_of_Silence_Editorial_v1.7.md`](Aurefold_Book_One_The_Bell_of_Silence_Editorial_v1.7.md) | **Prose master** — Book One, prologue + 34 chapters. The **Book One** and **Read** pages follow it. |
| [`Aurefold_Book_One_Editorial_Change_Log_v2.2.md`](Aurefold_Book_One_Editorial_Change_Log_v2.2.md) | What the v1.7 commercial/pacing pass changed. |

**Superseded, retained as provenance:** the v27.0 apparatus (`Aurefold_Lore_Bible_v27_0.md`,
`Aurefold_Book1_Spine_v27_0.md`, `Aurefold_Character_Map_v27_0.md`,
`Aurefold_Character_Arcs_Book1_v27_0.md`, `Aurefold_Image_Index_v27_0.md`,
`Aurefold_Character_Atlas_Update_Brief_v27_0.md`, the v27 status/overview/changelog,
and the v31 prose master) plus the v26 files (`lore-bible.md`, `Aurefold_STATUS_NASTA_STEG.md`,
`scenes/`). These are Emberwold/early-Aurefold-era; the v1.8 / v1.7 files above govern where they disagree.

## Pages

| Page | Contents |
| --- | --- |
| `index.html` | Hero, series pitch, Book One announcement, the name, optional chart plate |
| `book.html` | Book One: *The Bell of Silence* — where it begins, the shape of the book (a completed draft: prologue + 34 chapters, 2 interludes), and a full contents list |
| `houses.html` | The Ten Great Houses — expandable cards |
| `map.html` | Interactive chart of the Banner-lands with every house seat (pan, zoom, click a seal) |
| `world.html` | The world of the Banner-lands, in the archive's voice |
| `characters.html` | The Faces — the people of Book One |
| `read.html` | From the pages — the opening of Book One: an excerpt from Chapter One (*The Trial of the Goatherd*) and Chapter Two (*The Morning After*) complete |
| `history.html` | In-world history: the reckoning of years, the War of the Unification, the Tenfold Compact, a timeline of the four centuries, and the four records |
| `vote.html` | **The Moot** — live reader voting (which house would you follow; what the archive opens next) |
| `support.html` | **Follow & support** — sponsor and follow channels, driven by `data/community.js` |

The *Rawness & Mortality* development document no longer appears on the
public site (it is writing method, not story); it lives on as the gated
`Development:Rawness and Mortality` page in the MediaWiki (`wiki/`).

## Structure

- `data/houses.js` — canon data for the ten houses (name, philosophy, seat,
  region, people, one-line description, map coordinates). The map renders
  from this file; edit coordinates here to move a seat on the chart.
- `assets/map.js` — interactive map logic (pan/zoom, seals, detail card,
  `#house/<id>` deep links).
- `assets/site.js` — card expansion and the optional front-page chart plate.
- `assets/style.css` — the whole visual identity (parchment `#efe7d3`,
  ink `#3a332a`, accent `#8a7f6d`, ember `#8a4a2a`).

## House sigils

Drop each house's crest into `assets/sigils/` named by house id:

```
assets/sigils/blackthorn.png    assets/sigils/ravenshade.png
assets/sigils/ashbourne.png     assets/sigils/whitehart.png
assets/sigils/stormrider.png    assets/sigils/ironvale.png
assets/sigils/blackcrest.png    assets/sigils/stonebear.png
assets/sigils/tidebreaker.png   assets/sigils/phoenix.png
```

They appear automatically on the house cards (`houses.html`) and in the
map's record card. Missing files are hidden — no placeholder is shown.
Square images work best.

All ten sigils are in place (web-sized from the canon pack in the Aurefold
repo). The `sigill_`-prefixed originals also work as a fallback naming.

## Character portraits

Portraits live in `assets/portraits/` as web-sized copies (640&nbsp;px),
named `<name>.jpg` after the card. The Faces page (`characters.html`) now
leads with the **Book One cast** and keeps the wider Ten-house leadership
below it, per the v27 character apparatus.

**Present in the repo:** `sela`, `tomas`, `alaine`, `sabra`, `roderick`,
`garron`, `halvard`, `aldous`, `torvald`, `maren`, `signe` (`wren` is also
present but no longer placed on the page).

**Book One cast still needing a portrait** (v27 visual debt — the file
names the page already expects): `fen`, `merta`, `harl`, `perrin`, `wilda`,
`ivet`, `orla`, `nella`, `roan`, `ottar`, and `alder`. Drop a
`assets/portraits/<name>.jpg` in and the card picks it up automatically.

Cards whose file is missing simply hide the portrait slot — no placeholder
is shown, so the text-only cards render cleanly until the art lands.

## The book cover

`assets/cover_bell_of_silence.jpg` is the **front cover** of Book One, shown
in the book announcement on `index.html` and `book.html` (styled by
`.book-cover`). It was extracted from the KDP full-wrap PDF — the front panel
only, cropped clear of the spine and bleed.

The **back cover** is intentionally not on the site yet: its blurb states that
"the voice that guided Sela … only points east," which the v27.0 locks forbid
(the voice is never verified). It goes up once that copy is revised.

> **Rename note:** the cover's **EMBERWOLD** wordmark has been raster-edited to
> **AUREFOLD** as an *interim* — the original title is a bespoke engraved font
> that can't be matched pixel-for-pixel here, so the stand-in is a plain serif.
> Replace with a production cover: send a new Aurefold full-wrap (or the title
> font) and the front panel is re-rendered properly.

## The chart plate

The front page shows `assets/fanlanden_map.jpg` — a web-sized copy of the
canonical `fanlanden_map.png` (Release&nbsp;1.1, Aurefold repo) — full-width as
*"Plate I — the Banner-lands, general chart · 396 A.U."*
If the file is removed, the section hides itself.

## The Moot (reader voting)

`vote.html` is backed by a small database (Supabase project **aurefold-site**,
`akboesleczddqdikjzbw`, Stockholm region, free tier — dashboard at
https://supabase.com/dashboard/project/akboesleczddqdikjzbw). The key in
`data/community.js` is the *anon* key (a JWT with `role=anon` baked in) —
safe in a public site; the database's row-level security is what decides
permissions:

- anyone can read polls and **aggregated** results;
- anyone can cast **one vote per poll per browser** (enforced by a per-browser
  id + a primary key in the database);
- nobody can read, change, or delete individual votes from the site.

**Add a poll** (SQL editor in the dashboard):

```sql
insert into polls (id, question, description, open, sort)
values ('my-poll', 'The question?', 'Optional description.', true, 3);
insert into poll_options (poll_id, id, label, detail, sort) values
  ('my-poll', 'a', 'First option', 'Optional detail.', 1),
  ('my-poll', 'b', 'Second option', '', 2);
```

**Close a poll:** `update polls set open = false where id = 'my-poll';`
(Closed polls stop accepting votes immediately and disappear from the page.)

**Where voting works:** on the hosted site (any static HTTPS host — GitHub
Pages, Netlify, Cloudflare Pages). It does **not** work in the Claude
artifact preview (its security sandbox blocks all external requests, so the
Moot there is read-only) and may not work from a `file://` double-click
(browsers block cross-origin `fetch` from local files). Serve the folder over
http(s) and voting is live.

## Follow & support

`support.html` renders only the channels that have a URL in
`data/community.js` → `support`. Paste your Patreon / Ko-fi / Swish / PayPal /
newsletter / social links there and the buttons appear; empty strings stay
hidden and the page shows an honest "being set up" note instead. No payment
handling happens on the site itself — sponsorship runs through the platforms.

## Canon guardrails

The site presents only established canon and is written to keep it that way:

- All text is in English.
- *Ederhamn · Elvestad · Ederstad* appear exactly as written — never resolved,
  never translated.
- The phrase *"ten seals — some say eleven"* appears exactly once, on
  `index.html`, and no other reference to that count exists anywhere on the site.
- Ravenshade's patron is never named.
- Every house — including Blackcrest — is presented with equal dignity.
- Rivers are unnamed; the charts never agree.
- No characters, events, places, quotes, or lore beyond canon. When adding
  content, add facts to `data/houses.js` or the pages only from the series
  bible.
