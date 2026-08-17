# Aurefold — Book One Character Art Ratification Record v1.0

**Date:** 17 August 2026  
**Status:** ACTIVE — author-facing visual reference control  
**Authority:** Subordinate to the Aurefold Constitution, Canon Ledger, governing Book One Master v1.7, Character Identity Guide, Character & Knowledge Map, and Character Appearance Bible v1.0/v1.1.  
**Canon effect:** No numbered Canon Lock is created. Ratification of an image approves it as a visual reference for character likeness/presentation; it does **not** automatically canonize every incidental prop, background object, fastener, pouch, tool, or other set-dressing detail visible in the image.

## Source review

Decision basis: `review/full-book-v1.6/BOSSDOM_character_art_QC_v1.md` (Kimi, four-agent visual QC; 26 characters × 3 images = 78 images).

## Ratified now — 36 images / 12 characters

All three images (`portrait`, `fullbody`, `at_work`) are ratified for:

- Alaine Serenel
- Fen Leren
- Harl
- Ivet
- Joric Vale
- Merta
- Orla Darun
- Perrin
- Roderick
- Signe
- Tomas
- Wren

Supabase `public.character_art.state` is set to `ratified` for those 36 rows.

## Remaining proposal — 42 images / 14 characters

The following remain `proposal` pending repair or regeneration:

- Col
- Corrin
- Corven Serenel
- Elya Serenel
- Halvard
- Jeren Tesk
- Maren
- Nessa
- Osric
- Roan
- Sela of the Light Heights
- Tam
- Aren Lethren
- Wilda

### Required regeneration set

Regenerate the 26 images identified by the BOSSDOM review:

- Aren: portrait, fullbody, at_work
- Wilda: portrait, fullbody, at_work
- Sela: portrait, fullbody
- Halvard: fullbody
- Col: fullbody, at_work
- Corrin: fullbody, at_work
- Tam: portrait
- Corven: portrait, fullbody, at_work
- Jeren: fullbody, at_work
- Osric: fullbody
- Maren: fullbody
- Roan: fullbody
- Elya: at_work
- Nessa: portrait, fullbody

Use the accepted portrait as the reference image whenever available to lock face and age. Explicitly side-fix scars, injuries, marks, deafness/listening side, patches, and other directional continuity facts in prompts.

## Accessory and set-dressing policy

1. **Images do not create canon by themselves.**
2. Symbolic, heraldic, devotional, identity-signalling, or narratively suggestive accessories not supported by governing text should be removed during regeneration unless separately adopted in text control.
3. Generic functional period-appropriate objects may remain as visual set dressing if non-contradictory, but remain non-canonical unless textually established.
4. Specifically remove or avoid on regeneration: Wilda's cross, Corrin's coin pendant unless separately adopted, Aren/Jeren invented brooches when regenerating, and Aren's invented belt knife.
5. Nessa's hip bag and Orla's utility pouches may remain as non-canonical functional set dressing if visually appropriate; they do not become character facts through image ratification.

## Storage/access state

Creator instruction controls bucket visibility. At the time of this record, `character-art` is intentionally public for retrieval. Existing signed QC URLs may remain until expiry but are not the governing access model.

## Canon safety

- Constitution unchanged.
- Canon Ledger unchanged.
- Governing Book One manuscript unchanged by this decision.
- Canon Locks remain 85 / max #085.
- Canon Lock #086 remains unused.
