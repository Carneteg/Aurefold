# The Bell of Silence v1.7 — BOSSDOM Two-Passage Fix

**Status:** PROPOSAL — NOT GOVERNING UNTIL TOBIAS RATIFIES AND MERGES  
**Source judgment:** `review/full-book-v1.6/martin-loop/BOSSDOM_implementation_v1_7.md`  
**Governing manuscript baseline:** `Aurefold_The_Bell_of_Silence_English_Master_v1.7.md`  
**Baseline SHA-256:** `0294da99bb085a7aad7a722ab34a11e80ef9a4196856fad78b66560d04333970`  
**Patched-candidate SHA-256:** `801b9036944c6aca379952880705543cecc945c0ba96ce38a67f4aa2edc5c5e3`

This proposal implements only the two passages judged **HÅLLER DELVIS** by Kimi. The other eight Martin-loop blocks are not touched.

## Fix 1 — B3 / Chapter 41 / Sela focalization

**Reason:** Sela can observe Hessa Morn and the second woman, but the focalized narration must not identify the second woman as Jeren Tesk's mother when Sela cannot know that identity at this distance.

**Decision:** Use Kimi Alt B, the minimal repair. The woman remains unnamed in Sela's focalization; the reader carries the recognition.

```diff
-Roderick's count stopped once near the east edge. Hessa Morn stood there with an empty grain sack under one arm. Jeren Tesk's mother had both younger girls beside her.
+Roderick's count stopped once near the east edge. Hessa Morn stood there with an empty grain sack under one arm. A woman stood there with two younger girls beside her.
 
 The two women saw each other.
 
-Jeren's mother drew the smaller girl against her coat. Hessa turned back toward the food line. Roderick moved on.
+The woman drew the smaller girl against her coat. Hessa turned back toward the food line. Roderick moved on.
```

No other Chapter 41 prose changes.

## Fix 2 — A4 9b / Chapter 47 / first-bend sequence

**Reason:** The non-farewell beat currently begins `At the first bend` before the prose has established Sela reaching that bend. The beat itself is retained; only its placement changes.

**Decision:** Move the sentence establishing the new graves above the first bend before the look-back beat. The look-back wording, empty gallery, one breath, eastward turn, and all later prose remain unchanged.

```diff
 Sela followed it past the wash slope and the roofless treatment shelter. Frost held the last pieces of straw to the ground. Someone had stacked the shelter boards by length. Someone else had left a single strip of bandage tied to the corner post. It moved when the wind came down from the shoulder.
 
+The new graves lay above the first bend, nine low mounds in ground cut before it had frozen hard. No names stood there yet.
+
 At the first bend Sela looked back once.
 
 The upper gallery was empty.
 
 She stood there for one breath, with the wall above her and the road dropping away below, then turned east and kept walking.
 
-The new graves lay above the first bend, nine low mounds in ground cut before it had frozen hard. No names stood there yet. Whitehart's grave had been closed again farther up, the turf replaced in a rectangle that did not match the color around it. The edges had settled after rain. From the road it looked less like a grave than a repair made with the wrong stone.
+Whitehart's grave had been closed again farther up, the turf replaced in a rectangle that did not match the color around it. The edges had settled after rain. From the road it looked less like a grave than a repair made with the wrong stone.
```

No other Chapter 47 prose changes. `She went east.` remains untouched.

## Validation

- Exactly one occurrence of the B3 source block was found and patched.
- Exactly one occurrence of the A4 source block was found and patched.
- Baseline manuscript hash matched the adopted v1.7 registry hash before patching.
- No Constitution, Canon Ledger, Canon Lock, source registry, scorecard, or Supabase row is changed by this proposal.
- If Tobias ratifies and merges, the governing manuscript must then be updated on Drive and the Book One v1.7 manuscript/scorecard hashes re-synchronized in Supabase.

**Loremaster ruling:** both repairs are accepted as source-faithful continuity/focalization corrections. They do not alter plot, character outcome, protected ambiguity, or canon architecture.
