# The Emberwold Wiki (MediaWiki)

A self-hosted MediaWiki for the **Emberwold** series, modeled on the structure and
feel of *A Wiki of Ice and Fire* — with an ember/glow theme instead of the beige.
Everything in `content/` was converted from the project's canon (Lore Bible v26.5,
the prologue, the approved scenes) and is written **spoiler-safe for a public,
fanbase-facing wiki**: the historian's voice, open riddles kept open, no hidden
models, no character secrets.

## 1. Getting started (local)

Requirements: Docker + Docker Compose.

```bash
cd wiki
docker compose up -d          # starts MediaWiki (port 8080) + MariaDB
```

1. Open **http://localhost:8080** and run the MediaWiki install wizard:
   - Database host: `database` · name: `emberwold_wiki` · user: `wikiuser`
     · password: the one in `docker-compose.yml` (change it!).
   - Site name: **Emberwold**. Create your admin account (e.g. `Admin`).
2. The wizard offers `LocalSettings.php` for download — **save it into `wiki/config/`**.
3. Append this line at the very end of that `config/LocalSettings.php`:
   ```php
   require_once "$IP/LocalSettings.emberwold.php";
   ```
4. In `docker-compose.yml`, **uncomment the four volume lines** (LocalSettings ×2, the logo, and the vendored TemplateStyles extension), then:
   ```bash
   docker compose up -d --force-recreate mediawiki
   ```
5. Import all content (pages, templates, theme, images):
   ```bash
   ./import.sh Admin        # your admin username
   ```
6. Open http://localhost:8080 and hard-refresh (Ctrl+Shift+R). Done.

> Verified end-to-end: this exact flow was run against `mediawiki:lts` (1.43) —
> the import script promotes your admin to `interface-admin` (needed for
> `MediaWiki:Common.css`) and restarts the app container afterward, because the
> default APCu cache otherwise serves the pre-import (empty) site styles.
> **TemplateStyles** is not bundled in the Docker image; a vendored copy
> (REL1_43, with its composer dependencies) ships in `extensions-extra/`.

## 2. What's configured

`config/LocalSettings.emberwold.php` enables (all bundled with MediaWiki — nothing
to download): **ParserFunctions**, **Scribunto** (Lua), **TemplateStyles**,
**CategoryTree**, **Cite**, **VisualEditor**, WikiEditor/CodeEditor, ImageMap,
InputBox, Interwiki. Uploads are on; anonymous editing is off (public fan wiki:
everyone reads, registered users edit).

Skin: **Vector 2022** with the ember theme in `MediaWiki:Common.css`
(sooty ground `#191210`, parchment reading surface, glowing ember accents
`#e2571e`/`#ffb347`, serif headings). If you later want a dark skin baseline,
[Citizen](https://www.mediawiki.org/wiki/Skin:Citizen) is the best fit — install
it into `extensions/../skins` and the same palette carries over.

## 3. What's imported

| Kind | Pages |
| --- | --- |
| Main Page | Two-column AWOIAF-style layout: Featured article, Featured quotes, Did you know, References · portal grid, About, Contributing |
| Templates | `Box` (rounded heading tab), `Quote`, `Infobox character/place/faction/creature/artifact`, `Placeholder`, `Gate`, `Tl` — each with TemplateStyles |
| Portals | Houses, Characters, Places, History, Culture, Mystery |
| Articles | ~90: the 10 Great Houses, ~38 characters, 10 seats, 7 regions, world & geography, the war/oath/timeline/jubilee, the four sources, customs, the books |
| Development | `Development:Rawness and Mortality` — gate material, hard-bannered non-canon ({{Gate}}) |
| Images | The 11 canon portraits + Plate I (web-sized) |

Canon guardrails are encoded in `Help:Style guide`: open riddles stay open, the
elevens are frozen, hidden models are never named, development material is never
cited as canon.

## 4. Deploying later

- Point a reverse proxy (Caddy/nginx/Traefik) at port 8080 with TLS.
- Set `$wgServer = "https://your-domain"` in `config/LocalSettings.php`.
- For pretty URLs (`/wiki/Page`), enable the `$wgArticlePath` lines in
  `LocalSettings.emberwold.php` and add the usual alias rule in your proxy.
- Back up: the `wiki_db` and `wiki_images` volumes + the `config/` folder.

## 5. Everyday editing

See **Help:Style guide** on the wiki itself. Short version: new article → red
link → pick the right infobox → link generously → end with categories. Filler
text must carry `{{Placeholder}}`; gate material must carry `{{Gate}}` and live
in `Category:Development`.

## Known gaps (deliberate)

|image=Sigill whitehart.png` to each house infobox.
- The logo (`config/emberwold_logo.png`) is a generated placeholder.
- `Development:` is a plain page prefix, not a real namespace; if the section
  grows, register a proper namespace in `LocalSettings.emberwold.php`.
