#!/usr/bin/env python3
"""Aurefold manuscript sync manifest generator.

Reads Markdown locally, hashes chapter/interlude bodies, preserves stable section
identities when possible, and emits a hash-only JSON payload suitable for the
Supabase `author_register_manuscript_version` RPC.

The manuscript prose is never included in the output payload.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
import unicodedata
from pathlib import Path
from typing import Any

PARSER_VERSION = "aurefold-manuscript-sync-v1"
SECTION_RE = re.compile(r"^##\s+(Chapter\b.*|Interlude|Prologue|Epilogue)\s*$", re.I)
TITLE_RE = re.compile(r"^###\s+(.+?)\s*$")
MARKER_RE = re.compile(r"^<!--\s*aurefold:section\s+([A-Za-z0-9._:-]+)\s*-->\s*$")
WORD_RE = re.compile(r"\b[\w’'-]+\b", re.UNICODE)


def normalize_newlines(text: str) -> str:
    return text.replace("\r\n", "\n").replace("\r", "\n")


def normalize_block(text: str) -> str:
    text = normalize_newlines(text)
    return "\n".join(line.rstrip() for line in text.split("\n")).strip() + "\n"


def sha256(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def normalize_heading(text: str) -> str:
    text = unicodedata.normalize("NFKC", text).strip().casefold()
    text = text.translate(str.maketrans({"’": "'", "‘": "'", "“": '"', "”": '"', "–": "-", "—": "-"}))
    return re.sub(r"\s+", " ", text)


def section_type(label: str) -> str:
    low = label.casefold()
    if low.startswith("chapter"):
        return "chapter"
    if low == "interlude":
        return "interlude"
    if low == "prologue":
        return "prologue"
    if low == "epilogue":
        return "epilogue"
    return "other"


def load_baseline(path: Path | None) -> dict[str, Any]:
    if not path:
        return {"sections": []}
    return json.loads(path.read_text(encoding="utf-8"))


def parse_markdown(path: Path, book_code: str, baseline: dict[str, Any]) -> dict[str, Any]:
    raw = normalize_newlines(path.read_text(encoding="utf-8"))
    lines = raw.splitlines()
    starts: list[int] = []
    for i, line in enumerate(lines):
        if SECTION_RE.match(line):
            starts.append(i)
    if not starts:
        raise ValueError("No Markdown chapter/interlude headings found (expected '## Chapter ...' / '## Interlude').")
    starts.append(len(lines))

    baseline_sections = baseline.get("sections", [])
    by_heading: dict[str, list[dict[str, Any]]] = {}
    by_body: dict[str, list[dict[str, Any]]] = {}
    for row in baseline_sections:
        by_heading.setdefault(normalize_heading(row.get("heading", "")), []).append(row)
        by_body.setdefault(row.get("body_sha256", ""), []).append(row)

    used_keys: set[str] = set()
    sections: list[dict[str, Any]] = []
    chapter_counter = 0

    for ordinal, (start, end) in enumerate(zip(starts[:-1], starts[1:]), 1):
        label = lines[start][3:].strip()
        stype = section_type(label)
        if stype == "chapter":
            chapter_counter += 1
            chapter_number: int | None = chapter_counter
        else:
            chapter_number = None

        heading = ""
        body_start = start + 1
        if start + 1 < end:
            m_title = TITLE_RE.match(lines[start + 1])
            if m_title:
                heading = m_title.group(1).strip()
                body_start = start + 2

        body_text = normalize_block("\n".join(lines[body_start:end]))
        section_text = normalize_block("\n".join(lines[start:end]))
        body_hash = sha256(body_text)
        content_hash = sha256(section_text)

        marker_key = None
        if start > 0:
            m_marker = MARKER_RE.match(lines[start - 1])
            if m_marker:
                marker_key = m_marker.group(1)

        stable_key = None
        mapping_status = "unmapped"
        if marker_key:
            stable_key = marker_key
            mapping_status = "marker"
        else:
            candidates = by_heading.get(normalize_heading(heading), []) if heading else []
            candidates = [c for c in candidates if c.get("stable_key") not in used_keys]
            if len(candidates) == 1:
                stable_key = candidates[0]["stable_key"]
                mapping_status = "heading"
            else:
                body_candidates = [c for c in by_body.get(body_hash, []) if c.get("stable_key") not in used_keys]
                if len(body_candidates) == 1:
                    stable_key = body_candidates[0]["stable_key"]
                    mapping_status = "body_hash"

        if not stable_key:
            prefix = book_code.replace("book-", "b")
            stable_key = f"{prefix}-new-{content_hash[:12]}"
        if stable_key in used_keys:
            raise ValueError(f"Duplicate stable_key produced: {stable_key}")
        used_keys.add(stable_key)

        sections.append({
            "stable_key": stable_key,
            "section_type": stype,
            "chapter_number": chapter_number,
            "ordinal": ordinal,
            "label": label,
            "heading": heading,
            "start_line": start + 1,
            "end_line": end,
            "word_count": len(WORD_RE.findall(body_text)),
            "content_sha256": content_hash,
            "body_sha256": body_hash,
            "metadata": {"mapping_status": mapping_status},
        })

    return {
        "parser_version": PARSER_VERSION,
        "file": path.name,
        "source_sha256": sha256(raw),
        "word_count": sum(s["word_count"] for s in sections),
        "section_count": len(sections),
        "sections": sections,
    }


def compare(baseline: dict[str, Any], current: dict[str, Any]) -> list[dict[str, Any]]:
    old = {s["stable_key"]: s for s in baseline.get("sections", [])}
    new = {s["stable_key"]: s for s in current.get("sections", [])}
    rows: list[dict[str, Any]] = []
    for key in sorted(set(old) | set(new), key=lambda k: (new.get(k) or old.get(k)).get("ordinal", 999999)):
        a, b = old.get(key), new.get(key)
        if a is None:
            kind = "added"
        elif b is None:
            kind = "removed"
        else:
            modified = a.get("body_sha256") != b.get("body_sha256")
            moved = a.get("ordinal") != b.get("ordinal")
            renamed = a.get("heading") != b.get("heading")
            if modified:
                kind = "modified"
            elif renamed:
                kind = "renamed"
            elif moved:
                kind = "moved"
            else:
                kind = "unchanged"
        rows.append({
            "stable_key": key,
            "change_type": kind,
            "old_heading": a.get("heading") if a else None,
            "new_heading": b.get("heading") if b else None,
            "old_ordinal": a.get("ordinal") if a else None,
            "new_ordinal": b.get("ordinal") if b else None,
            "mapping_status": (b or {}).get("metadata", {}).get("mapping_status"),
            "needs_review": kind != "unchanged",
        })
    return rows


def make_payload(parsed: dict[str, Any], book_code: str, version_label: str, notes: str | None) -> dict[str, Any]:
    return {
        "p_book_code": book_code,
        "p_version_label": version_label,
        "p_source_filename": parsed["file"],
        "p_source_sha256": parsed["source_sha256"],
        "p_word_count": parsed["word_count"],
        "p_sections": parsed["sections"],
        "p_notes": notes,
    }


def write_tagged_copy(source: Path, parsed: dict[str, Any], target: Path) -> None:
    lines = normalize_newlines(source.read_text(encoding="utf-8")).splitlines()
    by_line = {s["start_line"] - 1: s["stable_key"] for s in parsed["sections"]}
    out: list[str] = []
    for i, line in enumerate(lines):
        if i in by_line:
            if not (out and MARKER_RE.match(out[-1])):
                out.append(f"<!-- aurefold:section {by_line[i]} -->")
        out.append(line)
    target.write_text("\n".join(out) + "\n", encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser(description="Generate Aurefold hash-only manuscript sync payloads.")
    ap.add_argument("manuscript", type=Path)
    ap.add_argument("--book-code", default="book-1")
    ap.add_argument("--version-label", required=True)
    ap.add_argument("--baseline", type=Path)
    ap.add_argument("--out", type=Path, required=True, help="Write RPC payload JSON here")
    ap.add_argument("--comparison-out", type=Path, help="Optional change preview JSON")
    ap.add_argument("--tagged-out", type=Path, help="Optional Markdown copy with stable section markers")
    ap.add_argument("--notes")
    args = ap.parse_args()

    baseline = load_baseline(args.baseline)
    parsed = parse_markdown(args.manuscript, args.book_code, baseline)
    changes = compare(baseline, parsed) if baseline.get("sections") else []
    payload = make_payload(parsed, args.book_code, args.version_label, args.notes)
    args.out.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    if args.comparison_out:
        args.comparison_out.write_text(json.dumps(changes, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    if args.tagged_out:
        write_tagged_copy(args.manuscript, parsed, args.tagged_out)

    counts: dict[str, int] = {}
    for row in changes:
        counts[row["change_type"]] = counts.get(row["change_type"], 0) + 1
    unmapped = sum(1 for s in parsed["sections"] if s["metadata"]["mapping_status"] == "unmapped")
    print(f"{parsed['file']}: {parsed['section_count']} sections, {parsed['word_count']} sync-parser words")
    print(f"source sha256: {parsed['source_sha256']}")
    if changes:
        print("changes:", ", ".join(f"{k}={v}" for k, v in sorted(counts.items())))
    print(f"unmapped sections: {unmapped}")
    print(f"payload: {args.out}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"error: {exc}", file=sys.stderr)
        raise SystemExit(2)
