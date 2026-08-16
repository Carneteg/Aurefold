# CHATGPT-BRIEF v2 — Martin-loopen är ratificerad: implementera (redo att klistra in)

Klistra in texten nedan till ChatGPT:

---

Hej — Kimi här, andra överlämningen. Kort läge:

**Nyheter sedan förra briefen:** Vi körde en Martin-loop (två storytelling-agenter i GRRM-linjen + en hänsynslös kritiker + mig som boss, två rundor). 12 förslag in, 9 ut. **Tobias har ratificerat hela paketet.** Din uppgift nu: skriv implementationen.

**Materialet ligger i repot Carneteg/Aurefold, branch `review/full-book-swarm-v1.6`, sökväg `review/full-book-v1.6/`:**
- `SLUTPAKET_martin_loop.md` — de 9 ratificerade förslagen med exakta villkor (läs denna först)
- `runda1_martinA_karaktar.md`, `runda1_martinB_plot.md` — originalförslagen med full motivering
- `runda1_kritik.md`, `runda2_kritik.md` — kritikerns domar och rangordning
- `runda2_martinA_lagning.md`, `runda2_martinB_lagning.md` — de lagade versionerna (A3, A5, B3, B4) — dessa texter är dina närmaste specifikationer
- `SLUTRAPPORT.md` + batch-rapporterna från förra omgången ligger kvar oförändrade

**De 9 ratificerade förslagen (styrkeordning, se SLUTPAKET för villkor):**
1. Alaine stryker Sela ur husets levande räkning (kap 47)
2. Ivet får ett eget begär som dör ouppfyllt (före kap 41, 80–150 ord)
3. Korgmodern ägs olöst inifrån muren (Sinnets register, mössan mot köksdörren)
4. Osric ärver blanka sidan inför Jubileet (3 rader)
5. Hessa vägrar ta emot Jerens dom (kap 43 datumrad + scen ≤300 ord, ordlös vägran)
6. Tam döms av Roderick till en säsong i Corrins hushåll (≤200 ord)
7. Markerat icke-avsked: Sela vänder sig, Alaine har redan vänt bort (kap 47)
8. Hessa och Jerens mor ser varandra vid grinden dag fem (kap 41, Rodericks POV, max 4 rader)
9. Kap 45 låter händelser svara: waste-duty-listan + Ansels två datum i marginalen

**Din uppgift:**
1. Skriv den konkreta prosa-implementationen av de 9 förslagen — totalt ca 900–1300 ord fördelat på kap 41–47. Ingen omstrukturering, inga nya scener utöver vad SLUTPAKETET specificerar.
2. Fixa dessutom faktafelet: rad 13166 "Hessa had still packed." → "His mother had still packed." (bekräftat av två oberoende programmatiska granskningar).
3. **Leveransform: en ny branch + PR** (inte direkt i mastern, inte i review-branchen). Tobias mergar själv. Lägg varje förslag i eget commit-block eller med tydliga rubriker i PR-beskrivningen så Tobias kan ratificera punkt för punkt även i textfasen.
4. Respektera villkoren i SLUTPAKETET till punkt — särskilt: A5:s "olidligt för att rättvist" skrivs som detalj, aldrig som tes; B4 del 2 (Ansels datum) har strykklausul — hörs det som en knall på sidan, stryk del 2 och låt del 1 stå ensam; A4 utan föremålsgest; B1 administrativt och tyst, aldrig i Selas POV.
5. **Spärrar du aldrig rör:** Ravenshades patron namnges aldrig, floderna förblir namnlösa, Ederhamn/Elvestad/Ederstad förblir olöst, husjämnvärdighet, webb-ekonomin. Ryggraden orörd: Sela, stängningen, blanka sidan, "She went east."
6. **Kvarvarande från förra briefen:** SLUTRAPPORT.md:s 20 punkter väntar fortfarande på din accept/adjust/reject per punkt (punktnumrerat 1–20, svenska). De 9 Martin-förslagen ersätter inte det svaret — de täcker delmängder av Nivå 2-punkterna men alla 20 ska besvaras.
7. Svara på svenska. Allt du skriver är kanon först när Tobias mergat.

---

*(Slut på brief v2. PR #72 innehåller granskningsmaterialet: https://github.com/Carneteg/Aurefold/pull/72 — implementationen ska som sagt i en NY PR.)*
