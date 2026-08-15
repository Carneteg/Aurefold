/* AUREFOLD — the moot: load open polls, cast one vote per visitor, show results.
   This file is PRESENTATION ONLY. The Supabase data layer, its row-level
   security, the poll_tallies aggregate, and the one-vote-per-reader rule
   (unique vote per ew-voter) are all unchanged — no schema changes are made
   or required by anything below.

   Localized interface: the Moot's own chrome (buttons, notes, standings)
   follows <html lang>. Poll questions and options are served from Supabase
   in the language they were authored in, so they are shown verbatim. */
(function () {
  "use strict";

  var cfg = window.AUREFOLD_COMMUNITY || {};
  var root = document.getElementById("moot");
  if (!root) return;

  var LANG = (document.documentElement.lang || "en").slice(0, 2);
  var TX = {
    en: {
      decidedLast: "What the Moot decided last time",
      kindHouse: "The house question",
      kindNext: "What opens next",
      kindQuestion: "A question for the Moot",
      notPublished: "The moot convenes on the published site.",
      yourVoice: "Your voice — ",
      counted: "counted",
      voicesWord: function (n) { return n === 1 ? " voice" : " voices"; },
      changeChoice: "Change your choice",
      addVoice: "Add your voice",
      heard: function (total) { return "The Moot has heard " + total + (total === 1 ? " voice." : " voices."); },
      noVoicesYet: "No voices yet. Yours would be the first.",
      countedStanding: "Your voice is counted. The full standing opens once more readers weigh in.",
      earlyDays: "Early days — be among the first to weigh in.",
      keepChoice: "Keep my current choice",
      pickAnother: "Pick another option to change your voice, or keep your current one.",
      showStanding: "Show the standing without voting",
      onePerReader: "One voice per reader. The archive counts; it does not watch.",
      currentVoiceSuffix: " — your current voice",
      oneVoiceKept: "The Moot keeps one voice per reader — your first choice stands.",
      notReached: "The archive could not be reached. Try again in a moment.",
      fromQuiz: "From your quiz — this house is highlighted below. Cast it, or choose another. Nothing is sent until you pick.",
      convening: "Convening the moot…",
      notInSession: "The moot is not in session. Come back soon.",
      notReachedHere: "The archive could not be reached from here. The moot convenes on the published site — or try again in a moment."
    },
    sv: {
      decidedLast: "Vad Tinget beslutade förra gången",
      kindHouse: "Husfrågan",
      kindNext: "Vad som öppnas härnäst",
      kindQuestion: "En fråga till Tinget",
      notPublished: "Tinget sammanträder på den publicerade sajten.",
      yourVoice: "Din röst — ",
      counted: "räknad",
      voicesWord: function (n) { return n === 1 ? " röst" : " röster"; },
      changeChoice: "Ändra ditt val",
      addVoice: "Lägg till din röst",
      heard: function (total) { return "Tinget har hört " + total + (total === 1 ? " röst." : " röster."); },
      noVoicesYet: "Inga röster ännu. Din skulle vara den första.",
      countedStanding: "Din röst är räknad. Hela ställningen öppnas när fler läsare har sagt sitt.",
      earlyDays: "Tidiga dagar — var bland de första att säga sitt.",
      keepChoice: "Behåll mitt nuvarande val",
      pickAnother: "Välj ett annat alternativ för att ändra din röst, eller behåll ditt nuvarande.",
      showStanding: "Visa ställningen utan att rösta",
      onePerReader: "En röst per läsare. Arkivet räknar; det övervakar inte.",
      currentVoiceSuffix: " — din nuvarande röst",
      oneVoiceKept: "Tinget håller en röst per läsare — ditt första val gäller.",
      notReached: "Arkivet kunde inte nås. Försök igen om en stund.",
      fromQuiz: "Från ditt test — det här huset är markerat nedan. Lägg din röst på det, eller välj ett annat. Inget skickas förrän du väljer.",
      convening: "Sammankallar tinget…",
      notInSession: "Tinget är inte i session. Kom tillbaka snart.",
      notReachedHere: "Arkivet kunde inte nås härifrån. Tinget sammanträder på den publicerade sajten — eller försök igen om en stund."
    }
  };
  var T = TX[LANG] || TX.en;

  // Below this many votes a poll shows a ranked standing with subtle bars and
  // NO raw numbers ("be among the first"); at or above it, the real tallies
  // show. Inert until configured: an unset/zero value means "always reveal",
  // i.e. the previous behaviour.
  var threshold = Number(cfg.MOOT_REVEAL_THRESHOLD);
  if (!(threshold > 0)) threshold = 0;

  function el(tag, cls, text) {
    var n = document.createElement(tag);
    if (cls) n.className = cls;
    if (text) n.textContent = text;
    return n;
  }

  // Normalise a house label or key for matching, e.g. "House Whitehart" and
  // "whitehart" both become "whitehart".
  function normHouse(s) {
    return String(s == null ? "" : s).toLowerCase().replace(/^house\s+/, "").replace(/[^a-z0-9]/g, "");
  }

  // "What the Moot decided last time" — config-only, needs no network, so it
  // renders first and survives even if Supabase is unreachable. Hidden when
  // no title is set.
  function renderLastOutcome(last) {
    var card = el("article", "moot-card moot-outcome");
    card.appendChild(el("p", "moot-kind", T.decidedLast));
    card.appendChild(el("h2", "section-title", last.title));
    if (last.note && String(last.note).trim()) card.appendChild(el("p", "moot-desc", last.note));
    return card;
  }

  // A short eyebrow that tells the two questions apart at a glance. The poll
  // question text is authored in English in the data layer, so the keyword
  // match stays English; only the label shown to the reader is localized.
  function kindFor(poll) {
    var q = (poll.question || "").toLowerCase();
    if (/house/.test(q)) return T.kindHouse;
    if (/thread|chapter|scene|excerpt|\bopen|\bnext\b|topic|read|reveal|material/.test(q)) return T.kindNext;
    return T.kindQuestion;
  }

  root.innerHTML = "";
  var last = (cfg.moot && cfg.moot.lastOutcome) || null;
  if (last && last.title && String(last.title).trim()) {
    root.appendChild(renderLastOutcome(last));
  }

  var pollsBox = el("div", "moot-polls");
  root.appendChild(pollsBox);

  if (!cfg.supabaseUrl || !cfg.supabaseKey) {
    pollsBox.appendChild(el("p", "moot-note", T.notPublished));
    return;
  }

  var API = cfg.supabaseUrl + "/rest/v1";
  // Authorization mirrors apikey so PostgREST resolves the anon role reliably.
  var HEADERS = {
    apikey: cfg.supabaseKey,
    Authorization: "Bearer " + cfg.supabaseKey,
    "Content-Type": "application/json"
  };

  // One anonymous voter id per browser (never sent anywhere except the vote row).
  function voterId() {
    var id = localStorage.getItem("ew-voter");
    if (!id) {
      id = (crypto.randomUUID && crypto.randomUUID()) ||
        "xxxxxxxx-xxxx-4xxx-8xxx-xxxxxxxxxxxx".replace(/x/g, function () {
          return Math.floor(Math.random() * 16).toString(16);
        });
      localStorage.setItem("ew-voter", id);
    }
    return id;
  }
  function votedFor(pollId) { return localStorage.getItem("ew-voted-" + pollId); }
  function markVoted(pollId, optionId) { localStorage.setItem("ew-voted-" + pollId, optionId); }

  function fetchJson(url, opts) {
    return fetch(url, opts).then(function (r) {
      if (!r.ok && r.status !== 409) throw new Error("HTTP " + r.status);
      return r.status === 409 ? { conflict: true } : (r.status === 201 ? {} : r.json());
    });
  }

  function loadPolls() {
    return fetchJson(API + "/polls?select=id,question,description,poll_options(id,label,detail,sort)&open=eq.true&order=sort", { headers: HEADERS });
  }
  function loadResults() {
    // Aggregated counts live in a dedicated tally table (kept in sync by a
    // trigger). It exposes only the counts; raw votes stay private under RLS.
    return fetchJson(API + "/poll_tallies?select=poll_id,option_id,votes", { headers: HEADERS });
  }
  function castVote(pollId, optionId) {
    // return=minimal is required: voters may insert a vote but may not read
    // it back, so asking PostgREST to return the row would fail the request.
    var postHeaders = {
      apikey: HEADERS.apikey,
      Authorization: HEADERS.Authorization,
      "Content-Type": "application/json",
      Prefer: "return=minimal"
    };
    return fetchJson(API + "/votes", {
      method: "POST",
      headers: postHeaders,
      body: JSON.stringify({ poll_id: pollId, option_id: optionId, voter: voterId() })
    });
  }

  function renderPoll(poll, results) {
    var card = el("article", "moot-card");
    card.appendChild(el("p", "moot-kind", kindFor(poll)));
    card.appendChild(el("h2", "section-title", poll.question));
    if (poll.description) card.appendChild(el("p", "moot-desc", poll.description));
    var body = el("div", "moot-body");
    var note = el("p", "moot-note");
    card.appendChild(body);
    card.appendChild(note);

    // Per-poll state: the latest tallies, and whether the server has told us
    // that changing a vote isn't allowed (a 409 on re-cast).
    var state = { results: results, changeLocked: false };

    function optionById(id) {
      for (var i = 0; i < poll.poll_options.length; i++) {
        if (poll.poll_options[i].id === id) return poll.poll_options[i];
      }
      return null;
    }

    function tallies() {
      var counts = {}, total = 0, max = 0;
      (state.results || []).forEach(function (r) {
        if (r.poll_id === poll.id) {
          counts[r.option_id] = r.votes;
          total += r.votes;
          if (r.votes > max) max = r.votes;
        }
      });
      return { counts: counts, total: total, max: max };
    }

    // Show the standing. `chosen` is the option id this reader voted for (or
    // null when peeking). Below the reveal threshold we rank the options and
    // hide raw numbers; at/above it we show real counts and percentages.
    function showResults(chosen) {
      body.innerHTML = "";
      var t = tallies();
      var revealed = t.total >= threshold;

      if (chosen) {
        var opt = optionById(chosen);
        body.appendChild(el("p", "moot-yourvoice", T.yourVoice + (opt ? opt.label : T.counted)));
      }

      var ordered = poll.poll_options.slice().sort(function (a, b) {
        var d = (t.counts[b.id] || 0) - (t.counts[a.id] || 0);
        return d !== 0 ? d : a.sort - b.sort;
      });

      ordered.forEach(function (o, i) {
        var n = t.counts[o.id] || 0;
        var isChosen = chosen === o.id;
        var row = el("div", "moot-result" + (isChosen ? " chosen" : "") + (revealed ? "" : " ranked"));
        var head = el("div", "moot-result-head");
        head.appendChild(el("span", "moot-result-label", o.label));
        if (revealed) {
          var pct = t.total ? Math.round((n * 100) / t.total) : 0;
          head.appendChild(el("span", "moot-result-count", n + T.voicesWord(n) + " · " + pct + "%"));
        } else {
          head.appendChild(el("span", "moot-result-rank", "#" + (i + 1)));
        }
        var bar = el("div", "moot-bar");
        var fill = el("div", "moot-bar-fill");
        // Revealed: width is the true share. Ranked: width is relative to the
        // leader and capped low, so it reads as "order", not "proportion".
        var w = 0;
        if (revealed) w = t.total ? Math.max(Math.round((n * 100) / t.total), 2) : 0;
        else w = t.max ? Math.round((n / t.max) * 70) : 0;
        fill.style.width = w + "%";
        bar.appendChild(fill);
        row.appendChild(head);
        row.appendChild(bar);
        body.appendChild(row);
      });

      if (chosen && !state.changeLocked) {
        var change = el("button", "moot-peek moot-change", T.changeChoice);
        change.type = "button";
        change.addEventListener("click", function () { showVoting(chosen); });
        body.appendChild(change);
      } else if (!chosen) {
        var addVoice = el("button", "moot-peek moot-change", T.addVoice);
        addVoice.type = "button";
        addVoice.addEventListener("click", function () { showVoting(null); });
        body.appendChild(addVoice);
      }

      if (revealed) {
        note.textContent = t.total ? T.heard(t.total) : T.noVoicesYet;
      } else if (chosen) {
        note.textContent = T.countedStanding;
      } else {
        note.textContent = T.earlyDays;
      }
    }

    // Show the ballot. When `prevChoice` is set the reader is changing an
    // existing vote, so we add a "keep" escape hatch and honour the server's
    // one-vote rule on submit.
    function showVoting(prevChoice) {
      body.innerHTML = "";
      var list = el("div", "moot-options");
      poll.poll_options.slice().sort(function (a, b) { return a.sort - b.sort; }).forEach(function (o) {
        var btn = el("button", "moot-option");
        btn.type = "button";
        btn.setAttribute("data-house", normHouse(o.label));
        if (prevChoice && o.id === prevChoice) btn.className = "moot-option is-current";
        btn.appendChild(el("span", "moot-option-label", o.label + (prevChoice && o.id === prevChoice ? T.currentVoiceSuffix : "")));
        if (o.detail) btn.appendChild(el("span", "moot-option-detail", o.detail));
        btn.addEventListener("click", function () {
          if (prevChoice && o.id === prevChoice) { showResults(prevChoice); return; }
          Array.prototype.forEach.call(body.querySelectorAll(".moot-option"), function (b) { b.disabled = true; });
          castVote(poll.id, o.id).then(function (res) {
            if (prevChoice && res && res.conflict) {
              // The server keeps one vote per reader (unique on ew-voter); a
              // re-cast is refused. Reflect the stored choice and say so.
              state.changeLocked = true;
              showResults(prevChoice);
              note.textContent = T.oneVoiceKept;
              return;
            }
            markVoted(poll.id, o.id);
            return loadResults().then(function (r) { state.results = r; showResults(o.id); });
          }).catch(function () {
            Array.prototype.forEach.call(body.querySelectorAll(".moot-option"), function (b) { b.disabled = false; });
            note.textContent = T.notReached;
          });
        });
        list.appendChild(btn);
      });
      body.appendChild(list);

      if (prevChoice) {
        var keep = el("button", "moot-peek moot-change", T.keepChoice);
        keep.type = "button";
        keep.addEventListener("click", function () { showResults(prevChoice); });
        body.appendChild(keep);
        note.textContent = T.pickAnother;
      } else {
        var peek = el("button", "moot-peek", T.showStanding);
        peek.type = "button";
        peek.addEventListener("click", function () { showResults(null); });
        body.appendChild(peek);
        note.textContent = T.onePerReader;
      }
    }

    var chosen = votedFor(poll.id);
    if (chosen) showResults(chosen);
    else showVoting(null);
    return card;
  }

  // A reader arriving from the quiz (vote.html#house=<key>) gets the matching
  // house pre-selected in the ballot — highlighted only, never auto-cast. Does
  // nothing if they've already voted (no ballot to highlight) or find no match.
  function prehighlightFromHash(cards) {
    var m = /(?:^|[#&])house=([^&]+)/.exec(location.hash || "");
    if (!m) return;
    var raw;
    try { raw = decodeURIComponent(m[1]); } catch (e) { raw = m[1]; }
    var want = normHouse(raw);
    if (!want) return;
    for (var i = 0; i < cards.length; i++) {
      var btns = cards[i].querySelectorAll(".moot-option");
      for (var j = 0; j < btns.length; j++) {
        if (btns[j].getAttribute("data-house") === want) {
          btns[j].classList.add("is-suggested");
          btns[j].setAttribute("aria-current", "true");
          var note = cards[i].querySelector(".moot-note");
          if (note) note.textContent = T.fromQuiz;
          if (btns[j].scrollIntoView) btns[j].scrollIntoView({ block: "center" });
          return;
        }
      }
    }
  }

  pollsBox.appendChild(el("p", "moot-note", T.convening));
  Promise.all([loadPolls(), loadResults()]).then(function (all) {
    pollsBox.innerHTML = "";
    var polls = all[0], results = all[1];
    if (!polls.length) {
      pollsBox.appendChild(el("p", "moot-note", T.notInSession));
      return;
    }
    var cards = polls.map(function (p) {
      var c = renderPoll(p, results);
      pollsBox.appendChild(c);
      return c;
    });
    prehighlightFromHash(cards);
  }).catch(function () {
    pollsBox.innerHTML = "";
    pollsBox.appendChild(el("p", "moot-note", T.notReachedHere));
  });
})();
