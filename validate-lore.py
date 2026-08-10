#!/usr/bin/env python3
"""
validate-lore.py — canon guard for the scaffolded lore files.

Scans content/lore/houses.md and content/lore/characters.md for:
  1. Legacy world names that must never reach production (Emberwold, Vareld).
     NOTE: "Halvard" is NOT legacy — Master Halvard is a canonical Ironvale
     figure (Lore Bible v27; "never retcon Halvard"), so it is deliberately
     absent from this list.
  2. Canon-lock violations that would resolve a protected uncertainty:
       - confirmed magic / supernatural power (must stay ambiguous)
       - Harl's permanent death (no resurrection / spirit-speaking)
       - Col's fate stated or resolved (must stay unconfirmed)
       - Sela's Ledger page filled (must stay blank)
       - the Eleventh House named or its philosophy confirmed

Lock/uncertainty checks scan only the narrative BODY of each file (the text
above the "Developer & Canon Guardrails" section), because the guardrail block
intentionally names the forbidden things in negated form ("No Magic", "no
resurrection") and scanning it would produce false positives. Legacy-name
checks scan the whole file.

Exit code 0 = all clean; 1 = one or more violations (or a scanned file missing).
"""

import re
import sys
from pathlib import Path

FILES = [
    "content/lore/houses.md",
    "content/lore/characters.md",
]

GUARDRAIL_MARKER = "Developer & Canon Guardrails"

# 1) Legacy world names — forbidden anywhere in the file.
LEGACY = [
    (r"\bemberwold\b", "legacy world name 'Emberwold' (retired -> Aurefold)"),
    (r"\bvareld\b",    "legacy world name 'Vareld' (retired dev name)"),
]

# 2) Lock violations — positive assertions that would break a protected
#    uncertainty. Tuned NOT to match the clean canonical prose (e.g. a
#    'miracle' others *weaponize*, or 'saved Col from ritual execution').
LOCKS = [
    # Confirmed magic / supernatural
    (r"\bconfirmed (?:magic|miracle|prophecy|supernatural)\b", "confirmed magic/miracle (must stay ambiguous)"),
    (r"\b(?:real|true|genuine|verified) (?:miracle|prophet|prophecy)\b", "a miracle/prophecy asserted as real (must stay ambiguous)"),
    (r"\bcasts? a spell\b|\bspellcasting\b", "spellcasting (no confirmed magic)"),
    (r"\bglowing runes?\b|\bholy (?:beam|light)\b|\bdivine voice\b", "high-fantasy magic imagery (forbidden)"),
    # Harl — permanent death
    (r"\bHarl\b[^.\n]{0,40}\b(?:resurrect\w*|returns from the dead|comes back to life|reappears alive|speaks from beyond|as a ghost|as a spirit)\b",
     "Harl brought back / speaking after death (Harl is permanently dead)"),
    (r"\b(?:resurrect\w+)\b", "resurrection language (permanent death is canon)"),
    # Col — fate never stated or resolved
    (r"\bCol\b[^.\n]{0,45}\b(?:is dead|is alive|died|survived|survives|was killed|is killed|was hanged|lives on)\b",
     "Col's fate stated/resolved (must stay unconfirmed)"),
    (r"\b(?:killed|hanged|freed|spared) Col\b", "Col's fate stated/resolved (must stay unconfirmed)"),
    # Eleventh House — never named or its philosophy confirmed
    (r"\beleventh house is (?:named|called|the)\b", "the Eleventh House named (must stay unnamed)"),
    (r"\bAshen Crown is (?:the|a|named|called)\b", "the Ashen Crown explained (must stay unconfirmed)"),
]

# 3) Positive invariant: wherever Sela's Ledger is mentioned, it must be blank.
LEDGER_LINE = re.compile(r"ledger", re.I)
LEDGER_OK = re.compile(r"\b(blank|empty|unwritten)\b", re.I)
LEDGER_BAD = re.compile(r"\b(filled|written|inscribed|signed|completed|marked|entered)\b", re.I)


def body_of(text: str) -> str:
    idx = text.find(GUARDRAIL_MARKER)
    return text[:idx] if idx != -1 else text


def scan(path: Path):
    problems = []
    raw = path.read_text(encoding="utf-8")
    body = body_of(raw)

    # Legacy names — whole file.
    for pat, desc in LEGACY:
        for m in re.finditer(pat, raw, re.I):
            problems.append((desc, m.group(0)))

    # Lock violations — body only.
    for pat, desc in LOCKS:
        for m in re.finditer(pat, body, re.I):
            problems.append((desc, m.group(0).strip()))

    # Ledger invariant — body only, line by line.
    for line in body.splitlines():
        if LEDGER_LINE.search(line):
            if LEDGER_BAD.search(line) or not LEDGER_OK.search(line):
                problems.append(("Sela's Ledger page not confirmed blank", line.strip()))

    return problems


def main():
    root = Path(__file__).resolve().parent
    any_fail = False
    print("AUREFOLD lore validation\n" + "=" * 26)
    for rel in FILES:
        path = root / rel
        if not path.exists():
            print(f"FAIL  {rel} — file not found")
            any_fail = True
            continue
        problems = scan(path)
        if not problems:
            print(f"PASS  {rel}")
        else:
            any_fail = True
            print(f"FAIL  {rel}")
            for desc, hit in problems:
                print(f"        - {desc}: “{hit}”")
    print("=" * 26)
    print("RESULT:", "CLEAN ✓" if not any_fail else "VIOLATIONS FOUND ✗")
    sys.exit(1 if any_fail else 0)


if __name__ == "__main__":
    main()
