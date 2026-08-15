#!/usr/bin/env python3
"""Generate sitemap.xml from the English root pages plus every translated
/<lang>/ copy, emitting hreflang alternates for each localized page.

Run from repo root:  python3 tools/gen_sitemap.py
"""
import os, glob, datetime

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BASE = "https://aurefold.com"
BUILT = ["sv"]  # translated language subdirs to include
LASTMOD = datetime.date.today().isoformat()

# pages we don't want in the index
SKIP = {"404.html"}

PRIORITY = {
    "index.html": "1.0", "book.html": "0.9", "read.html": "0.9",
    "support.html": "0.8", "vote.html": "0.7", "houses.html": "0.7",
    "map.html": "0.7", "world.html": "0.7", "characters.html": "0.7",
    "history.html": "0.7", "archive.html": "0.7", "quiz.html": "0.7",
    "journal.html": "0.7", "privacy.html": "0.5",
}

def loc(lang, page):
    if lang == "en":
        return BASE + ("/" if page == "index.html" else "/" + page)
    base = BASE + "/" + lang + "/"
    return base if page == "index.html" else base + page

def langs_for(page):
    out = ["en"]
    for l in BUILT:
        if os.path.exists(os.path.join(ROOT, l, page)):
            out.append(l)
    return out

def main():
    pages = sorted(os.path.basename(p) for p in glob.glob(os.path.join(ROOT, "*.html")))
    pages = [p for p in pages if p not in SKIP]
    lines = ['<?xml version="1.0" encoding="UTF-8"?>',
             '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"',
             '        xmlns:xhtml="http://www.w3.org/1999/xhtml">']
    for page in pages:
        alts = langs_for(page)
        prio = PRIORITY.get(page, "0.6")
        for lang in alts:
            lines.append("  <url>")
            lines.append("    <loc>%s</loc>" % loc(lang, page))
            lines.append("    <lastmod>%s</lastmod>" % LASTMOD)
            if len(alts) > 1:
                for a in alts:
                    lines.append('    <xhtml:link rel="alternate" hreflang="%s" href="%s" />' % (a, loc(a, page)))
                lines.append('    <xhtml:link rel="alternate" hreflang="x-default" href="%s" />' % loc("en", page))
            lines.append("    <priority>%s</priority>" % prio)
            lines.append("  </url>")
    lines.append("</urlset>")
    open(os.path.join(ROOT, "sitemap.xml"), "w", encoding="utf-8").write("\n".join(lines) + "\n")
    n_url = sum(1 for l in lines if l.strip() == "<url>")
    print("sitemap.xml: %d urls" % n_url)

if __name__ == "__main__":
    main()
