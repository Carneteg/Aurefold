#!/usr/bin/env python3
"""
Aurefold i18n generator (progressive localization).

English pages at the repo root are the source of truth. For each built language
this produces fully-translated copies under /<lang>/ ONLY for pages that have a
translation file (i18n/<lang>/<page>.json). Anything not yet translated is not
generated, and links/switchers/hreflang fall back to English — so a partially
translated language never 404s and never mixes languages on one page.

Translation file format (i18n/<lang>/<page>.json):
    { "title": "...", "description": "...", "blocks": [["EN exact","translated"], ...] }
Blocks are literal, ordered (longest-first) replacements of exact, unique English
substrings. Proper nouns (book titles, the ten House names, character names) are
intentionally NOT translated.

Run from repo root:  python3 tools/i18n_build.py
"""

import json, os, re, glob
from html import escape as html_escape
from urllib.parse import quote as urlquote

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
I18N = os.path.join(ROOT, "i18n")
BASE = "https://aurefold.com"

LANGS = {"en": "English", "sv": "Svenska", "es": "Español",
         "fr": "Français", "zh": "中文", "ja": "日本語"}
BUILT = ["en", "sv", "es", "fr", "zh", "ja"]   # languages offered in the switcher

CHROME = {
  "en": {"Book One":"Book One","Read":"Read","The Archive":"The Archive",
         "The Great Houses":"The Great Houses","The Map":"The Map","The World":"The World",
         "The Faces":"The Faces","History":"History","The Living Archive":"The Living Archive","The Banner":"The Banner",
         "The Moot":"The Moot","Support":"Support","Journal":"Journal",
         "Skip to content":"Skip to content","Open menu":"Open menu",
         "Privacy &amp; cookies":"Privacy &amp; cookies","Cookie settings":"Cookie settings",
         "AUREFOLD · The map ends where the truth begins.":"AUREFOLD · The map ends where the truth begins.",
         "Follow Aurefold":"Follow Aurefold","Language":"Language"},
  "sv": {"Book One":"Bok Ett","Read":"Läs","The Archive":"Arkivet",
         "The Great Houses":"De stora husen","The Map":"Kartan","The World":"Världen",
         "The Faces":"Ansiktena","History":"Historia","The Living Archive":"Det levande arkivet","The Banner":"Baneret",
         "The Moot":"Tinget","Support":"Stöd","Journal":"Journal",
         "Skip to content":"Hoppa till innehåll","Open menu":"Öppna meny",
         "Privacy &amp; cookies":"Integritet &amp; cookies","Cookie settings":"Cookie-inställningar",
         "AUREFOLD · The map ends where the truth begins.":"AUREFOLD · Kartan slutar där sanningen börjar.",
         "Follow Aurefold":"Följ Aurefold","Language":"Språk"},
  "es": {"Book One":"Libro Uno","Read":"Leer","The Archive":"El Archivo",
         "The Great Houses":"Las Grandes Casas","The Map":"El Mapa","The World":"El Mundo",
         "The Faces":"Los Rostros","History":"Historia","The Living Archive":"El Archivo Viviente","The Banner":"El Estandarte",
         "The Moot":"El Cónclave","Support":"Apoyar","Journal":"Diario",
         "Skip to content":"Saltar al contenido","Open menu":"Abrir menú",
         "Privacy &amp; cookies":"Privacidad y cookies","Cookie settings":"Ajustes de cookies",
         "AUREFOLD · The map ends where the truth begins.":"AUREFOLD · El mapa termina donde empieza la verdad.",
         "Follow Aurefold":"Sigue a Aurefold","Language":"Idioma"},
  "fr": {"Book One":"Livre Un","Read":"Lire","The Archive":"Les Archives",
         "The Great Houses":"Les Grandes Maisons","The Map":"La Carte","The World":"Le Monde",
         "The Faces":"Les Visages","History":"Histoire","The Living Archive":"Les Archives Vivantes","The Banner":"La Bannière",
         "The Moot":"Le Conseil","Support":"Soutenir","Journal":"Journal",
         "Skip to content":"Aller au contenu","Open menu":"Ouvrir le menu",
         "Privacy &amp; cookies":"Confidentialité et cookies","Cookie settings":"Réglages des cookies",
         "AUREFOLD · The map ends where the truth begins.":"AUREFOLD · La carte s’arrête où commence la vérité.",
         "Follow Aurefold":"Suivre Aurefold","Language":"Langue"},
  "zh": {"Book One":"第一部","Read":"阅读","The Archive":"档案",
         "The Great Houses":"十大家族","The Map":"地图","The World":"世界",
         "The Faces":"人物","History":"历史","The Living Archive":"活档案","The Banner":"旗帜",
         "The Moot":"议会","Support":"支持","Journal":"日志",
         "Skip to content":"跳到内容","Open menu":"打开菜单",
         "Privacy &amp; cookies":"隐私与 Cookie","Cookie settings":"Cookie 设置",
         "AUREFOLD · The map ends where the truth begins.":"AUREFOLD · 地图止于真相开始之处。",
         "Follow Aurefold":"关注 Aurefold","Language":"语言"},
  "ja": {"Book One":"第一巻","Read":"読む","The Archive":"アーカイブ",
         "The Great Houses":"十大家門","The Map":"地図","The World":"世界",
         "The Faces":"登場人物","History":"歴史","The Living Archive":"生きた記録","The Banner":"旗印",
         "The Moot":"合議","Support":"支援","Journal":"ジャーナル",
         "Skip to content":"本文へスキップ","Open menu":"メニューを開く",
         "Privacy &amp; cookies":"プライバシーと Cookie","Cookie settings":"Cookie 設定",
         "AUREFOLD · The map ends where the truth begins.":"AUREFOLD · 地図は真実の始まるところで終わる。",
         "Follow Aurefold":"Aurefold をフォロー","Language":"言語"},
}

def source_pages():
    return [os.path.basename(p) for p in sorted(glob.glob(os.path.join(ROOT, "*.html")))]

def translated_set(lang):
    d = os.path.join(I18N, lang)
    if not os.path.isdir(d):
        return set()
    return {f[:-5] for f in os.listdir(d) if f.endswith(".json")}  # strip ".json" -> "page.html"

TRANSLATED = {lang: translated_set(lang) for lang in BUILT if lang != "en"}

def has_tr(lang, page):
    return lang == "en" or page in TRANSLATED.get(lang, set())

def page_url(lang, page):
    """Root-absolute path; falls back to English if page isn't translated in lang."""
    if not has_tr(lang, page):
        lang = "en"
    if lang == "en":
        return "/" if page == "index.html" else "/" + page
    base = "/" + lang + "/"
    return base if page == "index.html" else base + page

def abs_url(lang, page):
    return BASE + page_url(lang, page)

def langs_for(page):
    return [l for l in BUILT if has_tr(l, page)]

def switcher_html(current_lang, page):
    items = []
    for lang in langs_for(page):
        cls = ' class="active"' if lang == current_lang else ""
        items.append('<li><a href="%s" hreflang="%s" lang="%s"%s>%s</a></li>'
                     % (page_url(lang, page), lang, lang, cls, LANGS[lang]))
    label = CHROME.get(current_lang, CHROME["en"]).get("Language", "Language")
    return ('<li class="has-sub lang-switch">'
            '<button type="button" class="nav-sub-toggle" aria-haspopup="true" '
            'aria-expanded="false" aria-controls="lang-submenu" aria-label="%s">%s</button>'
            '<ul class="sub-menu" id="lang-submenu">%s</ul></li>'
            % (label, LANGS[current_lang], "".join(items)))

def hreflang_block(page):
    out = []
    for lang in langs_for(page):
        out.append('  <link rel="alternate" hreflang="%s" href="%s" />' % (lang, abs_url(lang, page)))
    out.append('  <link rel="alternate" hreflang="x-default" href="%s" />' % abs_url("en", page))
    return "\n".join(out)

MARK_S, MARK_E = "<!-- i18n:switcher -->", "<!-- /i18n:switcher -->"
HL_S, HL_E = "<!-- i18n:hreflang -->", "<!-- /i18n:hreflang -->"

def strip_marked(s, a, b):
    # Remove the marked block along with any immediately-preceding
    # whitespace-only lines and inline indentation, so repeated generator
    # runs stay byte-for-byte idempotent (no accumulating blank lines).
    return re.sub(r'(?:[ \t]*\n)*[ \t]*' + re.escape(a) + r".*?" + re.escape(b), "", s, flags=re.S)

def inject_common(html, lang, page):
    html = strip_marked(html, MARK_S, MARK_E)
    html = strip_marked(html, HL_S, HL_E)
    sw = MARK_S + switcher_html(lang, page) + MARK_E
    # insert the switcher <li> just before the #nav-menu closing </ul> (the one
    # immediately before </nav>), never the nested archive/lang sub-menus.
    html = re.sub(r'</ul>\s*</nav>', lambda m: "      " + sw + "\n    " + m.group(0), html, count=1)
    hl = HL_S + "\n" + hreflang_block(page) + "\n  " + HL_E
    html = html.replace("</head>", hl + "\n</head>", 1)
    return html

def localize_chrome(html, lang):
    for en, tr in CHROME.get(lang, {}).items():
        if en == tr:
            continue
        html = html.replace(">" + en + "<", ">" + tr + "<")
        html = html.replace('aria-label="' + en + '"', 'aria-label="' + tr + '"')
        html = html.replace('>' + en + '</button>', '>' + tr + '</button>')
        html = html.replace('>' + en + '</a>', '>' + tr + '</a>')
        html = html.replace("    " + en + "\n", "    " + tr + "\n")
    return html

LINK_RE = re.compile(r'(href|src)="(?!https?:|//|#|mailto:|/)([^"]+)"')
SRCSET_RE = re.compile(r'(srcset)="([^"]+)"')

def _rewrite_target(val, lang):
    """Root-absolute rewrite for a single relative URL (same rules as href/src)."""
    if val.startswith(("https:", "http:", "//", "#", "mailto:", "/")):
        return val
    if val.startswith("assets/") or val.startswith("data/"):
        return "/" + val
    mm = re.match(r'^([A-Za-z0-9_./-]+\.html)(#.*)?$', val)
    if mm:
        return page_url(lang, mm.group(1)) + (mm.group(2) or "")
    return val

def rewrite_paths(html, lang):
    def repl(m):
        attr, val = m.group(1), m.group(2)
        return '%s="%s"' % (attr, _rewrite_target(val, lang))
    html = LINK_RE.sub(repl, html)
    # srcset needs its own pass: the value is a comma-separated list of
    # "<url> [descriptor]" candidates, each rewritten independently.
    def srcset_repl(m):
        out = []
        for cand in m.group(2).split(","):
            cand = cand.strip()
            if not cand:
                continue
            bits = cand.split(None, 1)
            url = _rewrite_target(bits[0], lang)
            out.append(url + (" " + bits[1] if len(bits) > 1 else ""))
        return '%s="%s"' % (m.group(1), ", ".join(out))
    return SRCSET_RE.sub(srcset_repl, html)

# Share texts for the static house pages — copied VERBATIM from the approved
# shareText functions in assets/quiz.js (en:93, sv:158, es:223, fr:288,
# zh:353, ja:418). If those change, change these too.
SHARE_TEXTS = {
    "en": "I'm House {short} in Aurefold — which house are you?",
    "sv": "Jag skulle följa House {short} i Aurefold — vilket hus skulle du följa?",
    "es": "Seguiría a House {short} en Aurefold — ¿a qué casa seguirías tú?",
    "fr": "Je suivrais House {short} dans Aurefold — quelle maison suivriez-vous ?",
    "zh": "在 Aurefold 中我会追随 House {short}——你会追随哪个家族？",
    "ja": "Aurefold で私は House {short} に従う——あなたはどの家に従う？",
}

def localize_share_block(html, lang, page):
    """Rebuild the share-block attributes on house-* pages so a share from
    /sv/ carries Swedish text and the /sv/ URL. apply_blocks can't do this:
    the values are percent-encoded, so no block key would ever match."""
    m = re.match(r'house-([a-z]+)\.html$', page)
    if not m or lang == "en":
        return html
    short = m.group(1).capitalize()
    text = SHARE_TEXTS.get(lang, SHARE_TEXTS["en"]).format(short=short)
    url = abs_url(lang, page)
    t_enc, u_enc = urlquote(text, safe=""), urlquote(url, safe=":/")
    html = re.sub(r'https://twitter\.com/intent/tweet\?text=[^"]*',
                  "https://twitter.com/intent/tweet?text=%s&url=%s" % (t_enc, u_enc), html)
    html = re.sub(r'https://www\.facebook\.com/sharer/sharer\.php\?u=[^"]*',
                  "https://www.facebook.com/sharer/sharer.php?u=" + u_enc, html)
    html = re.sub(r'https://www\.reddit\.com/submit\?url=[^"]*',
                  "https://www.reddit.com/submit?url=%s&title=%s" % (u_enc, t_enc), html)
    html = re.sub(r'data-copy="[^"]*"', lambda _: 'data-copy="%s"' % html_escape(text + " " + url, quote=True), html)
    return html

def apply_blocks(html, data):
    for en, tr in sorted(data.get("blocks", []), key=lambda p: -len(p[0])):
        if en not in html:
            print("    [warn] block not found: %r" % en[:70]); continue
        html = html.replace(en, tr)
    if data.get("title"):
        t = data["title"]
        html = re.sub(r"<title>.*?</title>", "<title>" + t + "</title>", html, count=1, flags=re.S)
        html = re.sub(r'(<meta property="og:title" content=").*?(")', r"\g<1>" + t + r"\g<2>", html, count=1, flags=re.S)
        html = re.sub(r'(<meta name="twitter:title" content=").*?(")', r"\g<1>" + t + r"\g<2>", html, count=1, flags=re.S)
    if data.get("description"):
        d = data["description"]
        html = re.sub(r'(<meta name="description" content=").*?(" ?/?>)', r"\g<1>" + d + r"\g<2>", html, count=1, flags=re.S)
        html = re.sub(r'(<meta property="og:description" content=").*?(")', r"\g<1>" + d + r"\g<2>", html, count=1, flags=re.S)
        html = re.sub(r'(<meta name="twitter:description" content=").*?(")', r"\g<1>" + d + r"\g<2>", html, count=1, flags=re.S)
    return html

def localize_page(page, lang):
    html = open(os.path.join(ROOT, page), encoding="utf-8").read()
    if lang != "en":
        html = html.replace('<html lang="en">', '<html lang="%s">' % lang, 1)
        html = re.sub(r'(<link rel="canonical" href=")[^"]*(")', r"\g<1>" + abs_url(lang, page) + r"\g<2>", html, count=1)
        html = re.sub(r'(<meta property="og:url" content=")[^"]*(")', r"\g<1>" + abs_url(lang, page) + r"\g<2>", html, count=1)
        html = html.replace('"inLanguage": "en"', '"inLanguage": "%s"' % lang)
        # translate content BEFORE rewriting paths, so block keys (which may
        # contain internal hrefs) still match the original English.
        dpath = os.path.join(I18N, lang, page + ".json")
        if os.path.exists(dpath):
            html = apply_blocks(html, json.load(open(dpath, encoding="utf-8")))
        html = localize_share_block(html, lang, page)
        html = localize_chrome(html, lang)
        html = rewrite_paths(html, lang)   # last: fixes hrefs in original + translated text
    html = inject_common(html, lang, page)
    return html

def main():
    pages = source_pages()
    for page in pages:
        out = localize_page(page, "en")          # read+process BEFORE opening for write
        open(os.path.join(ROOT, page), "w", encoding="utf-8").write(out)
    print("English: switcher + hreflang refreshed on %d pages" % len(pages))
    for lang in BUILT:
        if lang == "en":
            continue
        outdir = os.path.join(ROOT, lang)
        os.makedirs(outdir, exist_ok=True)
        n = 0
        for page in sorted(TRANSLATED.get(lang, set())):
            open(os.path.join(outdir, page), "w", encoding="utf-8").write(localize_page(page, lang))
            n += 1
        print("%s: generated %d translated page(s) -> /%s/" % (lang, n, lang))

if __name__ == "__main__":
    main()
