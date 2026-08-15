/* AUREFOLD — "Which of the Ten Houses would you follow?" A shareable quiz.
   Uses only the public house philosophies (locked canon; no spoilers).
   Localized: the interface, questions, philosophies, and taglines follow
   <html lang>. House KEYS and the canonical "House X" names never change
   (they drive share URLs, house-<key>.html, and analytics), so results and
   share links stay identical across languages. */
(function () {
  "use strict";
  var root = document.getElementById("quiz");
  if (!root) return;

  var LANG = (document.documentElement.lang || "en").slice(0, 2);

  // Stable house identity: key + canonical display name (kept in English as a
  // proper noun, matching the rest of the site). Localized philosophy label and
  // tagline are looked up per language below.
  var HOUSES = {
    blackthorn:  { name: "House Blackthorn" },
    ravenshade:  { name: "House Ravenshade" },
    ashbourne:   { name: "House Ashbourne" },
    whitehart:   { name: "House Whitehart" },
    stormrider:  { name: "House Stormrider" },
    ironvale:    { name: "House Ironvale" },
    blackcrest:  { name: "House Blackcrest" },
    stonebear:   { name: "House Stonebear" },
    tidebreaker: { name: "House Tidebreaker" },
    phoenix:     { name: "House Phoenix" }
  };

  var STR = {
    en: {
      phil: {
        blackthorn: "Intellect", ravenshade: "Information", ashbourne: "Courage",
        whitehart: "Faith", stormrider: "Unity", ironvale: "Innovation",
        blackcrest: "the victor's history", stonebear: "Honor",
        tidebreaker: "Knowledge", phoenix: "the future"
      },
      line: {
        blackthorn:  "They plan for every future — and act a moment too late.",
        ravenshade:  "They trade in what people would rather keep hidden.",
        ashbourne:   "They ride at the thing everyone else flinches from.",
        whitehart:   "They listen for a voice — and test those who claim to hear it.",
        stormrider:  "They hold people together — as long as the one who binds them lives.",
        ironvale:    "They measure everything, and build what no one else dares.",
        blackcrest:  "They keep the record — and the record is a kind of power.",
        stonebear:   "They keep their word past the point it costs them everything.",
        tidebreaker: "They chart all of it, and share almost none.",
        phoenix:     "They build on scorched ground and refuse to look down."
      },
      q: [
        { q: "A hard decision looms. What do you trust most?", a: [
          ["A careful plan for every outcome.", "blackthorn"],
          ["What I can find out that others can't.", "ravenshade"],
          ["My own nerve.", "ashbourne"],
          ["What I believe to be true.", "whitehart"] ] },
        { q: "The realm is fracturing. Your first instinct is to—", a: [
          ["Hold everyone together.", "stormrider"],
          ["Build something new from the pieces.", "ironvale"],
          ["Make sure the true account survives.", "blackcrest"],
          ["Keep the oath I swore, whatever it costs.", "stonebear"] ] },
        { q: "People would say your greatest strength is—", a: [
          ["I understand more than I let on.", "tidebreaker"],
          ["I never give up on tomorrow.", "phoenix"],
          ["I think three moves ahead.", "blackthorn"],
          ["I'm simply not afraid.", "ashbourne"] ] },
        { q: "A stranger asks for your help. You—", a: [
          ["Weigh what it will cost me first.", "blackthorn"],
          ["Ask what they're not telling me.", "ravenshade"],
          ["Help — and keep my word on it.", "stonebear"],
          ["Trust the impulse to do right.", "whitehart"] ] },
        { q: "Which sounds most like you?", a: [
          ["Knowledge is worth more than gold.", "tidebreaker"],
          ["Unity is worth more than being right.", "stormrider"],
          ["The story we tell becomes the truth.", "blackcrest"],
          ["The future is worth any fire.", "phoenix"] ] },
        { q: "When everything goes wrong, you—", a: [
          ["Rebuild, better than before.", "phoenix"],
          ["Charge the problem head-on.", "ashbourne"],
          ["Find the fact everyone missed.", "ravenshade"],
          ["Stand by what I promised.", "stonebear"] ] }
      ],
      ui: {
        progress: function (i, total) { return "Question " + i + " of " + total; },
        back: "← Back",
        eyebrow: "YOU WOULD FOLLOW",
        castVote: "Cast this as your vote in The Moot",
        followFree: "Follow free",
        joinReaders: function (n) { return "Join " + n + " reader" + (n === 1 ? "" : "s") + " following along"; },
        shareLabel: "Tell them which house you'd follow",
        shareX: "Share on X", facebook: "Facebook", reddit: "Reddit", copy: "Copy",
        again: "↻ Take it again",
        note: "The book's canon and central mysteries are the author's; the Moot and this quiz shape the world around it — what the archive opens or explores next — never the story's heart.",
        shareText: function (shortName) { return "I'm House " + shortName + " in Aurefold — which house are you?"; }
      }
    },
    sv: {
      phil: {
        blackthorn: "Intellekt", ravenshade: "Information", ashbourne: "Mod",
        whitehart: "Tro", stormrider: "Enhet", ironvale: "Innovation",
        blackcrest: "segrarens historia", stonebear: "Heder",
        tidebreaker: "Kunskap", phoenix: "framtiden"
      },
      line: {
        blackthorn:  "De planerar för varje framtid — och handlar ett ögonblick för sent.",
        ravenshade:  "De handlar med det folk helst vill dölja.",
        ashbourne:   "De rider rakt mot det alla andra ryggar för.",
        whitehart:   "De lyssnar efter en röst — och prövar dem som säger sig höra den.",
        stormrider:  "De håller samman folk — så länge den som binder dem lever.",
        ironvale:    "De mäter allt, och bygger det ingen annan vågar.",
        blackcrest:  "De för handlingen — och handlingen är ett slags makt.",
        stonebear:   "De håller sitt ord bortom den punkt där det kostar dem allt.",
        tidebreaker: "De kartlägger allt, och delar nästan inget.",
        phoenix:     "De bygger på bränd mark och vägrar se ner."
      },
      q: [
        { q: "Ett svårt beslut hotar. Vad litar du mest på?", a: [
          ["En noggrann plan för varje utfall.", "blackthorn"],
          ["Det jag kan ta reda på som andra inte kan.", "ravenshade"],
          ["Mitt eget mod.", "ashbourne"],
          ["Det jag tror är sant.", "whitehart"] ] },
        { q: "Riket splittras. Din första ingivelse är att—", a: [
          ["Hålla alla samman.", "stormrider"],
          ["Bygga något nytt av spillrorna.", "ironvale"],
          ["Se till att den sanna berättelsen överlever.", "blackcrest"],
          ["Hålla eden jag svor, vad det än kostar.", "stonebear"] ] },
        { q: "Folk skulle säga att din största styrka är—", a: [
          ["Jag förstår mer än jag visar.", "tidebreaker"],
          ["Jag ger aldrig upp morgondagen.", "phoenix"],
          ["Jag tänker tre drag framåt.", "blackthorn"],
          ["Jag är helt enkelt inte rädd.", "ashbourne"] ] },
        { q: "En främling ber om din hjälp. Du—", a: [
          ["Väger först vad det kommer att kosta mig.", "blackthorn"],
          ["Frågar vad de inte berättar.", "ravenshade"],
          ["Hjälper — och håller mitt ord om det.", "stonebear"],
          ["Litar på impulsen att göra rätt.", "whitehart"] ] },
        { q: "Vad låter mest som du?", a: [
          ["Kunskap är värd mer än guld.", "tidebreaker"],
          ["Enhet är värd mer än att ha rätt.", "stormrider"],
          ["Berättelsen vi berättar blir sanningen.", "blackcrest"],
          ["Framtiden är värd vilken eld som helst.", "phoenix"] ] },
        { q: "När allt går fel, du—", a: [
          ["Bygger upp igen, bättre än förr.", "phoenix"],
          ["Går rakt på problemet.", "ashbourne"],
          ["Hittar faktumet alla missade.", "ravenshade"],
          ["Står fast vid det jag lovade.", "stonebear"] ] }
      ],
      ui: {
        progress: function (i, total) { return "Fråga " + i + " av " + total; },
        back: "← Tillbaka",
        eyebrow: "DU SKULLE FÖLJA",
        castVote: "Lägg detta som din röst i Tinget",
        followFree: "Följ gratis",
        joinReaders: function (n) { return "Gå med " + n + " läsare som följer med"; },
        shareLabel: "Berätta vilket hus du skulle följa",
        shareX: "Dela på X", facebook: "Facebook", reddit: "Reddit", copy: "Kopiera",
        again: "↻ Gör om",
        note: "Bokens kanon och centrala mysterier är författarens; Tinget och det här testet formar världen kring den — vad arkivet öppnar eller utforskar härnäst — aldrig berättelsens hjärta.",
        shareText: function (shortName) { return "Jag skulle följa House " + shortName + " i Aurefold — vilket hus skulle du följa?"; }
      }
    },
    es: {
      phil: {
        blackthorn: "Intelecto", ravenshade: "Información", ashbourne: "Coraje",
        whitehart: "Fe", stormrider: "Unidad", ironvale: "Innovación",
        blackcrest: "la historia del vencedor", stonebear: "Honor",
        tidebreaker: "Conocimiento", phoenix: "el futuro"
      },
      line: {
        blackthorn:  "Planean para cada futuro — y actúan un instante demasiado tarde.",
        ravenshade:  "Comercian con lo que la gente preferiría mantener oculto.",
        ashbourne:   "Cargan contra aquello de lo que todos los demás se apartan.",
        whitehart:   "Escuchan una voz — y ponen a prueba a quienes dicen oírla.",
        stormrider:  "Mantienen unida a la gente — mientras viva quien la une.",
        ironvale:    "Lo miden todo, y construyen lo que nadie más se atreve.",
        blackcrest:  "Guardan el registro — y el registro es una forma de poder.",
        stonebear:   "Mantienen su palabra más allá del punto en que les cuesta todo.",
        tidebreaker: "Lo cartografían todo, y comparten casi nada.",
        phoenix:     "Construyen sobre tierra quemada y se niegan a mirar abajo."
      },
      q: [
        { q: "Se avecina una decisión difícil. ¿En qué confías más?", a: [
          ["Un plan cuidadoso para cada desenlace.", "blackthorn"],
          ["En lo que puedo averiguar y otros no.", "ravenshade"],
          ["En mi propio temple.", "ashbourne"],
          ["En lo que creo que es verdad.", "whitehart"] ] },
        { q: "El reino se fractura. Tu primer instinto es—", a: [
          ["Mantener a todos unidos.", "stormrider"],
          ["Construir algo nuevo con los pedazos.", "ironvale"],
          ["Asegurar que el relato verdadero sobreviva.", "blackcrest"],
          ["Cumplir el juramento que hice, cueste lo que cueste.", "stonebear"] ] },
        { q: "La gente diría que tu mayor fortaleza es—", a: [
          ["Entiendo más de lo que aparento.", "tidebreaker"],
          ["Nunca renuncio al mañana.", "phoenix"],
          ["Pienso tres jugadas por delante.", "blackthorn"],
          ["Sencillamente no tengo miedo.", "ashbourne"] ] },
        { q: "Un desconocido te pide ayuda. Tú—", a: [
          ["Sopeso primero lo que me costará.", "blackthorn"],
          ["Pregunto qué es lo que no me cuentan.", "ravenshade"],
          ["Ayudo — y mantengo mi palabra.", "stonebear"],
          ["Confío en el impulso de hacer el bien.", "whitehart"] ] },
        { q: "¿Qué se parece más a ti?", a: [
          ["El conocimiento vale más que el oro.", "tidebreaker"],
          ["La unidad vale más que tener razón.", "stormrider"],
          ["La historia que contamos se vuelve la verdad.", "blackcrest"],
          ["El futuro vale cualquier fuego.", "phoenix"] ] },
        { q: "Cuando todo sale mal, tú—", a: [
          ["Reconstruyo, mejor que antes.", "phoenix"],
          ["Voy de frente contra el problema.", "ashbourne"],
          ["Encuentro el dato que todos pasaron por alto.", "ravenshade"],
          ["Me mantengo fiel a lo que prometí.", "stonebear"] ] }
      ],
      ui: {
        progress: function (i, total) { return "Pregunta " + i + " de " + total; },
        back: "← Atrás",
        eyebrow: "SEGUIRÍAS A",
        castVote: "Lleva esto como tu voto en El Cónclave",
        followFree: "Sigue gratis",
        joinReaders: function (n) { return "Únete a " + n + " lector" + (n === 1 ? "" : "es") + " que siguen el proyecto"; },
        shareLabel: "Diles a qué casa seguirías",
        shareX: "Compartir en X", facebook: "Facebook", reddit: "Reddit", copy: "Copiar",
        again: "↻ Volver a hacerlo",
        note: "El canon del libro y sus misterios centrales son del autor; El Cónclave y este test dan forma al mundo que rodea al libro — lo que el archivo abre o explora a continuación — nunca el corazón de la historia.",
        shareText: function (shortName) { return "Seguiría a House " + shortName + " en Aurefold — ¿a qué casa seguirías tú?"; }
      }
    }
  };

  var T = STR[LANG] || STR.en;
  var UI = T.ui;
  var Q = T.q;
  var answers = [];

  function el(tag, cls, text) {
    var n = document.createElement(tag);
    if (cls) n.className = cls;
    if (text != null) n.textContent = text;
    return n;
  }

  function render(i) {
    root.innerHTML = "";
    var total = Q.length;
    var prog = el("p", "quiz-progress", UI.progress(i + 1, total));
    root.appendChild(prog);
    var bar = el("div", "quiz-bar");
    var fill = el("div", "quiz-bar-fill");
    fill.style.width = Math.round((i / total) * 100) + "%";
    bar.appendChild(fill); root.appendChild(bar);

    root.appendChild(el("h2", "quiz-question", Q[i].q));
    var list = el("div", "quiz-options");
    Q[i].a.forEach(function (opt) {
      var b = el("button", "quiz-option", opt[0]);
      b.type = "button";
      b.addEventListener("click", function () {
        answers[i] = opt[1];
        if (i + 1 < total) render(i + 1); else result();
      });
      list.appendChild(b);
    });
    root.appendChild(list);
    if (i > 0) {
      var back = el("button", "quiz-back", UI.back);
      back.type = "button";
      back.addEventListener("click", function () { render(i - 1); });
      root.appendChild(back);
    }
  }

  function result() {
    var tally = {};
    answers.forEach(function (h) { tally[h] = (tally[h] || 0) + 1; });
    // highest score; ties broken by earliest appearance in answers
    var best = null, bestN = -1;
    answers.forEach(function (h) {
      if (tally[h] > bestN) { bestN = tally[h]; best = h; }
    });
    var house = HOUSES[best];

    root.innerHTML = "";
    var card = el("div", "quiz-result");
    card.appendChild(el("p", "quiz-result-eyebrow", UI.eyebrow));
    card.appendChild(el("h2", "quiz-result-house", house.name));
    card.appendChild(el("p", "quiz-result-phil", T.phil[best]));
    card.appendChild(el("p", "quiz-result-line", "“" + T.line[best] + "”"));

    var shortName = house.name.replace(/^House\s+/, "");
    // Share the per-house result page so the link unfurls with that house's card.
    var pageUrl = "https://aurefold.com/house-" + best + ".html";
    var shareText = UI.shareText(shortName);

    // Primary next steps: carry the result into the Moot, or follow the journey.
    var row = el("div", "cta-row");
    row.style.justifyContent = "center";

    // Pre-fills the matching option in the Moot's house poll (never submits).
    var a1 = el("a", "btn btn-primary", UI.castVote);
    a1.href = "vote.html#house=" + encodeURIComponent(best);

    // "Follow free" uses whatever support link is configured — no hardcoded URL.
    var sup = ((window.AUREFOLD_COMMUNITY || {}).support) || {};
    var followUrl = (sup.patreon && String(sup.patreon).trim()) ? String(sup.patreon).trim() : "support.html";
    var a2 = el("a", "btn btn-ghost", UI.followFree);
    a2.href = followUrl;
    if (/^https?:/i.test(followUrl)) { a2.target = "_blank"; a2.rel = "noopener"; }

    row.appendChild(a1); row.appendChild(a2);
    card.appendChild(row);

    // Social proof, if a real member count is configured (hidden otherwise).
    var mem = ((window.AUREFOLD_COMMUNITY || {}).momentum || {}).members;
    if (typeof mem === "number" && mem > 0) {
      card.appendChild(el("p", "social-proof", UI.joinReaders(mem)));
    }

    // Share chips reuse the site-wide .share-row pattern; the Copy chip uses the
    // shared [data-copy] handler in site.js. Nothing shares or copies on its own.
    var shareBlock = el("div", "share-block");
    shareBlock.appendChild(el("p", "share-label", UI.shareLabel));
    var share = el("div", "share-row");
    var enc = encodeURIComponent, t = enc(shareText), u = enc(pageUrl);
    [
      [UI.shareX, "https://twitter.com/intent/tweet?text=" + t + "&url=" + u],
      [UI.facebook, "https://www.facebook.com/sharer/sharer.php?u=" + u],
      [UI.reddit, "https://www.reddit.com/submit?url=" + u + "&title=" + t]
    ].forEach(function (l) {
      var a = el("a", "share-btn", l[0]);
      a.href = l[1]; a.target = "_blank"; a.rel = "noopener";
      share.appendChild(a);
    });
    var copy = el("button", "share-btn", UI.copy);
    copy.type = "button";
    copy.setAttribute("data-copy", shareText + " " + pageUrl);
    share.appendChild(copy);
    shareBlock.appendChild(share);
    card.appendChild(shareBlock);

    var again = el("button", "quiz-back", UI.again);
    again.type = "button";
    again.addEventListener("click", function () { answers = []; render(0); });
    card.appendChild(again);

    card.appendChild(el("p", "quiz-note", UI.note));
    root.appendChild(card);

    if (window.plausible) window.plausible("Quiz result", { props: { house: house.name } });
  }

  render(0);
})();
