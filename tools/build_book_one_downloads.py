#!/usr/bin/env python3
"""Build reader-facing PDF + EPUB from the governing Book One Markdown master.

The script intentionally uses the Markdown master as the only prose source. It is
small enough to audit, deterministic apart from ZIP/PDF metadata timestamps, and
performs textual validation after generation.
"""
from __future__ import annotations

import argparse
import hashlib
import html
import json
import re
import sys
import zipfile
from pathlib import Path

TITLE = "The Bell of Silence"
AUTHOR = "Tobias Carneteg"
BOOK_ID = "aurefold-book-one-the-bell-of-silence"
OLD_WEEKDAY = "Jeren Tesk was sentenced on Thursday."
NEW_SENTENCE = "Jeren Tesk was sentenced."


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def inline_markup(text: str) -> str:
    text = html.escape(text, quote=False)
    text = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", text)
    text = re.sub(r"(?<!\*)\*([^*]+?)\*(?!\*)", r"<em>\1</em>", text)
    text = re.sub(r"`([^`]+?)`", r"<code>\1</code>", text)
    return text


def split_sections(markdown_text: str):
    lines = markdown_text.splitlines()
    sections = []
    current_title = "Front Matter"
    current = []
    for line in lines:
        if re.match(r"^## (Chapter\b|Interlude\b)", line, flags=re.I):
            if current:
                sections.append((current_title, current))
            current_title = line[3:].strip()
            current = [line]
        else:
            current.append(line)
    if current:
        sections.append((current_title, current))
    return sections


def lines_to_html(lines):
    out = []
    para = []

    def flush():
        nonlocal para
        if para:
            joined = " ".join(x.strip() for x in para).strip()
            if joined:
                out.append(f"<p>{inline_markup(joined)}</p>")
            para = []

    for line in lines:
        stripped = line.strip()
        if not stripped:
            flush()
            continue
        if stripped == "---":
            flush()
            out.append("<hr />")
            continue
        m = re.match(r"^(#{1,6})\s+(.+)$", stripped)
        if m:
            flush()
            level = min(len(m.group(1)), 6)
            out.append(f"<h{level}>{inline_markup(m.group(2))}</h{level}>")
            continue
        if stripped.startswith("> "):
            flush()
            out.append(f"<blockquote>{inline_markup(stripped[2:])}</blockquote>")
            continue
        para.append(stripped)
    flush()
    return "\n".join(out)


def build_epub(master: Path, cover: Path | None, output: Path):
    text = master.read_text(encoding="utf-8")
    sections = split_sections(text)
    output.parent.mkdir(parents=True, exist_ok=True)

    xhtml_entries = []
    nav_links = []
    manifest_items = []
    spine_items = []
    for idx, (section_title, lines) in enumerate(sections):
        name = f"section-{idx:02d}.xhtml"
        body = lines_to_html(lines)
        doc = f'''<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head><meta charset="utf-8"/><title>{html.escape(section_title)}</title><link rel="stylesheet" href="styles.css" type="text/css"/></head>
<body>{body}</body></html>'''
        xhtml_entries.append((name, doc))
        nav_links.append(f'<li><a href="{name}">{html.escape(section_title)}</a></li>')
        manifest_items.append(f'<item id="s{idx}" href="{name}" media-type="application/xhtml+xml"/>')
        spine_items.append(f'<itemref idref="s{idx}"/>')

    cover_item = ""
    cover_meta = ""
    cover_write = None
    if cover and cover.exists():
        ext = cover.suffix.lower().lstrip(".") or "jpg"
        media = "image/jpeg" if ext in {"jpg", "jpeg"} else "image/png"
        cover_name = f"cover.{ext}"
        cover_item = f'<item id="cover-image" href="{cover_name}" media-type="{media}" properties="cover-image"/>'
        cover_meta = '<meta name="cover" content="cover-image"/>'
        cover_write = (cover_name, cover.read_bytes())

    container_xml = '''<?xml version="1.0"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
<rootfiles><rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/></rootfiles>
</container>'''
    nav = f'''<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html><html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" lang="en">
<head><meta charset="utf-8"/><title>Contents</title></head><body><nav epub:type="toc" id="toc"><h1>Contents</h1><ol>{''.join(nav_links)}</ol></nav></body></html>'''
    opf = f'''<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://www.idpf.org/2007/opf" unique-identifier="bookid" version="3.0">
<metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
<dc:identifier id="bookid">{BOOK_ID}</dc:identifier><dc:title>{TITLE}</dc:title><dc:creator>{AUTHOR}</dc:creator><dc:language>en</dc:language>{cover_meta}
</metadata><manifest><item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/><item id="css" href="styles.css" media-type="text/css"/>{cover_item}{''.join(manifest_items)}</manifest><spine>{''.join(spine_items)}</spine></package>'''
    css = '''body{font-family:serif;line-height:1.5;margin:5%;}h1,h2,h3{text-align:center;margin-top:2em;}p{text-indent:1.2em;margin:.2em 0;}blockquote{margin:1em 2em;font-style:italic;}hr{border:0;border-top:1px solid #999;margin:2em 30%;}'''

    with zipfile.ZipFile(output, "w") as z:
        z.writestr("mimetype", "application/epub+zip", compress_type=zipfile.ZIP_STORED)
        z.writestr("META-INF/container.xml", container_xml)
        z.writestr("OEBPS/content.opf", opf)
        z.writestr("OEBPS/nav.xhtml", nav)
        z.writestr("OEBPS/styles.css", css)
        if cover_write:
            z.writestr(f"OEBPS/{cover_write[0]}", cover_write[1])
        for name, doc in xhtml_entries:
            z.writestr(f"OEBPS/{name}", doc)


def reportlab_markup(text: str) -> str:
    text = html.escape(text, quote=False)
    text = re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", text)
    text = re.sub(r"(?<!\*)\*([^*]+?)\*(?!\*)", r"<i>\1</i>", text)
    text = re.sub(r"`([^`]+?)`", r"<font name='Courier'>\1</font>", text)
    return text


def build_pdf(master: Path, cover: Path | None, output: Path):
    from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY
    from reportlab.lib.pagesizes import inch
    from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
    from reportlab.lib.units import inch as unit_inch
    from reportlab.platypus import Image, PageBreak, Paragraph, SimpleDocTemplate, Spacer

    text = master.read_text(encoding="utf-8")
    lines = text.splitlines()
    output.parent.mkdir(parents=True, exist_ok=True)
    pagesize = (6 * inch, 9 * inch)
    doc = SimpleDocTemplate(str(output), pagesize=pagesize, rightMargin=.68*unit_inch, leftMargin=.68*unit_inch, topMargin=.72*unit_inch, bottomMargin=.72*unit_inch, title=TITLE, author=AUTHOR)
    styles = getSampleStyleSheet()
    body = ParagraphStyle("BookBody", parent=styles["BodyText"], fontName="Times-Roman", fontSize=10.5, leading=14.2, alignment=TA_JUSTIFY, spaceAfter=7)
    chapter = ParagraphStyle("Chapter", parent=styles["Heading1"], fontName="Times-Bold", fontSize=18, leading=22, alignment=TA_CENTER, spaceBefore=28, spaceAfter=16)
    subtitle = ParagraphStyle("Subtitle", parent=styles["Heading2"], fontName="Times-Italic", fontSize=13, leading=16, alignment=TA_CENTER, spaceAfter=18)
    title_style = ParagraphStyle("Title", parent=styles["Title"], fontName="Times-Bold", fontSize=25, leading=30, alignment=TA_CENTER, spaceAfter=18)
    status_style = ParagraphStyle("Status", parent=body, fontSize=8.5, leading=11, alignment=TA_CENTER)

    story = []
    if cover and cover.exists():
        img = Image(str(cover))
        maxw, maxh = 4.7*unit_inch, 7.45*unit_inch
        scale = min(maxw / img.imageWidth, maxh / img.imageHeight)
        img.drawWidth = img.imageWidth * scale
        img.drawHeight = img.imageHeight * scale
        story.extend([Spacer(1, .15*unit_inch), img, PageBreak()])
    story.extend([
        Spacer(1, 1.4*unit_inch), Paragraph(TITLE.upper(), title_style),
        Paragraph("Book One of Aurefold", subtitle), Spacer(1, .5*unit_inch),
        Paragraph(AUTHOR, subtitle), PageBreak()
    ])

    para = []
    started_chapters = False

    def flush_para():
        nonlocal para
        if para:
            value = " ".join(x.strip() for x in para).strip()
            if value:
                story.append(Paragraph(reportlab_markup(value), body))
            para = []

    for raw in lines:
        s = raw.strip()
        if not s:
            flush_para()
            continue
        if s == "---":
            flush_para(); story.append(Spacer(1, 10)); continue
        if re.match(r"^## (Chapter\b|Interlude\b)", s, flags=re.I):
            flush_para()
            if started_chapters:
                story.append(PageBreak())
            started_chapters = True
            story.append(Paragraph(reportlab_markup(s[3:]), chapter))
            continue
        if s.startswith("### "):
            flush_para(); story.append(Paragraph(reportlab_markup(s[4:]), subtitle)); continue
        if s.startswith("# "):
            flush_para()
            if not started_chapters:
                story.append(Paragraph(reportlab_markup(s[2:]), title_style))
            continue
        if s.startswith("## "):
            flush_para(); story.append(Paragraph(reportlab_markup(s[3:]), subtitle)); continue
        if s.startswith("> "):
            flush_para(); story.append(Paragraph(reportlab_markup(s[2:]), status_style)); continue
        para.append(s)
    flush_para()

    def footer(canvas, _doc):
        canvas.saveState()
        canvas.setFont("Times-Roman", 8)
        canvas.drawCentredString(3*unit_inch, .35*unit_inch, str(canvas.getPageNumber()))
        canvas.restoreState()

    doc.build(story, onFirstPage=footer, onLaterPages=footer)


def validate(master: Path, pdf: Path, epub: Path):
    source = master.read_text(encoding="utf-8")
    errors = []
    if OLD_WEEKDAY in source:
        errors.append("source still contains forbidden weekday sentence")
    if source.count(NEW_SENTENCE) != 1:
        errors.append(f"source expected one corrected sentence, found {source.count(NEW_SENTENCE)}")
    chapters = len(re.findall(r"^## Chapter\b", source, flags=re.M))
    if chapters != 47:
        errors.append(f"expected 47 chapter headings, found {chapters}")
    if not re.search(r"^## Interlude\b|^### .*margin", source, flags=re.M|re.I):
        # Some source versions encode the interlude with a subtitle rather than a literal ## Interlude.
        errors.append("interlude marker not detected")

    epub_text = ""
    with zipfile.ZipFile(epub, "r") as z:
        for n in z.namelist():
            if n.endswith(".xhtml"):
                epub_text += z.read(n).decode("utf-8", errors="ignore") + "\n"
    if OLD_WEEKDAY in epub_text or NEW_SENTENCE not in html.unescape(re.sub(r"<[^>]+>", " ", epub_text)):
        errors.append("EPUB corrected sentence validation failed")

    try:
        from pypdf import PdfReader
        pdf_text = "\n".join((p.extract_text() or "") for p in PdfReader(str(pdf)).pages)
        if OLD_WEEKDAY in pdf_text or NEW_SENTENCE not in pdf_text:
            errors.append("PDF corrected sentence validation failed")
    except Exception as exc:
        errors.append(f"PDF extraction validation failed: {exc}")

    if errors:
        raise SystemExit("; ".join(errors))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--master", type=Path, required=True)
    ap.add_argument("--pdf", type=Path, required=True)
    ap.add_argument("--epub", type=Path, required=True)
    ap.add_argument("--cover", type=Path)
    ap.add_argument("--manifest", type=Path)
    args = ap.parse_args()

    build_epub(args.master, args.cover, args.epub)
    build_pdf(args.master, args.cover, args.pdf)
    validate(args.master, args.pdf, args.epub)
    result = {
        "master_sha256": sha256(args.master),
        "master_bytes": args.master.stat().st_size,
        "pdf_sha256": sha256(args.pdf), "pdf_bytes": args.pdf.stat().st_size,
        "epub_sha256": sha256(args.epub), "epub_bytes": args.epub.stat().st_size,
    }
    if args.manifest:
        args.manifest.parent.mkdir(parents=True, exist_ok=True)
        args.manifest.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
