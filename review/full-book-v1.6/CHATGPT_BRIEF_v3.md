# CHATGPT-BRIEF v3 — två lagningar i v1.7 (redo att klistra in)

Klistra in texten nedan till ChatGPT:

---

Hej — Kimi här. Bossdomen på din v1.7-implementation är klar: **8 HÅLLER + 2 HÅLLER DELVIS**. Först: dina två källkorrigeringar (Hessa = Darels farmor; kap 41 Sela-fokaliserat) är programmatiskt validerade mot mastern — båda var vårt fel, ditt fångande var korrekt. Bra arbete.

Två lagningar återstår innan jag dömer v1.7 slutgiltigt ren. Båda är små (~2 rader totalt):

## Lagning 1 — B3, kapitel 41: berättarläcka i Sela-fokaliseringen
Problemet: raden *"Jeren Tesk's mother had both younger girls beside her."* förutsätter att berättaren vet vem kvinnan är. Kapitlet är Sela-fokaliserat och Sela kan omöjligt identifiera Jerens mor på avstånd — hon känner Hessa Morn, men inte Tesk-hushållet. Ironin ska bäras av läsaren, inte av en berättarröst som inte finns i kapitlet.

Åtgärd (välj en):
- **Alt A (rekommenderas):** bär igenkänningen genom Rodericks kropp — han är den som kan lägret. T.ex.: *"Roderick's count stopped once near the east edge. Hessa Morn stood there with an empty grain sack under one arm. The woman with the two younger girls saw her; Roderick looked from one to the other, and moved on."* — Sela ser att Roderick ser; identiteten på kvinnan lämnas i Rodericks kunskap, inte berättarens.
- **Alt B:** låt kvinnan förbli obenämnd (*"a woman with two girls"*) och låt gesten bära allt: *"The woman drew the smaller girl against her coat and turned toward the food line."*

Båda bevarar: max 4 rader, ingen kommentar, minst en scen före gångjärnen.

## Lagning 2 — A4 9b, kapitel 47: sekvensfel vid kröken
Problemet: ersättningen av *"She did not look back at the wall."* (v1.6 r.17321) börjar med *"At the first bend Sela looked back once."* — men Sela når första kröken först efteråt (gravarna ligger ovanför kröken, v1.6 r.17323). Hon tittar tillbaka vid en plats hon ännu inte nått.

Åtgärd: flytta beatet till efter passagen om gravarnas läge (dvs. efter motsvarigheten till r.17323), eller skriv om öppningen så platsen stämmer där den sitter (t.ex. *"Below the wash slope, where the road first turned, Sela looked back once."*). Resten av beatet — tomma galleriet, en andning, vänd österut — ska inte röras. *"She went east."* är intakt.

## Leverans
Samma form som sist: tydlig diff/PR så Tobias kan ratificera. Berör endast dessa två passager — övriga åtta block är slutdömda HÅLLER och ska inte justeras. Kanonspärrarna givetvis orörda.

Källan för domen ligger i repot: `review/full-book-v1.6/martin-loop/BOSSDOM_implementation_v1_7.md`.

---

*(Slut på brief v3.)*
