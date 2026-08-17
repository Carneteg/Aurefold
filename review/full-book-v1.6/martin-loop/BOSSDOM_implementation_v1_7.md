# BOSSDOM — ChatGPT:s v1.7-implementation av Martin-loop-paketet

Granskad: `implementation/book-one-v1.7/Martin_Loop_Prose_Implementation_PROPOSAL.md` (GitHub, blob 81898be1)
Metod: samtliga förankringspunkter verifierade programmatiskt mot English Master v1.6; villkorsföljsamhet mätt mot SLUTPAKET + runda-2-lagningar.
(Kritiker-subagenten kunde inte startas — bossen dömde direkt.)

## ChatGPT:s två källkorrigeringar — VALIDERADE
1. **Hessa Morn är Darels farmor, inte mor** — mastern r.13010: "who shot her grandson". Vår egen spec (A3-lagningen + kritikerns krav) sa "the mother" — det var VÅRT fel, ChatGPT fångade det. Loggraden "delivered to Hessa Morn" är korrekt.
2. **Kapitel 41 är Sela-fokaliserat** (r.14906, 14930, 14946). Vår spec sa "Rodericks POV" — fel. ChatGPT höll Selas fokalisering och gjorde Roderick till observerad aktör. Faktamässigt korrekt.

## Förankringsverifiering (programmatisk)
- Fix r.13166: korrekt lokaliserad, korrekt ersättning.
- A3a-ankare "Nine names had gone up to Whitehart. / Twelve were spoken below." — r.15714–15716, kap 43.
- A3b-ankare "Wren left the report on the outgoing table." — r.16256, kap 44.
- B4b-ankare "One shelter appeared on both the water and waste lists." — r.16361, kap 45.
- B5-ankare "Osric closed his fingers around it." — r.16968, kap 46.
- A5-ankare "Tam waited near the empty stable with Harl's knife." — r.17150; "You would hear whatever you needed." — r.17176.
- B1-ankare grå klänning — r.17309, kap 47.
- A4b-original "She did not look back at the wall." — r.17321.
- "She went east." — r.17533, orörd.

## Dom per block

| Block | Dom | Anmärkning |
|---|---|---|
| Fix r.13166 | **HÅLLER** | Ren faktakorrigering. |
| A2 Ivet | **HÅLLER** | Banalt begär (sovmorgon, ovägd mat), ägs av Sinnet/institutionen, "I will forget." / "So will I." planterar Selas glömska exakt som specificerat. Torr, mästarlik röst. |
| B3 grinden | **HÅLLER DELVIS** | 4 rader, ingen kommentar, före gångjärnen — villkoren hålls. MEN: "Jeren Tesk's mother had both younger girls beside her" är berättarkunskap i ett Sela-fokaliserat kapitel — Sela kan inte veta vem kvinnan är. LAGNING: omformulera genom Rodericks kropp ("Roderick's count stopped once near the east edge... He looked from Hessa Morn to the woman with the two girls, and moved on.") eller låt kvinnan förbli obenämnd för Sela. Ironin måste ligga hos läsaren, inte hos en berättare som inte finns i kapitlet. |
| A3 vägran | **HÅLLER** | Datumraden sitter exakt rätt (r.15716). Vägranen är ordlös (alt 1), enda dialogen praktisk ("Do you want a copy?"). Loggraden platt, "She did not add a reason." Lökdetaljen är bokens egen röst. |
| B4a Ansel | **HÅLLER** | Två datum, "went on to the next correction" — noll reaktionsrad. Strykklausulen behövde inte aktiveras: det hörs inte som en knall. (Placeringsnoten säger "route count" — masterns r.16319 är en dag-räkning; kosmetiskt i noten, texten fungerar.) |
| B4b waste-duty | **HÅLLER** | En mening. Listan agerar, kvinnan förblir namnlös. |
| A6 korgmodern | **HÅLLER** | Sinnets praktiska register ("damp wool molded in drawers"), mössan vid dörren, modaliteten öppen. Avslutsraden är berättarmodal men tillåten — den äger olöstheten utan att peka. |
| A5 Tam | **HÅLLER** | "Good. Saves time." är exakt potatisskalningsregistret. Det färdigpackade sovmunderingen bär "olidligt för att rättvist" som detalj, aldrig tes. 6c är en enda bisats — knivscenen orörd i replikerna. |
| B5 Osric | **HÅLLER** | Tre rader. "The duty to say what it does not prove" — Orlas dom som laddat vapen, inte segrande sanning. |
| B1 räkningen | **HÅLLER** | Administrativt, tyst, Alaines POV. "The line did not say released. / It did not say expelled." går precis på gränsen till tematisk pekning men stannar inne i scenens egen logik. Destinations-/garantfälten lämnade tomma = tvetydigheten bevarad. |
| A4 icke-avsked | **HÅLLER DELVIS** | 9a är perfekt (Alaine vänder innan någon figur syns — noll kontakt). 9b har ett sekvensfel: ersättningen sitter vid r.17321 men säger "At the first bend" — första kröken nås först vid r.17323 (gravarna ovanför kröken). LAGNING: flytta beatet till efter r.17323 eller skriv om öppningen ("Below the graves, where the road bent..."). Slutets rörelse mot "She went east." är intakt. |

## Helhetsdom: 8 HÅLLER + 2 HÅLLER DELVIS → **GODKÄND MED TVÅ SMÅ LAGNINGAR**

Prosan låter som boken. Villkorsföljsamheten är hög — högre än specifikationens egen faktanoggrannhet (två av våra fel korrigerade ChatGPT tyst och korrekt). De två lagningarna är ~2 rader totalt. Därefter är v1.7 slutgiltig ur mitt perspektiv — ratificering och merge är, som alltid, Tobias ensam.
