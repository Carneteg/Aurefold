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

The `sigill_`-prefixed names from the sigil pack also work as-is
(`sigill_blackthorn.png`, `sigill_whitehart.png`, …) — the site tries the
plain name first and falls back to the `sigill_` name automatically.

## Character portraits

Drop portraits into `assets/portraits/`. The Faces page tries
`<slug>.png` first, then the raw portrait-pack filename, then hides the
slot. Mapping (from the canon image index):

| Card | Preferred name | Pack fallback |
| --- | --- | --- |
| Sela | `sela.png` | `generatedimage_5.png` |
| Brother Tomas | `tomas.png` | `generatedimage_9.png` |
| Mother Alaine | `alaine.png` | `generatedimage_10.png` |
| Wren Blackthorn | `wren.png` | `generatedimage.png` |
| Garron, the Binder | `garron.png` | `generatedimage_4.png` |
| Sabra Ravenshade | `sabra.png` | `generatedimage_1.png` |
| Maren Tidebreaker | `maren.png` | `generatedimage_8.png` |
| Kael / Vaela / Rurik / Ser Alba / Signe | `kael.png` etc. | — (no portrait in the pack yet) |

Pack portraits without a Faces card (Roderick `_2`, Halvard `_3`,
Aldous `_6`, Torvald `_7`) are not shown yet. Duplicates `_11` and `_13`
per the image index should not be uploaded.

## The chart plate

If a hand-drawn map image is added as `assets/fanlanden_map.png`, the front
page automatically shows it full-width as
*"Plate I — the Banner-lands, general chart · 396 A.U."*
Without the file, the section stays hidden.

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
