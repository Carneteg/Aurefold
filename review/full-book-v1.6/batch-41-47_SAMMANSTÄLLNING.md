# SAMMANSTÄLLNING — Våg 8 (kap 41–47, rader 14903–17533) — SISTA VÅGEN

Granskad: 2026-08-16. Fem perspektiv: struktur, karaktär, prosa, plot (GoT), värld.
Kritikrunda: genomförd av orkestron med programmatisk verifikation mot mastern.

## Kritikrunda — resultat

**Citat: samtliga kontrollerade citat exakta** (rader 14906–17533 + bakåtreferenser; fragmentverifiering via substring-match där agenten citerat del av stycke, t.ex. prosa r.15700). Inga fabrikationer.

**Metadatanoteringar (slutsatser opåverkade):**
1. **värld — fyra felräkningar:** "Aren" 207 påstått → faktiskt **107** (hela ordet, case-sensitivt); "Whitehart" 258 ci påstått → faktiskt **263**; "river" 9 påstått → faktiskt **13** ci; "Garron" 1 påstått → faktiskt **4** (r.16531, 16535, m.fl.). Sista-träff-raderna (Aren 13764, Corven 13768) stämmer däremot exakt, liksom "Lower Field" 19/0 i batchen.
2. **prosa — en felräkning:** "changed" 79 påstått → faktiskt **81** (batchandelen 16 och de tre namngivna raderna 14960/14972/14998 korrekta).
3. **plot — ett radnummer:** "Six days after the crush" citerat r.16044 → faktiskt **r.16046**.

**Verifierat som korrekt:** Jeren 19 träffar/sista 13164; Hessa 36/13166; Corven 107/13768; "Vey" 1 träff (r.17531); "laughed once" 8 (raderna exakta); "waited."-helrader 20/8 i batchen; "No."-helrader 105; "ten seals" 0 (se nedan); "eleven" 1 (= "## Chapter Eleven"); Ravenshade 1 (r.6795); patron 1 (r.8065); Stormrider 1 (r.16567); Binder 1 (r.16535); Nessa 0 i batchen; Blackcrest 24 / Blackthorn 7 / Serenel 44 / Duskport 11 ci; kapitelordräkning (41:1663, 42:1232, 43:4653, 44:2117, 45:3012, 46:2385, 47:2894, kap 3: 5128, kap 21: 5072) — **exakt**.

**"TEN SEALS"-LARMET AVKRAFTAT (orkestrons ansvar):** Tre agenter eskalerade "ten seals — some say eleven saknas i mastern (0 träffar)". Det är **inte ett fel**. Spärren lyder: frasen ska förekomma exakt en gång **på index.html** (webbguardrail). Frasen ska INTE finnas i mastern — 0 träffar är det korrekta tillståndet. Agenterna har alltså verifierat att master-sidan av spärren håller. index.html-sidan verifieras vid GitHub-uppdateringen. Ingen åtgärd i manus. (Min egen brief var otydlig — noterat som metodlärdom.)

## Vågens fynd — konvergens

**Fem agenter, fem oberoende röster, samma slutsats:** slutakten är bokens starkaste parti. Ivets död (kap 41) bedöms av tre agenter som bokens mest förtjänta chock (löfte r.10637 → r.15205; stygn r.15125–15135; fysik ärligt oavgjord r.15000). Tomas nyckelöverlämning (r.16904–16966) och Selas "She went east." (r.17533) landar — prosans ord: "praktik före symbol"; "They did not become a road." (r.17529) besvarar den falska aforismen (r.16591) med terräng.

**NYTT TEKNISKT FEL — HÖG (struktur, enda agenten men starkt dokumenterat):** Fen står i Ledgerrummet utan att ha förts in — r.16944–16950 ("Fen looked at him. 'You make confession sound like inventory.'") i en scen där endast Sela, Tomas, Osric och Alaine etablerats (r.16872–16874), trots "Fen had not been spoken to in five months." (r.15462); Alaine lämnar utan Fen (r.16984) och Sela hittar honom vid muren direkt efter (r.17042). Förslag: flytta replikväxlingen till muren-scenen.

**Nya tekniska/tidsfel:** "Three weeks earlier" (r.17259) mot ≈16–17 dagars textmarkörer [MEDEL]; "Vey" oetablerat toponym i näst sista meningen (r.17531) [MEDEL, 2-agent-konvergens prosa+struktur]; Mertas Chronicle-post om Col (r.4704/4814) — enda Chronicle-tråden utan statusmarkör [MEDEL].

**Skuldernas sluträkning:**
- **Alaine/Aren/Corven betalar inget oåterkalleligt.** Aren 0 och Corven 0 träffar i hela slutakten (sista 13764/13768). Alaine sörjer (r.15359–15371) och släpper Sela (r.17303–17313) men förlorar inget synligt. Inverterat mönster: Tomas (vägrade döma) förlorar ämbetet, Wren (vägrade exponera) förlorar certifieringen — beslutsfattarna skyddas. [ESKALERAD HÖG — karaktär + plot]
- **Jeren/Hessa: 0 träffar i slutakten.** Vare sig inlösen eller ägd, markerad tystnad. [HÖG-MEDEL — karaktär + plot]
- **Ivet dör utan eget begär** — posthumt definierad av andras tjänsteminnen (r.15333/15341). [HÖG — karaktär, eskalerad punkt nu permanent]
- **Korgmodern (r.14897): aldrig löst, omarkerad öppen tråd.** [HÖG — plot]
- **Extern blindhet: 6/6 vågor.** "Lower Field" 0 efter r.14082. Omvärlden får Corrins fabulerade vers (r.16581) — mytexport istället för fakta. Texten markerar aldrig att detta ÄR svaret. [Designbeslut att äga eller markera — värld]
- **Nellakontot:** gäldenärsfrågan (r.9551) löses genom att upphöra — omarkerat. Ansel läser bara datum (r.16319). [MEDEL — värld]
- **Jubilee-ramen (r.7/13668): aldrig indragen, ingen slutmarkör.** [MEDEL — plot + karaktär + struktur]
- **Waste-duty-kvinnan ("Then enter the question." r.14835): återkommer aldrig.** [MEDEL — plot]
- **Tam ostraffad** ("Corrin will live." r.17164 är inget pris). [MEDEL — plot]

**Laddningsinventering (plot):** Wrens papper AVFYRAT (internt, fullt betalt); "Sela ordered it" medveten icke-detonation (r.15036, försvarbart); niodagarmatten implicit bekräftad, aldrig avfyrad; Orlas dom hålls laddad men oanvänd; korgmodern glömd.

**Prosanyheter:** tickers "laughed once" (8, troligen avsiktligt eko 3135→17451), "waited."-helrader (20, kluster 17230/17301/17347), "No."-helrader (105). Trimintervall: r.15700–15712 (kap 43), ev. r.15980–15992. Kap 43 är bokens tredje längsta (faktakorrigerat), slutaktens längsta — försvarar sin längd.

**Styrkor att bevara orörda:** dubbelräkningen 9/12 aldrig harmoniserad (r.15064/15070/16132/16581); Daven-listans dubbla payoff (r.16028/17226–17232); Binder-interregnet (r.16535–16567); Nellas valutabyte skuld→tacksamhet (r.16407–16453); klockans kodöverskridande slag (r.17497–17521); kap 42 "The Washing" (1232 ord, noll spill); Fen–Merta (kap 43); Mertas ägda icke-svar (r.17377).

**Spärrar bekräftade till sista raden:** Ravenshades patron aldrig namngiven; floder namnlösa (sista vattnet "a narrow stream" r.17473); Ederhamn/Elvestad/Ederstad 0; husjämnvärdighet (Blackcrest FÖRLORAR sitt köp — ingen överordning); "ten seals" 0 i mastern = korrekt (webbspärr, se ovan).

## Slutstatus efter 8 vågor
Hela boken (47 kapitel, 17 533 rader, 105 494 ord) är genomgången av 5 perspektiv × 8 vågor. Alla rapporter i /mnt/agents/output/granskning/. Nästa steg: slutrapport till författaren, sedan GitHub-PR, Supabase-hashindex, ChatGPT-brief. **Inga ändringar i manus förrän användaren ratificerar.**
