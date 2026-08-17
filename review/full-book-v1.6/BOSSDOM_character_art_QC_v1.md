# BOSSDOM — Visuell QC av karaktärsart, Bok 1

**Datum:** 2026-08-17
**Granskare:** Kimi (orkestratör) via fyra parallella QC-agenter
**Omfattning:** 26 karaktärer × 3 bilder = 78 bilder, genererade mot Appearance Bible v1.0 + v1.1 Expansion
**Kanonstatus:** [FÖRSLAG — inte kanon]. Inget ratificeras utan Tobias ord. `state` i `public.character_art` förblir `proposal`.
**Åtkomst:** Bucketen `character-art` förblir PRIVAT. 78 tidsbegränsade signerade URL:er (7 dagar, utgår ~2026-08-24) är lagrade i `character_art.qc_url` för author-only visuell granskning. Inga anonyma policies kvar (verifierat).

---

## Sammanfattande dom

| Omdöme | Antal | Karaktärer |
|---|---|---|
| **HÅLLER** | 12 | alaine, fen, harl, ivet, joric, merta, orla, perrin, roderick, signe, tomas, wren |
| **HÅLLER DELVIS** | 12 | col, corrin, corven, elya, halvard, jeren, maren, nessa, osric, roan, sela, tam |
| **FALLER** | 2 | aren, wilda |

**Genomgående mönster:** Fullbody-bilderna är den svaga länken — hos ~10 karaktärer visar fullbody en annan person (ålder/ansikte/hår) än portrait och at_work. Rekommendation: lås ansikte via referensbild (portrait som reference-image) vid all regeneration.

---

## FALLER — kräver om-generering

### aren — FALLER
**Canon-brott:** Det platta/krossade örat (hårt etablerat faktum) SAKNAS i alla tre bilder — båda öron normala. Dessutom: inventerad brosch (portrait) och inventerad bälteskniv (fullbody); kläderna underlevererar "excellenta, hårt använda" i 2 av 3 (at_work är dock tonmässigt perfekt: räknetavla, spannmål, galonrock).
**Åtgärd:** Generera om alla tre med explicit prompt om krossat/platt öra (sidefixera i prompt), utan tillagda accessoarer.

### wilda — FALLER
**Problem:** (a) At_work visar en ANNAN kvinna (ljusare hår, yngre/mjukare drag). (b) Bandagets sida är inkonsekvent (vänster i portrait, höger i övriga) — sidan är inte sidefixerad i Bibeln, men intern konsistens krävs; föreslå fixering till vänster hand. (c) Träkors-halsband i portrait: korsform är inte etablerad symbolik i Aurefold — inventerad anakronism tills motsatsen bevisats. Ta bort.
**Åtgärd:** Generera om alla tre; samma ansikte via referens; inget kors; bandage konsekvent på samma hand.

---

## HÅLLER DELVIS — kräver lagning eller explicit författarbeslut

### sela
**Canon-brott:** Det vita ögonbrynshacket sitter på HÖGER ögonbryn i de två bilder där det syns; canon säger VÄNSTER. I övrigt fullträff (grågröna ögon, fläta, vindbrunad näsa, röda valkiga händer, getter i karg höjdmiljö).
**Åtgärd:** Generera om portrait/fullbody med "thin white notch through her LEFT eyebrow" (eller författarbeslut om visningsvinkel).

### halvard
**Canon-brott:** Fullbody kupar handen mot det VÄNSTRA (döva) örat — canon: döv vänster, vänder HÖGER öra mot tysta talare. Portrait (beslag i rocken) och at_work (sågspån, verkstad) är starka.
**Åtgärd:** Generera om fullbody med korrekt lyssningsgest (eller croppa).

### col
**Canon-brott:** (a) Den blå lappen ska sitta på ARMBÅGEN — sitter på överarmen i fullbody; sidan växlar mellan bilderna. (b) At_work visar en glas-petroleumlampa (1800-tal) — sannolik anakronism; porträttets plåtlykta är mer försvarbar. Porträttet är nästan kanonvärdigt.
**Åtgärd:** Generera om fullbody + at_work: lapp på armbåge, samma arm i alla bilder, tidsenligt ljus (talgljus/oljelampa).

### corrin
**Problem:** Åldersglidning (gråsprängd ~55 i portrait, mörkhårig ~40 i fullbody/at_work); kluven stav (Y-grenad) korrekt i portrait men rak okluven käpp i at_work; det dåliga benet visualiseras inte (staven bär ingen tyngd); inventerat mynthänge runt halsen. Korrekt att ingen ansiktsskada visas (före Tams överfall).
**Åtgärd:** Generera om fullbody/at_work med ålderslås + kluven bärande stav; beslut om mynthänget (behåll = nytt kanonfaktum, kräver ratificering; ta bort = säkert).

### tam
**Problem:** Porträttet läser 19–22 år och är för stylat; canon kräver synlig 17-årig ofärdighet (långa handleder, ofärdiga axlar — fullbody fångar detta bäst). Fullbody har håret i knut — mot "hår som vägrar sitta uppknutet".
**Åtgärd:** Generera om portrait med yngre drag; hår halvt löst (som at_works kompromiss).

### corven
**Problem:** "Dyrbara kläder som används hårt" underlevereras — plaggen läser dräng snarare än adelsman i slitage (brosch + guldring i fullbody är svag kompensation). Fullbody-ansiktet avviker (rundare, äldre, rödbrunare hår). Arbetet/kompetensen är rätt.
**Åtgärd:** Generera om med finare material (ull av kvalitet, bra läder, mantel) i synbart slitage; lås ansiktet.

### jeren
**Problem:** At_work placerar honom i lerig STADSGATA/marknad — canon är vägvakt vid vått vägtäcke/grästuva; osäkert fotfäste saknas. Fullbody är för hård/skurkaktig + inventerad metallbrosch. Portrait är kanon-nära (armborst med överdriven omsorg, våt mantel, ungdomlig spänning).
**Åtgärd:** Generera om at_work (vägkant, våt grästuva, halka) och fullbody (mjukare drag, ingen brosch).

### osric
**Problem:** Fullbody är en ANNAN man (annan frisyr, yngre/hårdare) + munkkutalik siluett drar mot generisk präststereotyp. Portrait och at_work (skrivbräda, bläckfingrar, registerföring) är starka.
**Åtgärd:** Generera om fullbody med samma man, utan kutsiluett.

### maren
**Problem:** Fullbody är en yngre, tyngre kvinna — fel person. At_work är nära perfekt (kärl mot ljuset, sårtält, närhet till sår) men kärlet liknar en modern glasburk med patentlock — MÖJLIG ANAKRONISM, bedöm visuellt. Behandlingsdukar saknas i fullbody.
**Åtgärd:** Generera om fullbody; kontrollera/ersätt burken i at_work vid eventuell om-generering.

### roan
**Problem:** Fullbody är en tydligt yngre, leende man med annat ansikte. Portrait (vägslitet, pack sheets) och at_work (regnslitna papper, reselager) är starka. Ingen nomadstereotyp.
**Åtgärd:** Generera om fullbody med ansikts-/åldersmatch.

### elya
**Problem:** At_work visar en ~15 år yngre, mörkhårig kvinna — porträttet (gråsprängd ~60, Serenel-ögon, ögonvråveck) är kanonvärdigt. Svag men verklig familieair mot alaine_portrait — DELVIS träff på släktlikheten, vilket är rätt kalibrering (inte kopierat ansikte).
**Åtgärd:** Generera om at_work åldrad upp; behåll portrait som referens.

### nessa
**Problem:** Mjölsäcken bärs högt framför bröstet/magen i portrait och fullbody — canon är LÅGT MOT HÖFTEN. At_work är utmärkt (regnig rutt, bärställning nära höften, ingen romantisering). Fullbody ser yngre ut; inventerad lerväska på höften (ofarlig men onyanserad).
**Åtgärd:** Generera om portrait/fullbody med säck lågt mot höften.

---

## HÅLLER — redo för ratificering (med mindre noteringar)

- **alaine** — Fullträff. Flätan tolkad som kronfläta; verifiera mot "braided flat" vid ratificering.
- **tomas** — Fullträff inkl. kolfläckade fingrar och ojämn gråning. Notering: metalllykta i at_work bör bytas mot ljus/oljelampa vid framtida re-render (rekvisita, ej canon-brott).
- **perrin** — Mycket stabil konsistens; näsans snedhet kan förstärkas (ej blockerande).
- **wren** — Brännmärke på korrekt (höger) hand i båda synliga bilder; käkklippt hår; at_work-håret marginellt kortare (ej blockerande).
- **fen** — Utmärkt: stoop, hår över ena ögat, vaxflagiga händer, road mun, ljusgjutarverkstad.
- **orla** — Mended coat exemplarisk; marginell hårlängdsvariation i at_work; inventerade bältesväskor (milda, ofarliga).
- **harl** — Kniv framtill, tunga bryn (Tams arv trovärdigt), takarbete; säckvävslindor bara delvis visade (väderberoende signatur — acceptabelt).
- **merta** — Snöscenen med Cols vikta kappa över båda underarmarna exakt enligt signatur; ingen estetiserad sorg, ingen aura.
- **ivet** — Tre blå lagstygn återgivna i alla tre (starkast i at_work); ordinariet bevarat, inget martyrskimmer. Bekräfta blå färg + ojämnhet i fullbody vid ratificering.
- **joric** — At_work utmärkt (framåtlutad sits, kortade tyglar, blick nedför); fullbody något yngre ansikte (ej blockerande).
- **roderick** — Starkast interna konsistens i hela batchen; bunden HÖGER axel konsekvent i alla tre. Mild heroik-ton i at_work (tvåhandsgrepp trots skadan) — rekommenderar toning, ej krav.
- **signe** — Komplett signaturtäckning: trossnöre, pluggar, linjetavla, murare, blick nedåt mot terrängen. Inga brott.

---

## Tekniska flaggor (ej karaktärsbundna)

1. **Anakronismer att rensa vid regeneration:** glas-petroleumlampa (col at_work), metalllykta (tomas at_work), möjligt patentlock på glaskärl (maren at_work), träkors (wilda portrait).
2. **Inventerade accessoarer som kräver beslut eller borttag:** corrins mynthänge, nessas höftväska, orlas verktygsväskor, jerens/arens broscher, arens bälteskniv.
3. **Inga övernaturliga inslag, inga moderna plagg (dragkedjor/knappar/maskinsömnad) observerade i någon av 78 bilder.**
4. **Nella of Duskport:** korrekt EXKLUDERAD — ingen bild existerar, enligt Bibelns absoluta regel.

## Rekommenderad åtgärdsplan

1. **Omedelbar om-generering (FALLER):** aren (3), wilda (3) — 6 bilder.
2. **Riktad om-generering (HÅLLER DELVIS):** sela portrait+fullbody (vänster ögonbryn), halvard fullbody, col fullbody+at_work, corrin fullbody+at_work, tam portrait, corven alla tre, jeren fullbody+at_work, osric fullbody, maren fullbody, roan fullbody, elya at_work, nessa portrait+fullbody — totalt 20 bilder.
3. **Metod:** använd godkänt portrait som reference-image för att låsa ansikte/ålder; sidefixera alla skador/märken explicit i prompt.
4. **Ratificering:** 12 HÅLLER-karaktärer (36 bilder) kan ratificeras nu på ditt ord — då sätts `state='ratified'` för just de raderna. Ingenting sker automatiskt.
