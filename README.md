# EMBERWOLD — promotional site

Static promotional website for the fantasy series **EMBERWOLD**
(Book One: *The Bell of Silence*). Plain HTML/CSS/JS — no frameworks,
no build step, no external assets. Open `index.html` in a browser, or serve
the folder with any static file server (works as-is on GitHub Pages).

## Pages

| Page | Contents |
| --- | --- |
| `index.html` | Hero, series pitch, Book One announcement, the name, optional chart plate |
| `book.html` | Book One: *The Bell of Silence* — where it begins, the shape of the book |
| `houses.html` | The Ten Great Houses — expandable cards |
| `map.html` | Interactive chart of the Banner-lands with every house seat (pan, zoom, click a seal) |
| `world.html` | The world of the Banner-lands, in the archive's voice |
| `characters.html` | The Faces — the people of Book One |
| `history.html` | Development record: *Rawness & Mortality* (gate material — not canon; contains spoilers and eleven-references, so it sits outside the public pages' canon guardrails) |

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

All ten sigils are in place (web-sized from the canon pack in the Emberworld
repo). The `sigill_`-prefixed originals also work as a fallback naming.

## Character portraits

Portraits live in `assets/portraits/` as web-sized copies (640&nbsp;px) of
the canon portraits in the Emberworld repo. Since **Release&nbsp;1.1** the
canonical source names are `portrait_<house>_<name>.png`:

| Card | Site file | Canonical source (Emberworld repo) |
| --- | --- | --- |
| Sela | `sela.jpg` | `portrait_whitehart_sela.png` |
| Brother Tomas | `tomas.jpg` | `portrait_whitehart_tomas.png` |
| Mother Alaine | `alaine.jpg` | `portrait_whitehart_alaine.png` |
| Wren Blackthorn | `wren.jpg` | `portrait_blackthorn_wren.png` |
| Garron, the Binder | `garron.jpg` | `portrait_stormrider_garron.png` |
| Sabra Ravenshade | `sabra.jpg` | `portrait_ravenshade_sabra.png` |
| Maren Tidebreaker | `maren.jpg` | `portrait_tidebreaker_maren.png` |
| Roderick Ashbourne | `roderick.jpg` | `portrait_ashbourne_roderick.png` |
| Master Halvard | `halvard.jpg` | `portrait_ironvale_halvard.png` |
| Aldous Blackcrest | `aldous.jpg` | `portrait_blackcrest_aldous.png` |
| Reverend Torvald | `torvald.jpg` | `portrait_stonebear_torvald.png` |
| Signe Phoenix | `signe.png` — pending | `portrait_phoenix_signe.png` — in the release manifest, not yet uploaded |
| Kael / Vaela / Rurik / Ser Alba | — | no portrait in the release yet |

Cards whose file is missing simply hide the portrait slot — no placeholder
is shown. When Signe's release portrait lands, save a 640&nbsp;px copy as
`assets/portraits/signe.png` and her card picks it up automatically.

## The chart plate

The front page shows `assets/fanlanden_map.jpg` — a web-sized copy of the
canonical `fanlanden_map.png` (Release&nbsp;1.1, Emberworld repo) — full-width as
*"Plate I — the Banner-lands, general chart · 396 A.U."*
If the file is removed, the section hides itself.

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
