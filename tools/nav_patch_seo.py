#!/usr/bin/env python3
"""One-shot nav patch for kimi/seo-pages-2026-08-17 (run by CI bootstrap).

Inserts the two new Archive-submenu links (For readers of / Reading order)
into every English root page that does not have them yet. Idempotent.
Deleted by the bootstrap workflow after it runs.
"""
import glob

INS = ('          <li><a href="for-readers-of.html">For readers of</a></li>\n'
       '          <li><a href="reading-order.html">Reading order</a></li>\n')
INS_ABS = INS.replace('href="', 'href="/')

TARGETS = [
    ('          <li><a href="archive.html">The Living Archive</a></li>\n', INS),
    ('          <li><a href="archive.html" class="active">The Living Archive</a></li>\n', INS),
    ('          <li><a href="/archive.html">The Living Archive</a></li>\n', INS_ABS),
]

def main():
    for f in sorted(glob.glob('*.html')):
        s = open(f, encoding='utf-8').read()
        if 'for-readers-of.html' in s:
            continue
        for old, add in TARGETS:
            if old in s:
                assert s.count(old) == 1, f
                open(f, 'w', encoding='utf-8').write(s.replace(old, old + add))
                print('nav patched:', f)
                break
        else:
            raise SystemExit('no nav anchor found in ' + f)

if __name__ == '__main__':
    main()
